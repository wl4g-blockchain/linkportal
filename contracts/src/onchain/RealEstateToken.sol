// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {CrossChainBurnAndMintERC1155} from "./CrossChainBurnAndMintERC1155.sol";
import {RealEstatePriceDetails} from "./RealEstatePriceDetails.sol";

/**
 * @title RealEstateToken
 * @author James Wong
 * @notice RealEstateToken is a cross-chain ERC1155 token that supports burn and mint operations.
 */
contract RealEstateToken is
    CrossChainBurnAndMintERC1155,
    RealEstatePriceDetails
{
    constructor(
        string memory uri,
        address ccipRouterAddress,
        address linkTokenAddress,
        uint64 currentChainSelector,
        address functionsRouterAddress
    )
        CrossChainBurnAndMintERC1155(
            uri,
            ccipRouterAddress,
            linkTokenAddress,
            currentChainSelector
        )
        RealEstatePriceDetails(functionsRouterAddress)
    {}
}
