// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {RealEstateToken} from "../src/core/RealEstateToken.sol";
import {Issuer} from "../src/core/Issuer.sol";

/**
 * @title DeployRealEstateScript
 * @dev A script to deploy RealEstateToken and Issuer contracts on the Sepolia network.
 */
contract DeployRealEstateScript is Script {
    // Sepolia network configuration
    // see: https://docs.chain.link/ccip/directory/testnet/chain/ethereum-testnet-sepolia
    address constant LINK_TOKEN_SEPOLIA =
        0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address constant CCIP_ROUTER_SEPOLIA =
        0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    uint64 constant CHAIN_SELECTOR_SEPOLIA = 16015286601757825753;
    // see: https://docs.chain.link/chainlink-functions/supported-networks#sepolia-testnet
    address constant FUNCTIONS_ROUTER_SEPOLIA =
        0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;

    function setUp() public {}

    function run() external {
        // Read deployment wallet private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy RealEstateToken
        string memory baseTokenUri = "https://your-api.com/metadata/"; // TODO e.g: https://token-cdn-domain/{id}.json
        RealEstateToken realEstateToken = new RealEstateToken(
            baseTokenUri,
            CCIP_ROUTER_SEPOLIA,
            LINK_TOKEN_SEPOLIA,
            CHAIN_SELECTOR_SEPOLIA,
            FUNCTIONS_ROUTER_SEPOLIA
        );
        console.log("RealEstateToken deployed at:", address(realEstateToken));

        // 2. Deploy Issuer
        Issuer issuer = new Issuer(
            address(realEstateToken),
            FUNCTIONS_ROUTER_SEPOLIA
        );
        console.log("Issuer deployed at:", address(issuer));

        // 3. Configure contracts
        // Set issuer in RealEstateToken
        realEstateToken.setIssuer(address(issuer));
        console.log("Issuer set in RealEstateToken");

        // Optional: Enable cross-chain functionality for specific chains
        // Example for enabling Mumbai testnet
        // bytes memory ccipExtraArgs = "";
        // realEstateToken.enableChain(
        //     MUMBAI_CHAIN_SELECTOR,
        //     MUMBAI_NFT_ADDRESS,
        //     ccipExtraArgs
        // );

        vm.stopBroadcast();

        // Log deployment summary
        console.log("\nDeployment Summary:");
        console.log("==================");
        console.log("Network: Sepolia");
        console.log("RealEstateToken:", address(realEstateToken));
        console.log("Issuer:", address(issuer));
        console.log("CCIP Router:", CCIP_ROUTER_SEPOLIA);
        console.log("LINK Token:", LINK_TOKEN_SEPOLIA);
        console.log("Functions Router:", FUNCTIONS_ROUTER_SEPOLIA);
    }
}
