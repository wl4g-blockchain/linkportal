// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {OwnerIsCreator} from "@chainlink/contracts/src/v0.8/shared/access/OwnerIsCreator.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// TODO : add pool manager contract, link refer to AAVE pool contracts
contract StandalonePoolManager is OwnerIsCreator, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct PoolInfo {
        uint256 utilizationRate; // Current Utilization Rate (borrows/totalDeposits)
        uint256 baseAPY; // Baseline year APY
        uint256 optimalUtilizationRate; // Best utilizationRate
        uint256 variableRateSlope1; // UtilizationRate <= optimal 时的斜率
        uint256 variableRateSlope2; // UtilizationRate > optimal 时的斜率
        uint256 totalDeposits;
        uint256 totalBorrows;
    }

    struct UserDeposit {
        uint256 amount;
        uint256 lastUpdateTimestamp;
    }

    event PoolCreated(uint256 indexed riskLevel);
    event Deposited(
        address indexed user,
        uint256 indexed riskLevel,
        uint256 amount
    );
    event Withdrawn(
        address indexed user,
        uint256 indexed riskLevel,
        uint256 amount
    );
    event PoolParamsUpdated(uint256 indexed riskLevel);

    error InvalidRiskLevel();
    error InsufficientLiquidity();
    error InvalidAmount();

    // Risk Level => Pool Info
    mapping(uint256 => PoolInfo) public pools;
    // Risk Level => User Address => User Deposit
    mapping(uint256 => mapping(address => UserDeposit)) public userDeposits;

    IERC20 public immutable usdcToken;
    uint256 public constant RISK_LEVELS = 3; // 低、中、高三个风险等级
    uint256 private constant PRECISION = 1e4;

    constructor(address _usdcToken) {
        usdcToken = IERC20(_usdcToken);

        // Initialize the default 3 pools.
        _initializePool(0, 500, 8000, 1000, 3000); // lower risk: 5% based APY
        _initializePool(1, 800, 8500, 1500, 4000); // medium risk: 8% base APY
        _initializePool(2, 1200, 9000, 2000, 5000); // high risk: 12% base APY
    }

    function _initializePool(
        uint256 riskLevel,
        uint256 baseAPY,
        uint256 optimalUtilizationRate,
        uint256 slope1,
        uint256 slope2
    ) private {
        pools[riskLevel] = PoolInfo({
            utilizationRate: 0,
            baseAPY: baseAPY,
            optimalUtilizationRate: optimalUtilizationRate,
            variableRateSlope1: slope1,
            variableRateSlope2: slope2,
            totalDeposits: 0,
            totalBorrows: 0
        });

        emit PoolCreated(riskLevel);
    }

    function deposit(uint256 riskLevel, uint256 amount) external nonReentrant {
        if (riskLevel >= RISK_LEVELS) revert InvalidRiskLevel();
        if (amount == 0) revert InvalidAmount();

        PoolInfo storage pool = pools[riskLevel];
        UserDeposit storage userDeposit = userDeposits[riskLevel][msg.sender];

        // Update user profit
        if (userDeposit.amount > 0) {
            uint256 profit = _calculateProfit(riskLevel, msg.sender);
            userDeposit.amount += profit;
        }

        pool.totalDeposits += amount;
        userDeposit.amount += amount;
        userDeposit.lastUpdateTimestamp = block.timestamp;

        usdcToken.safeTransferFrom(msg.sender, address(this), amount);

        _updateUtilizationRate(riskLevel);
        emit Deposited(msg.sender, riskLevel, amount);
    }

    function withdraw(uint256 riskLevel, uint256 amount) external nonReentrant {
        if (riskLevel >= RISK_LEVELS) revert InvalidRiskLevel();

        UserDeposit storage userDeposit = userDeposits[riskLevel][msg.sender];
        PoolInfo storage pool = pools[riskLevel];

        // 计算并添加收益
        uint256 interest = _calculateProfit(riskLevel, msg.sender);
        userDeposit.amount += interest;

        if (amount > userDeposit.amount) revert InvalidAmount();
        if (amount > pool.totalDeposits - pool.totalBorrows)
            revert InsufficientLiquidity();

        userDeposit.amount -= amount;
        pool.totalDeposits -= amount;
        userDeposit.lastUpdateTimestamp = block.timestamp;

        usdcToken.safeTransfer(msg.sender, amount);

        _updateUtilizationRate(riskLevel);
        emit Withdrawn(msg.sender, riskLevel, amount);
    }

    function _calculateAPY(uint256 riskLevel) public view returns (uint256) {
        PoolInfo memory pool = pools[riskLevel];

        if (pool.utilizationRate <= pool.optimalUtilizationRate) {
            return
                pool.baseAPY +
                (pool.utilizationRate * pool.variableRateSlope1) /
                PRECISION;
        } else {
            uint256 normalRate = pool.baseAPY + pool.variableRateSlope1;
            uint256 excessUtilization = pool.utilizationRate -
                pool.optimalUtilizationRate;
            return
                normalRate +
                (excessUtilization * pool.variableRateSlope2) /
                PRECISION;
        }
    }

    function _calculateProfit(
        uint256 riskLevel,
        address user
    ) internal view returns (uint256) {
        UserDeposit memory userDeposit = userDeposits[riskLevel][user];
        if (userDeposit.amount == 0) return 0;

        uint256 timeElapsed = block.timestamp - userDeposit.lastUpdateTimestamp;
        uint256 apy = _calculateAPY(riskLevel);

        return
            (userDeposit.amount * apy * timeElapsed) / (365 days * PRECISION);
    }

    function _updateUtilizationRate(uint256 riskLevel) internal {
        PoolInfo storage pool = pools[riskLevel];
        if (pool.totalDeposits == 0) {
            pool.utilizationRate = 0;
        } else {
            pool.utilizationRate =
                (pool.totalBorrows * PRECISION) /
                pool.totalDeposits;
        }
    }

    // 仅供 RwaLending 合约调用的接口
    function increaseTotalBorrows(uint256 riskLevel, uint256 amount) external {
        // TODO: 需要限制只允许 RwaLending 合约调用
        PoolInfo storage pool = pools[riskLevel];
        pool.totalBorrows += amount;
        _updateUtilizationRate(riskLevel);
    }

    function decreaseTotalBorrows(uint256 riskLevel, uint256 amount) external {
        // TODO: 需要限制只允许 RwaLending 合约调用
        PoolInfo storage pool = pools[riskLevel];
        pool.totalBorrows -= amount;
        _updateUtilizationRate(riskLevel);
    }

    // 管理员功能
    function updatePoolParams(
        uint256 riskLevel,
        uint256 baseAPY,
        uint256 optimalUtilizationRate,
        uint256 slope1,
        uint256 slope2
    ) external onlyOwner {
        if (riskLevel >= RISK_LEVELS) revert InvalidRiskLevel();

        PoolInfo storage pool = pools[riskLevel];
        pool.baseAPY = baseAPY;
        pool.optimalUtilizationRate = optimalUtilizationRate;
        pool.variableRateSlope1 = slope1;
        pool.variableRateSlope2 = slope2;

        emit PoolParamsUpdated(riskLevel);
    }
}
