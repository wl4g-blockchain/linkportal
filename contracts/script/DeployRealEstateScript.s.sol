// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {RealEstateToken} from "../src/onchain/RealEstateToken.sol";
import {RealEstateIssuer} from "../src/onchain/RealEstateIssuer.sol";
import {NetworkConfig} from "./config/NetworkConfig.s.sol";

/*
 * @title DeployRealEstateScript
 * @dev This script deploys the RealEstateToken and Issuer contracts on the specified network.
 */
contract DeployRealEstateScript is Script {
    error InvalidNetwork();

    function setUp() public {}

    function run() external {
        // Get current network configuration
        uint256 chainId;
        try vm.envUint("CHAIN_ID") returns (uint256 _chainId) {
            chainId = _chainId;
        } catch {
            revert InvalidNetwork();
        }

        NetworkConfig.NetworkInfo memory network = NetworkConfig
            .getNetworkConfig(chainId);

        // Log pre-deployment information
        console.log("\nDeploying to network:", network.name);
        console.log("Chain ID:", network.chainId);
        console.log("CCIP Router:", network.ccipRouter);
        console.log("LINK Token:", network.linkToken);
        console.log("Functions Router:", network.functionsRouter);

        // Start deployment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        try this.deploy(network) returns (
            address tokenAddress,
            address issuerAddress
        ) {
            // Log deployment results
            console.log("\nDeployment successful!");
            console.log("==================");
            console.log("RealEstateToken:", tokenAddress);
            console.log("Issuer:", issuerAddress);
        } catch Error(string memory reason) {
            console.log("\nDeployment failed!");
            console.log("Reason:", reason);
            vm.stopBroadcast();
            revert(reason);
        }

        vm.stopBroadcast();
    }

    function deploy(
        NetworkConfig.NetworkInfo memory network
    ) external returns (address tokenAddress, address issuerAddress) {
        // Deploy RealEstateToken
        string memory baseTokenUri = vm.envString("BASE_TOKEN_URI");
        RealEstateToken realEstateToken = new RealEstateToken(
            baseTokenUri,
            network.ccipRouter,
            network.linkToken,
            network.chainSelector,
            network.functionsRouter
        );

        // Deploy RealEstateIssuer
        RealEstateIssuer issuer = new RealEstateIssuer(
            address(realEstateToken),
            network.functionsRouter
        );

        // Configure contracts
        realEstateToken.setIssuer(address(issuer));

        return (address(realEstateToken), address(issuer));
    }
}
