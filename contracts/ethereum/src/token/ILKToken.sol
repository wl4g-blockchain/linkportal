// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ILKToken
 * @notice LKToken接口，定义RealEstateLinker需要的所有方法
 */
interface ILKToken {
    function mint(address to, uint256 amount) external;
    function calcShares(uint256 tokenId) external view returns (uint256 shares, uint256 valuationInUsdc);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
