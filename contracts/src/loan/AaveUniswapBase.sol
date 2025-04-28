// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IPoolAddressesProvider} from "./interfaces/aave-v3/IPoolAddressesProvider.sol";
import {IPriceOracleGetter} from "./interfaces/aave-v3/IPriceOracleGetter.sol";
import {ISwapRouter} from "./interfaces/uniswap-v3/ISwapRouter.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {IPoolDataProvider} from "./interfaces/aave-v3/IPoolDataProvider.sol";
import {IPool} from "./interfaces/aave-v3/IPool.sol";

contract AaveUniswapBase {
    IPoolAddressesProvider public immutable POOL_ADDRESSES_PROVIDER;
    ISwapRouter public immutable SWAP_ROUTER;
    address public immutable UNISWAP_ROUTER_ADDRESS;

    constructor(address _poolAddressesProvider, address _swapRouter) {
        POOL_ADDRESSES_PROVIDER = IPoolAddressesProvider(_poolAddressesProvider);
        SWAP_ROUTER = ISwapRouter(_swapRouter);
        UNISWAP_ROUTER_ADDRESS = _swapRouter;
    }

    // Get the lending pool
    function LENDING_POOL() public view returns (IPool) {
        return IPool(POOL_ADDRESSES_PROVIDER.getPool());
    }

    // Get the price oracle
    function getPriceOracle() public view returns (IPriceOracleGetter) {
        return IPriceOracleGetter(POOL_ADDRESSES_PROVIDER.getPriceOracle());
    }

    // Get the protocol data provider
    function getProtocolDataProvider() public view returns (IPoolDataProvider) {
        return IPoolDataProvider(POOL_ADDRESSES_PROVIDER.getPoolDataProvider());
    }

    // Get the reserve data for an asset
    function getAaveAssetReserveData(address asset) public view returns (DataTypes.ReserveData memory) {
        return LENDING_POOL().getReserveData(asset);
    }
}
