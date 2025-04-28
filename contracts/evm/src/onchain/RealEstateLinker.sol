// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// --- OpenZeppelin 依赖 ---
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../token/ILKToken.sol";
import "../loan/ILKLendingPool.sol";

/// @title RealEstateLinker
/// @notice 锁定单个 NFT（ERC721 或 ER1155），分数化铸造 ERC20 份额，并支持赎回

contract RealEstateLinker is ERC721Holder, ERC1155Holder, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// 锁定的 NFT 信息
    struct Vault {
        address nftContract;
        uint256 tokenId;
        bool isERC1155;
        bool deposited;
        address user;
    }

    // 分数化代币工具类
    ILKToken public immutable i_lkToken;

    // 借贷池地址
    ILKLendingPool public lendingPool;

    // 是否开启计费
    bool private s_feeOn;
    // 手续费百分比
    uint256 private s_feePercentage = 3;

    // 清算者奖励百分比 (默认5%)
    uint256 internal liquidatorRewardPercentage = 5;

    // NFT 的 LTV 和清算阈值
    uint256 internal immutable NFT_LTV = 60;
    uint256 internal immutable NFT_LIQUIDATE_RATE = 80;

    // 用户的借款信息
    mapping(address user => uint256 amount) public userBorrow;

    // tokenId及对应的信息
    mapping(uint256 => Vault) public tokenIdToVault;

    // 事件定义
    event Deposited(address indexed user, address indexed nftContract, uint256 indexed tokenId, bool isERC1155);
    event Redeemed(uint256 indexed tokenId, address indexed user);
    event Liquidated(
        uint256 indexed tokenId,
        address indexed liquidator,
        address indexed owner,
        uint256 repayAmount,
        uint256 liquidatorReward,
        uint256 borrowerSurplus
    );
    event LendingPoolSet(address indexed lendingPool);
    event CollateralDepositedToPool(address indexed user, uint256 amount);
    event StablecoinBorrowed(address indexed user, address indexed stablecoin, uint256 amount);
    event StablecoinRepaid(address indexed user, address indexed stablecoin, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    constructor(address _lkToken) Ownable(msg.sender) {
        i_lkToken = ILKToken(_lkToken);
    }

    /// @notice 设置借贷池地址
    /// @param _lendingPool 借贷池合约地址
    function setLendingPool(address _lendingPool) external onlyOwner {
        require(_lendingPool != address(0), "Invalid lending pool address");
        lendingPool = ILKLendingPool(_lendingPool);
        emit LendingPoolSet(_lendingPool);
    }

    /// @notice 存入 ERC‑721 NFT 并铸造 ERC‑20 份额
    /// @param nftContract ERC721 合约地址
    /// @param tokenId 要分数化的 NFT ID
    function depositERC721(address nftContract, uint256 tokenId) external nonReentrant {
        Vault storage vault = tokenIdToVault[tokenId];
        require(!vault.deposited, "Already deposited");
        // 转移 NFT 到本合约
        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId);
        // 记录 NFT 信息
        vault.nftContract = nftContract;
        vault.tokenId = tokenId;
        vault.isERC1155 = false;
        vault.deposited = true;
        vault.user = msg.sender;
        // 计算份额
        (, uint256 valuationInUsdc) = i_lkToken.calcShares(tokenId);

        // 铸造份额
        uint256 mintAmount = valuationInUsdc;

        // 铸造份额
        i_lkToken.mint(msg.sender, mintAmount);

        emit Deposited(msg.sender, nftContract, tokenId, false);
    }

    /// @notice 存入 ERC‑1155 NFT 并铸造 ERC‑20 份额
    /// @param nftContract ERC1155 合约地址
    /// @param tokenId 要分数化的 NFT ID
    function depositERC1155(address nftContract, uint256 tokenId) external nonReentrant {
        Vault storage vault = tokenIdToVault[tokenId];
        require(!vault.deposited, "Already deposited");
        // 仅转 1 个单位
        IERC1155(nftContract).safeTransferFrom(msg.sender, address(this), tokenId, 1, "");

        // 记录 NFT 信息
        vault.nftContract = nftContract;
        vault.tokenId = tokenId;
        vault.isERC1155 = true;
        vault.deposited = true;
        vault.user = msg.sender;

        // 计算份额
        (, uint256 valuationInUsdc) = i_lkToken.calcShares(tokenId);
        // 铸造份额
        uint256 mintAmount = valuationInUsdc * NFT_LTV / 100;

        // 铸造份额
        i_lkToken.mint(msg.sender, mintAmount);
        emit Deposited(msg.sender, nftContract, tokenId, true);
    }

    // todo: 清算
    function liquidate(uint256 tokenId) external nonReentrant {
        Vault storage vault = tokenIdToVault[tokenId];
        require(vault.deposited, "No NFT deposited");
        address owner = vault.user;
        require(userBorrow[owner] > 0, "No borrow");
        // 计算份额
        (, uint256 currentValue) = i_lkToken.calcShares(tokenId);
        uint256 borrowAmount = userBorrow[owner];
        uint256 healthFactor = currentValue * 100 / borrowAmount;
        require(healthFactor < NFT_LIQUIDATE_RATE, "Health factor is too low");

        // 总债务
        uint256 repayAmount = borrowAmount;
        uint256 liquidatorReward = repayAmount * liquidatorRewardPercentage / 100;
        uint256 totalPayment = repayAmount + liquidatorReward;
        // 抵押者的剩余价值
        uint256 borrowerSurplus = currentValue;

        // 清算者还钱
        i_lkToken.approve(address(this), totalPayment);
        i_lkToken.transferFrom(msg.sender, address(this), totalPayment);

        // 抵押者拿到补偿
        userBorrow[owner] = 0;
        i_lkToken.approve(owner, borrowerSurplus);
        i_lkToken.transferFrom(address(this), owner, borrowerSurplus);
        if (vault.isERC1155) {
            IERC1155(vault.nftContract).safeTransferFrom(address(this), owner, vault.tokenId, 1, "");
        } else {
            IERC721(vault.nftContract).safeTransferFrom(address(this), owner, vault.tokenId);
        }

        // 更新状态
        vault.deposited = false;
        emit Liquidated(tokenId, msg.sender, owner, repayAmount, liquidatorReward, borrowerSurplus);
    }

    /// @dev 赎回者必须先 approve 本合约所有 i_shareToken
    function redeem(uint256 tokenId) external nonReentrant {
        Vault storage vault = tokenIdToVault[tokenId];
        require(vault.deposited, "No NFT deposited");
        require(vault.user == msg.sender, "Not the owner");
        // 赎回者销毁其全部份额
        uint256 bal = i_lkToken.balanceOf(msg.sender);
        (, uint256 valuationInUsdc) = i_lkToken.calcShares(tokenId);

        require(bal >= valuationInUsdc, "Insufficient shares");

        userBorrow[msg.sender] = 0;
        i_lkToken.approve(address(this), valuationInUsdc);
        i_lkToken.transferFrom(msg.sender, address(this), valuationInUsdc);

        // 重置状态
        vault.deposited = false;

        // 返还 NFT
        if (vault.isERC1155) {
            IERC1155(vault.nftContract).safeTransferFrom(address(this), msg.sender, vault.tokenId, 1, "");
        } else {
            IERC721(vault.nftContract).safeTransferFrom(address(this), msg.sender, vault.tokenId);
        }

        emit Redeemed(tokenId, msg.sender);
    }

    // ======================= 借贷集成功能 =======================

    /// @notice 将LKToken存入借贷池作为抵押品
    /// @param amount LKToken数量
    function depositToLendingPool(uint256 amount) external nonReentrant {
        require(address(lendingPool) != address(0), "Lending pool not set");
        require(amount > 0, "Amount must be greater than zero");

        // 检查用户余额
        require(i_lkToken.balanceOf(msg.sender) >= amount, "Insufficient LKToken balance");

        // 将LKToken转移到本合约
        i_lkToken.transferFrom(msg.sender, address(this), amount);

        // 授权借贷池使用LKToken
        i_lkToken.approve(address(lendingPool), amount);

        // 调用借贷池的存款函数
        lendingPool.depositCollateral(amount);

        emit CollateralDepositedToPool(msg.sender, amount);
    }

    /// @notice 从借贷池借出稳定币
    /// @param stablecoin 稳定币地址
    /// @param amount 借款金额
    function borrowFromLendingPool(address stablecoin, uint256 amount) external nonReentrant {
        require(address(lendingPool) != address(0), "Lending pool not set");
        require(amount > 0, "Amount must be greater than zero");

        // 检查用户可借款额度
        (,, uint256 availableBorrowsValue,,) = lendingPool.getUserAccountData(address(this));

        require(availableBorrowsValue >= amount, "Borrow amount exceeds limit");

        // 调用借贷池的借款函数
        lendingPool.borrowStablecoin(stablecoin, amount);

        // 将借到的稳定币转给用户
        IERC20(stablecoin).safeTransfer(msg.sender, amount);

        emit StablecoinBorrowed(msg.sender, stablecoin, amount);
    }

    /// @notice 从借贷池提取LKToken抵押品
    /// @param amount 提取金额
    function withdrawFromLendingPool(uint256 amount) external nonReentrant {
        require(address(lendingPool) != address(0), "Lending pool not set");
        require(amount > 0, "Amount must be greater than zero");

        // 调用借贷池的提款函数
        lendingPool.withdrawCollateral(amount);

        // 将LKToken转给用户
        i_lkToken.transferFrom(address(this), msg.sender, amount);

        emit CollateralWithdrawn(msg.sender, amount);
    }

    /// @notice 偿还借贷池的贷款
    /// @param stablecoin 稳定币地址
    /// @param amount 偿还金额
    function repayToLendingPool(address stablecoin, uint256 amount) external nonReentrant {
        require(address(lendingPool) != address(0), "Lending pool not set");
        require(amount > 0, "Amount must be greater than zero");

        // 从用户转入稳定币
        IERC20(stablecoin).safeTransferFrom(msg.sender, address(this), amount);

        // 授权借贷池使用稳定币
        IERC20(stablecoin).approve(address(lendingPool), amount);

        // 调用借贷池的还款函数
        lendingPool.repayLoan(stablecoin, amount);

        emit StablecoinRepaid(msg.sender, stablecoin, amount);
    }

    /// @notice 获取用户在借贷池中的账户数据
    function getLendingPoolAccountData()
        external
        view
        returns (
            uint256 totalCollateralValue,
            uint256 totalDebtValue,
            uint256 availableBorrowsValue,
            uint256 currentLiquidationThreshold,
            uint256 healthFactor
        )
    {
        require(address(lendingPool) != address(0), "Lending pool not set");

        return lendingPool.getUserAccountData(address(this));
    }
}
