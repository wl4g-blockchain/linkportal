// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.24;

import {AaveUniswapBase} from "./AaveUniswapBase.sol";
import {IUniswapV3Factory} from "./interfaces/uniswap-v3/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "./interfaces/uniswap-v3/IUniswapV3Pool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPool} from "./interfaces/aave-v3/IPool.sol";
import {ISwapRouter} from "./interfaces/uniswap-v3/ISwapRouter.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {console2} from "forge-std/console2.sol";

contract AaveApe is AaveUniswapBase {
    error BorrowAmountNotEnough();
    error RepayAmountNotEnough();
    error NotLendingPool();
    error NotSelf();

    event Ape(
        address ape,
        string action,
        address apeAsset,
        address borrowAsset,
        uint256 borrowAmount,
        uint256 apeAmount,
        uint256 interestRateMode
    );

    IUniswapV3Factory public constant factory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

    uint24[4] public v3Fees = [100, 500, 3000, 10000];

    constructor(address _poolAddressesProvider, address _swapRouter)
        AaveUniswapBase(_poolAddressesProvider, _swapRouter)
    {}

    // 借用资产，通过uniswap对换成 apeAddress，抵押到aave中
    function ape(address apeAddress, address borrowAsset, uint256 interestRateMode) public returns (bool) {
        // 获取用户当前的最大借款
        uint256 borrowAmount = getAvailableBorrowInAsset(msg.sender, borrowAsset);
        if (borrowAmount <= 0) revert BorrowAmountNotEnough();

        console2.log("borrowAsset", borrowAsset);
        console2.log("borrowAmount", borrowAmount);

        IPool lendingPool = LENDING_POOL();
        // 借款
        lendingPool.borrow(borrowAsset, borrowAmount, interestRateMode, 0, msg.sender);

        // 授予 Uniswap V3 交换权限
        IERC20(borrowAsset).approve(UNISWAP_ROUTER_ADDRESS, borrowAmount);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: borrowAsset,
            tokenOut: apeAddress,
            fee: getBestPool(borrowAsset, apeAddress).fee(),
            recipient: address(this),
            deadline: block.timestamp + 50,
            amountIn: borrowAmount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        uint256 amountOut = ISwapRouter(UNISWAP_ROUTER_ADDRESS).exactInputSingle(params);

        IERC20(apeAddress).approve(POOL_ADDRESSES_PROVIDER.getPool(), amountOut);

        LENDING_POOL().supply(apeAddress, amountOut, msg.sender, 0);
        emit Ape(msg.sender, "open", apeAddress, borrowAsset, borrowAmount, amountOut, interestRateMode);
        return true;
    }

    // 多级借贷
    function leverageApe(address apeAddress, address borrowAsset, uint256 interestRateMode, uint256 levels)
        public
        returns (bool)
    {
        for (uint256 i = 0; i < levels; i++) {
            ape(apeAddress, borrowAsset, interestRateMode);
        }
        return true;
    }

    // 还款
    function repay(address apeAddress, address borrowAsset, uint256 interestRateMode) public returns (bool) {
        (, uint256 currentStableDebt, uint256 currentVariableDebt,,,,,,) =
            getProtocolDataProvider().getUserReserveData(borrowAsset, msg.sender);

        uint256 repayAmount = 0;
        if (interestRateMode == 1) {
            repayAmount = currentStableDebt;
        } else {
            repayAmount = currentVariableDebt;
        }

        if (repayAmount <= 0) revert RepayAmountNotEnough();

        address receiverAddress = address(this);
        address[] memory assets = new address[](1);
        assets[0] = borrowAsset;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = repayAmount;
        uint256[] memory interestRateModes = new uint256[](1);
        interestRateModes[0] = 0;

        address onBehalfOf = address(this);
        uint16 referralCode = 0;

        bytes memory params = abi.encode(msg.sender, apeAddress, interestRateMode);

        LENDING_POOL().flashLoan(receiverAddress, assets, amounts, interestRateModes, onBehalfOf, params, referralCode);

        return true;
    }

    // 在回调中还款
    function executeOperation(
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        if (msg.sender != address(LENDING_POOL())) revert NotLendingPool();
        if (initiator != address(this)) revert NotSelf();

        address borrowAsset = assets[0];
        uint256 repayAmount = amounts[0];
        // 闪电贷无利率
        uint256 amountOwing = repayAmount + premiums[0];

        (address user, address apeAddress, uint256 interestRateMode) = abi.decode(params, (address, address, uint256));

        return closePosition(user, apeAddress, borrowAsset, repayAmount, amountOwing, interestRateMode);
    }

    function closePosition(
        address user,
        address apeAddress,
        address borrowAsset,
        uint256 repayAmount,
        uint256 amountOwing,
        uint256 interestRateMode
    ) internal returns (bool) {
        // 还款
        IPool lendingPool = LENDING_POOL();

        address poolAddress = POOL_ADDRESSES_PROVIDER.getPool();
        IERC20(apeAddress).approve(poolAddress, repayAmount);

        lendingPool.repay(borrowAsset, repayAmount, interestRateMode, user);

        // 获取用户可借资产的数量
        uint256 _maxAvailableBorrow = getAvailableBorrowInAsset(user, apeAddress);
        DataTypes.ReserveData memory reserveData = getAaveAssetReserveData(apeAddress);
        IERC20 _aToken = IERC20(reserveData.aTokenAddress);

        // 如果用户可借资产数量小于最大可借资产数量，则将最大可借资产数量设置为可借资产数量
        if (_aToken.balanceOf(user) < _maxAvailableBorrow) {
            _maxAvailableBorrow = _aToken.balanceOf(user);
        }

        // 通过uniswap来计算需要的apeAddress的数量
        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
            tokenIn: apeAddress,
            tokenOut: borrowAsset,
            fee: getBestPool(borrowAsset, apeAddress).fee(),
            recipient: address(this),
            deadline: block.timestamp + 5,
            amountOut: amountOwing,
            amountInMaximum: _maxAvailableBorrow,
            sqrtPriceLimitX96: 0
        });

        // 计算是否多偿还了
        uint256 needAmountIn = ISwapRouter(UNISWAP_ROUTER_ADDRESS).exactOutputSingle(params);
        if (needAmountIn <= _maxAvailableBorrow) {
            _maxAvailableBorrow = needAmountIn;
        }

        // 赎回 apeAddress
        _aToken.transferFrom(user, address(this), _maxAvailableBorrow);
        lendingPool.withdraw(apeAddress, _maxAvailableBorrow, address(this));

        IERC20(apeAddress).approve(poolAddress, amountOwing);

        emit Ape(user, "close", apeAddress, borrowAsset, repayAmount, _maxAvailableBorrow, interestRateMode);
        return true;
    }

    function getAvailableBorrowInAsset(address user, address borrowAsset) public view returns (uint256) {
        (,, uint256 availableBorrowsETH,,,) = LENDING_POOL().getUserAccountData(user);
        return getAssetAmount(availableBorrowsETH, borrowAsset);
    }

    function getAssetAmount(uint256 amountInETH, address targetAsset) public view returns (uint256) {
        uint256 targetAssetPrice = getPriceOracle().getAssetPrice(targetAsset);
        (uint256 decimals,,,,,,,,,) = getProtocolDataProvider().getReserveConfigurationData(targetAsset);
        // 正确计算借款资产金额
        uint256 amount = (amountInETH * 10 ** decimals) / targetAssetPrice / 5;
        return amount;
    }

    function getBestPool(address tokenA, address tokenB) public view returns (IUniswapV3Pool bestPool) {
        uint256 maxLiquidity = 0;

        for (uint256 i = 0; i < v3Fees.length; i++) {
            address pool = factory.getPool(tokenA, tokenB, v3Fees[i]);
            if (pool == address(0)) continue;
            uint256 liquidity = IUniswapV3Pool(pool).liquidity();
            if (liquidity > maxLiquidity) {
                maxLiquidity = liquidity;
                bestPool = IUniswapV3Pool(pool);
            }
        }
    }
}
