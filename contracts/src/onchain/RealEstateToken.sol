// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {CrossChainBurnAndMintERC1155} from "./CrossChainBurnAndMintERC1155.sol";
import {RealEstatePriceDetails} from "./RealEstatePriceDetails.sol";

contract RealEstateToken is
    CrossChainBurnAndMintERC1155,
    RealEstatePriceDetails
{
    /**
     *
     *  ██████╗ ███████╗ █████╗ ██╗         ███████╗███████╗████████╗ █████╗ ████████╗███████╗    ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗
     *  ██╔══██╗██╔════╝██╔══██╗██║         ██╔════╝██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝    ╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║
     *  ██████╔╝█████╗  ███████║██║         █████╗  ███████╗   ██║   ███████║   ██║   █████╗         ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║
     *  ██╔══██╗██╔══╝  ██╔══██║██║         ██╔══╝  ╚════██║   ██║   ██╔══██║   ██║   ██╔══╝         ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║
     *  ██║  ██║███████╗██║  ██║███████╗    ███████╗███████║   ██║   ██║  ██║   ██║   ███████╗       ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║
     *  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝    ╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝       ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝
     *
     */
    constructor(
        string memory uri_,
        address ccipRouterAddress,
        address linkTokenAddress,
        uint64 currentChainSelector,
        address functionsRouterAddress
    )
        CrossChainBurnAndMintERC1155(
            uri_,
            ccipRouterAddress,
            linkTokenAddress,
            currentChainSelector
        )
        RealEstatePriceDetails(functionsRouterAddress)
    {}
}
