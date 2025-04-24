// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// --- OpenZeppelin 依赖 ---
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../token/ILKToken.sol";

/// @title LKLendingPool
/// @notice 基于LKToken的借贷池，允许用户以LKToken为抵押借出稳定币
contract LKLendingPool is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// 稳定币池信息
    struct StablecoinPool {
        bool isSupported; // 是否支持该稳定币
        uint256 totalSupply; // 稳定币总供应量
        uint256 totalBorrowed; // 已借出的稳定币总量
        uint256 lendRate; // 年化利率 (基点: 1% = 100)
        uint256 borrowRate; // 年化借出利率 (基点: 1% = 100)
    }

    // 用户借款信息
    struct UserLoan {
        uint256 loanAmount; // 借款金额
        uint256 lastUpdateTime; // 上次更新时间
    }

    // 用户存款信息
    struct UserLend {
        uint256 lendAmount; // 存款金额
        uint256 lastUpdateTime; // 上次更新时间
    }

    // LKToken实例
    ILKToken public immutable i_lkToken;

    // 是否开启计费
    bool private s_feeOn;
    // 手续费百分比 (基点: 0.3% = 30)
    uint256 private s_feePercentage = 30;

    // 清算者奖励百分比 (默认5%)
    uint256 public liquidatorRewardPercentage = 5;

    // LKToken的贷款价值比 (默认60%)
    uint256 public constant LTV_RATIO = 60;
    // 清算阈值 (默认75%)
    uint256 public constant LIQUIDATION_THRESHOLD = 75;

    // 支持的稳定币列表
    address[] public supportedStablecoins;

    // 稳定币地址 => 池信息
    mapping(address => StablecoinPool) public stablecoinPools;

    // 用户地址 => 质押的LKToken数量
    mapping(address => uint256) public userCollateral;

    // 用户地址 => 稳定币地址 => 借款信息
    mapping(address => mapping(address => UserLoan)) public userLoans;

    // 用户地址 => 稳定币地址 => 存款信息
    mapping(address => mapping(address => UserLend)) public userLends;

    // 事件定义
    event StablecoinAdded(address indexed stablecoin, uint256 lendRate);
    event StablecoinDeposited(address indexed depositor, address indexed stablecoin, uint256 amount);
    event StablecoinWithdrawn(address indexed withdrawer, address indexed stablecoin, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event LoanTaken(address indexed borrower, address indexed stablecoin, uint256 amount);
    event LoanRepaid(address indexed borrower, address indexed stablecoin, uint256 amount, uint256 interest);
    event PositionLiquidated(
        address indexed borrower,
        address indexed liquidator,
        address indexed stablecoin,
        uint256 debtRepaid,
        uint256 collateralLiquidated
    );
    event FeeUpdated(uint256 newFeePercentage);
    event LiquidatorRewardUpdated(uint256 newRewardPercentage);

    constructor(address _lkToken) Ownable(msg.sender) {
        require(_lkToken != address(0), "Invalid LKToken address");
        i_lkToken = ILKToken(_lkToken);
    }

    // ======================= 管理员功能 =======================

    /// @notice 添加支持的稳定币 (仅所有者)
    /// @param stablecoin 稳定币地址
    /// @param lendRate 年化利率 (基点: 1% = 100)
    function addStablecoin(address stablecoin, uint256 lendRate, uint256 borrowRate) external onlyOwner {
        require(stablecoin != address(0), "Invalid stablecoin address");
        require(!stablecoinPools[stablecoin].isSupported, "Stablecoin already supported");
        require(lendRate <= 2000, "Interest rate too high"); // 最高20%

        stablecoinPools[stablecoin] = StablecoinPool({
            isSupported: true,
            totalSupply: 0,
            totalBorrowed: 0,
            lendRate: lendRate,
            borrowRate: borrowRate
        });

        supportedStablecoins.push(stablecoin);

        emit StablecoinAdded(stablecoin, lendRate);
    }

    /// @notice 设置手续费百分比 (仅所有者)
    /// @param feePercentage 新的手续费百分比 (基点)
    function setFeePercentage(uint256 feePercentage) external onlyOwner {
        require(feePercentage <= 500, "Fee too high"); // 最高5%
        s_feePercentage = feePercentage;
        emit FeeUpdated(feePercentage);
    }

    /// @notice 设置清算者奖励百分比 (仅所有者)
    /// @param rewardPercentage 新的奖励百分比
    function setLiquidatorRewardPercentage(uint256 rewardPercentage) external onlyOwner {
        require(rewardPercentage <= 10, "Reward too high"); // 最高10%
        liquidatorRewardPercentage = rewardPercentage;
        emit LiquidatorRewardUpdated(rewardPercentage);
    }

    // ======================= 主要功能 =======================

    /// @notice 存入稳定币到协议
    /// @param stablecoin 稳定币地址
    /// @param amount 存款金额
    function depositStablecoin(address stablecoin, uint256 amount) external nonReentrant {
        require(stablecoinPools[stablecoin].isSupported, "Stablecoin not supported");
        require(amount > 0, "Amount must be greater than zero");

        // 转移稳定币到合约
        IERC20(stablecoin).safeTransferFrom(msg.sender, address(this), amount);

        // 更新稳定币池信息
        stablecoinPools[stablecoin].totalSupply += amount;

        // 更新用户存款信息
        userLends[msg.sender][stablecoin].lendAmount += amount;
        userLends[msg.sender][stablecoin].lastUpdateTime = block.timestamp;

        emit StablecoinDeposited(msg.sender, stablecoin, amount);
    }

    /// @notice 存入LKToken作为抵押品
    /// @param amount LKToken数量
    function depositCollateral(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");

        // 转移LKToken到合约
        i_lkToken.transferFrom(msg.sender, address(this), amount);

        // 更新用户抵押信息
        userCollateral[msg.sender] += amount;

        emit CollateralDeposited(msg.sender, amount);
    }

    /// @notice 提取LKToken抵押品
    /// @param amount 提取金额
    function withdrawCollateral(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        require(userCollateral[msg.sender] >= amount, "Insufficient collateral");

        // 计算提取后的健康因子
        uint256 collateralValueAfter = userCollateral[msg.sender] - amount;

        // 检查用户所有借款
        for (uint256 i = 0; i < supportedStablecoins.length; i++) {
            address stablecoin = supportedStablecoins[i];
            UserLoan storage loan = userLoans[msg.sender][stablecoin];

            if (loan.loanAmount > 0) {
                uint256 interest = calculateBorrowInterest(msg.sender, stablecoin);
                uint256 totalDebt = loan.loanAmount + interest;

                // 确保提取后抵押率仍然安全
                if (totalDebt > 0) {
                    uint256 collateralRatio = collateralValueAfter * 100 / totalDebt;
                    require(collateralRatio >= LIQUIDATION_THRESHOLD, "Withdrawal would risk liquidation");
                }
            }
        }

        // 更新抵押信息
        userCollateral[msg.sender] -= amount;

        // 转移LKToken回用户
        i_lkToken.approve(msg.sender, amount);
        i_lkToken.transferFrom(address(this), msg.sender, amount);

        emit CollateralWithdrawn(msg.sender, amount);
    }

    function withdrawStablecoin(address stablecoin, uint256 amount) external nonReentrant {
        require(stablecoinPools[stablecoin].isSupported, "Stablecoin not supported");
        require(amount > 0, "Amount must be greater than zero");

        // 转移稳定币到用户
        UserLend storage lend = userLends[msg.sender][stablecoin];
        uint256 lendAmount = lend.lendAmount;
        uint256 lendInterest = calculateLendInterest(msg.sender, stablecoin);
        amount = amount >= lendAmount + lendInterest ? lendAmount + lendInterest : amount;
        // 转移稳定币到用户
        IERC20(stablecoin).safeTransfer(msg.sender, amount);

        if (amount >= lendAmount + lendInterest) {
            lend.lendAmount = 0;
            lend.lastUpdateTime = block.timestamp;
        } else {
            if (amount >= lendInterest) {
                lend.lendAmount -= amount - lendInterest;
                lend.lastUpdateTime = block.timestamp;
            } else {
                uint256 timeElapsed = block.timestamp - lend.lastUpdateTime;
                uint256 interestRatio = (amount * 1e18) / (lendInterest);
                uint256 timeReduction = interestRatio * timeElapsed / 1e18;
                lend.lastUpdateTime = lend.lastUpdateTime + timeReduction;
            }
        }
        emit StablecoinWithdrawn(msg.sender, stablecoin, amount);
    }

    /// @notice 借出稳定币
    /// @param stablecoin 稳定币地址
    /// @param amount 借款金额
    function borrowStablecoin(address stablecoin, uint256 amount) external nonReentrant {
        require(stablecoinPools[stablecoin].isSupported, "Stablecoin not supported");
        require(amount > 0, "Amount must be greater than zero");

        // 检查借款池流动性
        StablecoinPool storage pool = stablecoinPools[stablecoin];
        require(pool.totalSupply - pool.totalBorrowed >= amount, "Insufficient liquidity");

        // 计算用户最大可借金额
        uint256 maxBorrowAmount = calculateMaxBorrow(msg.sender);
        uint256 currentBorrowedTotal = getTotalBorrowedValue(msg.sender);

        require(currentBorrowedTotal + amount <= maxBorrowAmount, "Borrow exceeds allowed amount");

        // 判断健康因子
        uint256 healthFactor = userCollateral[msg.sender] * 100 / (currentBorrowedTotal + amount);
        require(healthFactor >= LIQUIDATION_THRESHOLD, "Health factor below liquidation threshold");

        // 更新借款信息
        UserLoan storage loan = userLoans[msg.sender][stablecoin];
        loan.loanAmount += amount;
        loan.lastUpdateTime = block.timestamp;

        // 更新池信息
        pool.totalBorrowed += amount;

        // 转移稳定币给用户
        IERC20(stablecoin).safeTransfer(msg.sender, amount);

        emit LoanTaken(msg.sender, stablecoin, amount);
    }

    /// @notice 偿还借款
    /// @param stablecoin 稳定币地址
    /// @param amount 偿还金额
    function repayLoan(address stablecoin, uint256 amount) external nonReentrant {
        require(stablecoinPools[stablecoin].isSupported, "Stablecoin not supported");
        require(amount > 0, "Amount must be greater than zero");

        UserLoan storage loan = userLoans[msg.sender][stablecoin];
        require(loan.loanAmount > 0, "No active loan");

        // 计算利息
        uint256 interest = calculateBorrowInterest(msg.sender, stablecoin);
        uint256 totalOwed = loan.loanAmount + interest;

        // 确定实际还款金额
        uint256 paymentAmount = amount > totalOwed ? totalOwed : amount;

        // 转移稳定币到合约
        IERC20(stablecoin).safeTransferFrom(msg.sender, address(this), paymentAmount);

        // 更新借款信息
        if (paymentAmount >= totalOwed) {
            // 全额还款
            stablecoinPools[stablecoin].totalBorrowed -= loan.loanAmount;
            loan.loanAmount = 0;
            loan.lastUpdateTime = 0;
        } else {
            // 部分还款
            if (paymentAmount >= interest) {
                uint256 principalPayment = paymentAmount - interest;
                stablecoinPools[stablecoin].totalBorrowed -= principalPayment;
                loan.loanAmount -= principalPayment;
                loan.lastUpdateTime = block.timestamp;
            } else {
                // 如果只偿还了部分利息，需要重新计算时间
                uint256 timeElapsed = block.timestamp - loan.lastUpdateTime;
                uint256 interestRatio = (paymentAmount * 1e18) / (interest);
                uint256 timeReduction = interestRatio * timeElapsed / 1e18;
                loan.lastUpdateTime = loan.lastUpdateTime + timeReduction;
            }
        }

        emit LoanRepaid(msg.sender, stablecoin, paymentAmount, interest);
    }

    /// @notice 清算不健康的头寸
    /// @param borrower 被清算的借款人
    /// @param stablecoin 稳定币地址
    /// @param debtToCover 要偿还的债务金额
    function liquidatePosition(address borrower, address stablecoin, uint256 debtToCover) external nonReentrant {
        require(stablecoinPools[stablecoin].isSupported, "Stablecoin not supported");
        require(debtToCover > 0, "Amount must be greater than zero");
        require(borrower != msg.sender, "Cannot liquidate own position");

        // 计算借款人健康因子
        uint256 healthFactor = calculateHealthFactor(borrower);
        require(healthFactor < LIQUIDATION_THRESHOLD, "Position not liquidatable");

        UserLoan storage loan = userLoans[borrower][stablecoin];
        require(loan.loanAmount > 0, "No active loan");

        // 计算利息和总债务
        uint256 interest = calculateBorrowInterest(borrower, stablecoin);
        uint256 totalDebt = loan.loanAmount + interest;

        // 限制清算金额
        uint256 maxLiquidationAmount = totalDebt / 2; // 最多清算50%
        uint256 actualDebtToCover = debtToCover > maxLiquidationAmount ? maxLiquidationAmount : debtToCover;
        actualDebtToCover = actualDebtToCover > totalDebt ? totalDebt : actualDebtToCover;

        // 计算清算者获得的抵押品金额 (债务金额 + 奖励)
        uint256 bonusMultiplier = 100 + liquidatorRewardPercentage;
        uint256 collateralToLiquidate = (actualDebtToCover * bonusMultiplier) / 100;

        // 确保借款人有足够抵押品
        require(userCollateral[borrower] >= collateralToLiquidate, "Insufficient collateral");

        // 清算者还款
        IERC20(stablecoin).safeTransferFrom(msg.sender, address(this), actualDebtToCover);

        // 更新借款信息
        if (actualDebtToCover >= totalDebt) {
            stablecoinPools[stablecoin].totalBorrowed -= loan.loanAmount;
            loan.loanAmount = 0;
            loan.lastUpdateTime = 0;
        } else {
            // 部分还款
            if (actualDebtToCover >= interest) {
                uint256 principalPayment = actualDebtToCover - interest;
                stablecoinPools[stablecoin].totalBorrowed -= principalPayment;
                loan.loanAmount -= principalPayment;
                loan.lastUpdateTime = block.timestamp;
            } else {
                // 如果只偿还了部分利息，需要重新计算时间
                uint256 timeElapsed = block.timestamp - loan.lastUpdateTime;
                uint256 interestRatio = (actualDebtToCover * 1e18) / (interest);
                uint256 timeReduction = interestRatio * timeElapsed / 1e18;
                loan.lastUpdateTime = loan.lastUpdateTime + timeReduction;
            }
        }

        // 更新抵押品
        userCollateral[borrower] -= collateralToLiquidate;

        // 清算者获得抵押品
        i_lkToken.approve(msg.sender, collateralToLiquidate);
        i_lkToken.transferFrom(address(this), msg.sender, collateralToLiquidate);

        emit PositionLiquidated(borrower, msg.sender, stablecoin, actualDebtToCover, collateralToLiquidate);
    }

    // ======================= 辅助函数 =======================

    /// @notice 计算借出利息
    /// @param user 用户地址
    /// @param stablecoin 稳定币地址
    /// @return 累积的利息
    function calculateBorrowInterest(address user, address stablecoin) public view returns (uint256) {
        UserLoan storage loan = userLoans[user][stablecoin];
        if (loan.loanAmount == 0 || loan.lastUpdateTime == 0) {
            return 0;
        }

        uint256 timeElapsed = block.timestamp - loan.lastUpdateTime;

        // 计算利息: 本金 * 利率 * 时间 / (365天 * 100)
        return (loan.loanAmount * stablecoinPools[stablecoin].borrowRate * timeElapsed) / (365 days * 100);
    }

    /// @notice 计算存款利息
    /// @param user 用户地址
    /// @param stablecoin 稳定币地址
    /// @return 累积的利息
    function calculateLendInterest(address user, address stablecoin) public view returns (uint256) {
        UserLend storage lend = userLends[user][stablecoin];
        if (lend.lendAmount == 0 || lend.lastUpdateTime == 0) {
            return 0;
        }
        uint256 timeElapsed = block.timestamp - lend.lastUpdateTime;
        // 计算利息: 本金 * 利率 * 时间 / (365天 * 100)
        return (lend.lendAmount * stablecoinPools[stablecoin].lendRate * timeElapsed) / (365 days * 100);
    }

    /// @notice 计算用户健康因子
    /// @param user 用户地址
    /// @return 健康因子 (100 = 100%)
    function calculateHealthFactor(address user) public view returns (uint256) {
        uint256 totalBorrowed = getTotalBorrowedValue(user);
        if (totalBorrowed == 0) {
            return type(uint256).max; // 无借款时返回最大值
        }

        return (userCollateral[user] * 100) / totalBorrowed;
    }

    /// @notice 计算用户可以借出的最大金额
    /// @param user 用户地址
    /// @return 最大可借金额
    function calculateMaxBorrow(address user) public view returns (uint256) {
        return (userCollateral[user] * LTV_RATIO) / 100;
    }

    /// @notice 获取用户所有借款的总价值
    /// @param user 用户地址
    /// @return 总借款金额 (包括利息)
    function getTotalBorrowedValue(address user) public view returns (uint256) {
        uint256 totalBorrowed = 0;

        for (uint256 i = 0; i < supportedStablecoins.length; i++) {
            address stablecoin = supportedStablecoins[i];
            UserLoan storage loan = userLoans[user][stablecoin];

            if (loan.loanAmount > 0) {
                uint256 interest = calculateBorrowInterest(user, stablecoin);
                totalBorrowed += (loan.loanAmount + interest);
            }
        }

        return totalBorrowed;
    }

    /// @notice 获取用户账户数据
    /// @param user 用户地址
    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalLendValue,
            uint256 totalCollateralValue,
            uint256 totalDebtValue,
            uint256 availableBorrowsValue,
            uint256 currentLiquidationThreshold,
            uint256 healthFactor
        )
    {
        for (uint256 i = 0; i < supportedStablecoins.length; i++) {
            address stablecoin = supportedStablecoins[i];
            totalLendValue += userLends[user][stablecoin].lendAmount + calculateLendInterest(user, stablecoin);
        }

        totalCollateralValue = userCollateral[user];
        totalDebtValue = getTotalBorrowedValue(user);

        // 可借金额 = 最大可借金额 - 已借金额
        uint256 maxBorrowValue = calculateMaxBorrow(user);
        availableBorrowsValue = totalDebtValue >= maxBorrowValue ? 0 : maxBorrowValue - totalDebtValue;

        currentLiquidationThreshold = LIQUIDATION_THRESHOLD;
        healthFactor = calculateHealthFactor(user);

        return (
            totalLendValue,
            totalCollateralValue,
            totalDebtValue,
            availableBorrowsValue,
            currentLiquidationThreshold,
            healthFactor
        );
    }

    /// @notice 获取稳定币池信息
    /// @param stablecoin 稳定币地址
    function getStablecoinPoolData(address stablecoin)
        external
        view
        returns (
            bool isSupported,
            uint256 totalSupply,
            uint256 totalBorrowed,
            uint256 availableLiquidity,
            uint256 utilizationRate,
            uint256 lendRate
        )
    {
        StablecoinPool storage pool = stablecoinPools[stablecoin];

        isSupported = pool.isSupported;
        totalSupply = pool.totalSupply;
        totalBorrowed = pool.totalBorrowed;
        availableLiquidity = totalSupply - totalBorrowed;

        // 使用率 = 已借 / 总供应 (百分比)
        utilizationRate = totalSupply > 0 ? (totalBorrowed * 100) / totalSupply : 0;
        lendRate = pool.lendRate;

        return (isSupported, totalSupply, totalBorrowed, availableLiquidity, utilizationRate, lendRate);
    }
}
