// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {RealEstatePriceOracle} from "../onchain/RealEstatePriceOracle.sol";
import {ILKToken} from "./ILKToken.sol";

/// @title LKToken
/// @notice 仅供 RWALinker 合约铸造和燃烧的 ERC‑20
contract LKToken is ERC20, Ownable, ILKToken {
    error PriceFeedDdosed();
    error InvalidRoundId();
    error StalePriceFeed();
    error OnlyLinker();

    AggregatorV3Interface internal i_usdcUsdAggregatorApi;
    uint256 internal i_usdcUsdFeedHeartbeatInterval;

    RealEstatePriceOracle internal i_rwaPriceOracle;

    address internal i_linkerAddress;

    // 估值精度
    uint256 internal immutable i_valuationDecimals = 1e6;

    modifier onlyLinker() {
        if (msg.sender != i_linkerAddress) revert OnlyLinker();
        _;
    }

    constructor(address _usdcUsdAggregatorAddress, uint256 _usdcUsdFeedHeartbeatInterval, address _priceOracle)
        Ownable(msg.sender)
        ERC20("NFTShare", "NFTShare")
    {
        i_usdcUsdAggregatorApi = AggregatorV3Interface(_usdcUsdAggregatorAddress);
        i_usdcUsdFeedHeartbeatInterval = _usdcUsdFeedHeartbeatInterval;
        i_rwaPriceOracle = RealEstatePriceOracle(_priceOracle);
    }

    // 设置Linker地址
    function setLinkerAddress(address linkerAddress) external onlyOwner {
        i_linkerAddress = linkerAddress;
    }

    // 获取资产的估值，返回价格与数量
    function calcShares(uint256 tokenId) public view virtual override returns (uint256, uint256) {
        uint256 valuationInUsdc = _getValuationInUsdc(tokenId);
        return (i_valuationDecimals, valuationInUsdc);
    }

    // 铸造份额
    function mint(address to, uint256 amount) external override onlyLinker {
        _mint(to, amount);
    }

    // 销毁份额
    function burn(uint256 amount) external onlyLinker {
        _burn(msg.sender, amount);
    }

    // ERC20接口方法的覆盖实现
    function approve(address spender, uint256 amount) public override(ERC20, ILKToken) returns (bool) {
        return super.approve(spender, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override(ERC20, ILKToken) returns (bool) {
        return super.transferFrom(from, to, amount);
    }

    function balanceOf(address account) public view override(ERC20, ILKToken) returns (uint256) {
        return super.balanceOf(account);
    }

    // 计算资产在usdc下面的价格
    function _getValuationInUsdc(uint256 tokenId) internal view returns (uint256) {
        uint256 valuationInUsdc = i_rwaPriceOracle.getValuationInUsdc(tokenId);

        uint256 usdcPriceInUsd = _getUsdcPriceInUsd();

        uint256 feedDecimals = i_usdcUsdAggregatorApi.decimals();
        uint256 usdcDecimals = 6; // USDC uses 6 decimals

        uint256 normalizedValuationInUsdc =
            Math.mulDiv((valuationInUsdc * usdcPriceInUsd), 10 ** usdcDecimals, 10 ** feedDecimals); // Adjust the valuation from USD (Chainlink 1e8) to USDC (1e6)
        return normalizedValuationInUsdc;
    }

    function _getUsdcPriceInUsd() internal view returns (uint256) {
        uint80 _roundId;
        int256 _price;
        uint256 _updatedAt;
        try i_usdcUsdAggregatorApi.latestRoundData() returns (
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
        if (_updatedAt < block.timestamp - i_usdcUsdFeedHeartbeatInterval) revert StalePriceFeed();

        return uint256(_price);
    }

    function setUsdcUsdPriceFeedDetails(address usdcUsdAggregatorAddress) external onlyOwner {
        i_usdcUsdAggregatorApi = AggregatorV3Interface(usdcUsdAggregatorAddress);
    }
}
