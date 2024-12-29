// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {RealEstateToken} from "../onchain/RealEstateToken.sol";
import {IERC1155Receiver, IERC165} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {OwnerIsCreator} from "@chainlink/contracts/src/v0.8/shared/access/OwnerIsCreator.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract RwaLending is IERC1155Receiver, OwnerIsCreator, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct LoanedInfo {
        uint256 erc1155StakingAmount;
        uint256 usdcLoanedAmount;
        uint256 usdcLiquidateThresholdAmount;
    }

    event Borrow(
        uint256 indexed tokenId,
        uint256 amount,
        uint256 indexed loanAmount,
        uint256 indexed liquidationThreshold
    );
    event BorrowRepayed(uint256 indexed tokenId, uint256 indexed amount);
    event Liquidated(uint256 indexed tokenId);

    error AlreadyBorrowed(address borrower, uint256 tokenId);
    error OnlyRealEstateTokenSupported();
    error InvalidValuation();
    error SlippageToleranceExceeded();
    error PriceFeedDdosed();
    error InvalidRoundId();
    error StalePriceFeed();
    error NothingToRepay();

    RealEstateToken internal immutable stakingRealEstateToken;
    IERC20 internal immutable usdcToken;
    AggregatorV3Interface internal usdcUsdAggregatorApi;
    uint32 internal usdcUsdFeedHeartbeatInterval;
    // TBC: support to update them?
    uint256 internal immutable initialLoanThresholdRate;
    uint256 internal immutable liquidateLoanThresholdRate;

    // TODO: should be dynamically?
    uint256 internal immutable i_weightListPrice;
    uint256 internal immutable i_weightOriginalListPrice;
    uint256 internal immutable i_weightTaxAssessedValue;

    mapping(uint256 tokenId => mapping(address borrower => LoanedInfo))
        internal loanedBooks;

    constructor(
        address realEstateTokenAddress,
        address usdc,
        address usdcUsdAggregatorAddress,
        uint32 usdcUsdFeedHeartbeat
    ) {
        stakingRealEstateToken = RealEstateToken(realEstateTokenAddress);
        usdcToken = IERC20(usdc);
        usdcUsdAggregatorApi = AggregatorV3Interface(usdcUsdAggregatorAddress);
        usdcUsdFeedHeartbeatInterval = usdcUsdFeedHeartbeat;

        i_weightListPrice = 50;
        i_weightOriginalListPrice = 30;
        i_weightTaxAssessedValue = 20;

        initialLoanThresholdRate = 60;
        liquidateLoanThresholdRate = 75;
    }

    function borrow(
        uint256 tokenId,
        uint256 erc1155StakingAmount,
        bytes memory data,
        uint256 minLoanAmount,
        uint256 maxLiquidationThresholdAmount // TBC: 此参数无意义待删除???
    ) external nonReentrant {
        if (loanedBooks[tokenId][msg.sender].usdcLoanedAmount != 0)
            revert AlreadyBorrowed(msg.sender, tokenId);

        // 1. 计算质押(Token)的当前价值(USDC). 注: 由于 chainlink 预言机 dataFeed API 动态抓取推送过来的准实时价格为 USD 单位, 因此需要根据 USDC/USD 汇率换算
        // 2. 计算质押价值(USDC) = (Token)当前总价值(USDC) * 质押的(Token)与总供应量的比例
        uint256 normalizedValuationInUsdc = (getValuationInUsdc(tokenId) *
            erc1155StakingAmount) / stakingRealEstateToken.totalSupply(tokenId);

        if (normalizedValuationInUsdc == 0) revert InvalidValuation();

        // 3. 计算可贷款额(USDC): 质押价值(USDC)的60%作为可贷款额额(USDC) -- 避免因价格波动资不抵债
        uint256 usdcLoanedAmount = (normalizedValuationInUsdc *
            initialLoanThresholdRate) / 100;
        // 4. 检查若可贷款额(USDC)小于最低质押价值(USDC)则放弃贷款 -- 能贷出的太少了就不想贷了
        if (usdcLoanedAmount < minLoanAmount)
            revert SlippageToleranceExceeded();

        // 5. 计算触发清算阈值(USDC): 质押价值(USDC)的75%作为触发清算的阈值(USDC)
        uint256 usdcLiquidateThresholdAmount = (normalizedValuationInUsdc *
            liquidateLoanThresholdRate) / 100;

        // 6. 检查若触发清算阈值(USDC)大于最大期望清算阈值(USDC)则终止贷款 -- 能贷出的太多了就不想贷了 ???
        if (usdcLiquidateThresholdAmount > maxLiquidationThresholdAmount) {
            revert SlippageToleranceExceeded();
        }

        stakingRealEstateToken.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            erc1155StakingAmount,
            data
        );

        loanedBooks[tokenId][msg.sender] = LoanedInfo({
            erc1155StakingAmount: erc1155StakingAmount,
            usdcLoanedAmount: usdcLoanedAmount,
            usdcLiquidateThresholdAmount: usdcLiquidateThresholdAmount
        });

        usdcToken.safeTransfer(msg.sender, usdcLoanedAmount);

        emit Borrow(
            tokenId,
            erc1155StakingAmount,
            usdcLoanedAmount,
            usdcLiquidateThresholdAmount
        );
    }

    function repay(uint256 tokenId) external nonReentrant {
        LoanedInfo memory info = loanedBooks[tokenId][msg.sender];
        if (info.usdcLoanedAmount == 0) revert NothingToRepay();

        delete loanedBooks[tokenId][msg.sender];

        usdcToken.safeTransferFrom(
            msg.sender,
            address(this),
            info.usdcLoanedAmount
        );

        stakingRealEstateToken.safeTransferFrom(
            address(this),
            msg.sender,
            tokenId,
            info.erc1155StakingAmount,
            ""
        );

        emit BorrowRepayed(tokenId, info.erc1155StakingAmount);
    }

    function liquidate(uint256 tokenId, address borrower) external {
        // 1. 获取贷款信息
        LoanedInfo memory info = loanedBooks[tokenId][borrower];

        // 2. 重新计算已质押(Token)的当前价值(USDC)
        uint256 normalizedValuationInUsdc = (getValuationInUsdc(tokenId) *
            info.erc1155StakingAmount) /
            stakingRealEstateToken.totalSupply(tokenId);
        if (normalizedValuationInUsdc == 0) revert InvalidValuation();

        // 3. 重新计算触发清算阈值(USDC)
        uint256 usdcLiquidateThresholdAmount = (normalizedValuationInUsdc *
            liquidateLoanThresholdRate) / 100;

        // 4. 检查若当前计算的触发清算阈值(USDC)小于(Borrow)时计算的初始阈值, 即资不抵债, 需执行清算(即相当于强制平仓)
        if (usdcLiquidateThresholdAmount < info.usdcLiquidateThresholdAmount) {
            // 5. 移除贷款信息
            delete loanedBooks[tokenId][borrower];

            // TODO: not implemented yet.
            // 6. 将已质押的(Token)转给流动性提供者(而不是平台直接借出的), 以及收益计算???
            //usdcToken.safeTransfer(borrower, info.usdcLoanedAmount);
        }
    }

    function getUsdcPriceInUsd() public view returns (uint256) {
        uint80 _roundId;
        int256 _price;
        uint256 _updatedAt;
        try usdcUsdAggregatorApi.latestRoundData() returns (
            uint80 roundId,
            int256 price,
            uint256,
            /* startedAt */
            uint256 updatedAt,
            uint80 /* answeredInRound */
        ) {
            _roundId = roundId;
            _price = price;
            _updatedAt = updatedAt;
        } catch {
            revert PriceFeedDdosed();
        }

        if (_roundId == 0) revert InvalidRoundId();

        if (_updatedAt < block.timestamp - usdcUsdFeedHeartbeatInterval) {
            revert StalePriceFeed();
        }

        return uint256(_price);
    }

    function getValuationInUsdc(uint256 tokenId) public view returns (uint256) {
        RealEstateToken.PriceDetails
            memory priceDetailsInUsd = stakingRealEstateToken.getPriceDetails(
                tokenId
            );

        uint256 valuationInUsd = (i_weightListPrice *
            priceDetailsInUsd.listPrice +
            i_weightOriginalListPrice *
            priceDetailsInUsd.originalListPrice +
            i_weightTaxAssessedValue *
            priceDetailsInUsd.taxAssessedValue) /
            (i_weightListPrice +
                i_weightOriginalListPrice +
                i_weightTaxAssessedValue);

        uint256 usdcPriceInUsd = getUsdcPriceInUsd();

        uint256 feedDecimals = usdcUsdAggregatorApi.decimals();
        uint256 usdcDecimals = 6; // USDC uses 6 decimals

        uint256 normalizedValuationInUsdc = Math.mulDiv(
            (valuationInUsd * usdcPriceInUsd),
            10 ** usdcDecimals,
            10 ** feedDecimals
        ); // Adjust the valuation from USD (Chainlink 1e8) to USDC (1e6)

        return normalizedValuationInUsdc;
    }

    function setUsdcUsdPriceFeedDetails(
        address usdcUsdAggregatorAddress,
        uint32 usdcUsdFeedHeartbeat
    ) external onlyOwner {
        usdcUsdAggregatorApi = AggregatorV3Interface(usdcUsdAggregatorAddress);
        usdcUsdFeedHeartbeatInterval = usdcUsdFeedHeartbeat;
    }

    function onERC1155Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*id*/,
        uint256 /*value*/,
        bytes calldata /*data*/
    ) external view returns (bytes4) {
        if (msg.sender != address(stakingRealEstateToken)) {
            revert OnlyRealEstateTokenSupported();
        }

        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address /*operator*/,
        address /*from*/,
        uint256[] calldata /*ids*/,
        uint256[] calldata /*values*/,
        bytes calldata /*data*/
    ) external view returns (bytes4) {
        if (msg.sender != address(stakingRealEstateToken)) {
            revert OnlyRealEstateTokenSupported();
        }

        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155Receiver).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
