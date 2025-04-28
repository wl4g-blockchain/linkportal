// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ILKLendingPool
 * @notice LKLendingPool接口定义，提供RealEstateLinker和其他合约与借贷池交互的方法
 */
interface ILKLendingPool {
    /**
     * @notice 存入LKToken作为抵押品
     * @param amount LKToken数量
     */
    function depositCollateral(uint256 amount) external;

    /**
     * @notice 提取LKToken抵押品
     * @param amount 提取金额
     */
    function withdrawCollateral(uint256 amount) external;

    /**
     * @notice 借出稳定币
     * @param stablecoin 稳定币地址
     * @param amount 借款金额
     */
    function borrowStablecoin(address stablecoin, uint256 amount) external;

    /**
     * @notice 偿还借款
     * @param stablecoin 稳定币地址
     * @param amount 偿还金额
     */
    function repayLoan(address stablecoin, uint256 amount) external;

    /**
     * @notice 获取用户账户数据
     * @param user 用户地址
     * @return totalCollateralValue 总抵押品价值
     * @return totalDebtValue 总债务价值
     * @return availableBorrowsValue 可用借款额度
     * @return currentLiquidationThreshold 当前清算阈值
     * @return healthFactor 健康因子
     */
    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralValue,
            uint256 totalDebtValue,
            uint256 availableBorrowsValue,
            uint256 currentLiquidationThreshold,
            uint256 healthFactor
        );

    /**
     * @notice 获取稳定币池信息
     * @param stablecoin 稳定币地址
     * @return isSupported 是否支持
     * @return totalSupply 总供应量
     * @return totalBorrowed 总借出量
     * @return availableLiquidity 可用流动性
     * @return utilizationRate 使用率
     * @return interestRate 利率
     */
    function getStablecoinPoolData(address stablecoin)
        external
        view
        returns (
            bool isSupported,
            uint256 totalSupply,
            uint256 totalBorrowed,
            uint256 availableLiquidity,
            uint256 utilizationRate,
            uint256 interestRate
        );
}
