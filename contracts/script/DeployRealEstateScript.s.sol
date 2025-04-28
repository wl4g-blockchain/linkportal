// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {NetworkConfig} from "./config/NetworkConfig.s.sol";
import {RealEstateToken} from "../src/onchain/RealEstateToken.sol";
import {RealEstateIssuer} from "../src/onchain/RealEstateIssuer.sol";
import {RealEstateKYC} from "../src/onchain/RealEstateKYC.sol";
import {RealEstateLinker} from "../src/onchain/RealEstateLinker.sol";
import {LKToken} from "../src/token/LKToken.sol";
import {RealEstatePriceOracle} from "../src/onchain/RealEstatePriceOracle.sol";
import {LKLendingPool} from "../src/loan/LKLendingPool.sol";
/*
 * @title DeployRealEstateScript
 * @dev This script deploys the RealEstateToken and Issuer contracts on the specified network.
 */

contract DeployRealEstateScript is Script {
    error InvalidNetwork();

    function setUp() public {}

    struct DeployResult {
        address realEstateKYC;
        address realEstateToken;
        address issuer;
        address realEstatePriceOracle;
        address lkToken;
        address realEstateLinker;
        address lkLendingPool;
    }

    function run() external returns (DeployResult memory result) {
        // Get current network configuration
        uint256 chainId;
        try vm.envUint("CHAIN_ID") returns (uint256 _chainId) {
            chainId = _chainId;
        } catch {
            revert InvalidNetwork();
        }

        NetworkConfig.NetworkInfo memory network = NetworkConfig.getNetworkConfig(chainId);

        // Log pre-deployment information
        console.log("\nDeploying to network:", network.name);
        console.log("Chain ID:", network.chainId);
        console.log("CCIP Router:", network.ccipRouter);
        console.log("LINK Token:", network.linkToken);
        console.log("Functions Router:", network.functionsRouter);

        // Start deployment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        result = deploy(network);
        // Log deployment results
        console.log("\nDeployment successful!");
        console.log("==================");
        console.log("RealEstateKYC:", result.realEstateKYC);
        console.log("RealEstateToken:", result.realEstateToken);
        console.log("Issuer:", result.issuer);
        console.log("RealEstatePriceOracle:", result.realEstatePriceOracle);
        console.log("LKToken:", result.lkToken);
        console.log("RealEstateLinker:", result.realEstateLinker);
        console.log("LKLendingPool:", result.lkLendingPool);
        vm.stopBroadcast();
    }

    function deploy(NetworkConfig.NetworkInfo memory network) private returns (DeployResult memory result) {
        // ================================================ ON CHAIN CONTRACTS ================================================
        // Deploy RealEstateKYC
        RealEstateKYC realEstateKYC = new RealEstateKYC();

        // Deploy RealEstateToken
        string memory baseTokenUri = vm.envString("BASE_TOKEN_URI");
        RealEstateToken realEstateToken = new RealEstateToken(
            baseTokenUri, network.ccipRouter, network.linkToken, network.chainSelector, network.functionsRouter
        );

        // Deploy RealEstateIssuer
        string memory metadataScript = vm.readFile("./script/functions/metadata.min.js");
        string memory metaURL =
            "https://api.bridgedataoutput.com/api/v2/OData/test/Property('P_5dba1fb94aa4055b9f29696f')?access_token=6baca547742c6f96a6ff71b138424f21";
        RealEstateIssuer issuer = new RealEstateIssuer(
            address(realEstateToken), network.functionsRouter, address(realEstateKYC), metadataScript, metaURL
        );

        // set issuer address
        realEstateToken.setIssuer(address(issuer));

        // Deploy RealEstatePriceOracle
        string memory priceScript = vm.readFile("./script/functions/rwaPrice.min.js");
        string memory priceURL =
            "https://api.bridgedataoutput.com/api/v2/OData/test/Property('P_5dba1fb94aa4055b9f29696f')?access_token=6baca547742c6f96a6ff71b138424f21";
        RealEstatePriceOracle realEstatePriceOracle =
            new RealEstatePriceOracle(network.functionsRouter, priceScript, priceURL);

        // Deploy LKToken
        LKToken lkToken =
            new LKToken(network.usdcUsdAggregator, network.usdcUsdFeedHeartbeatInterval, address(realEstatePriceOracle));

        // Deploy RealEstateLinker
        RealEstateLinker realEstateLinker = new RealEstateLinker(address(lkToken));

        // set linker address
        lkToken.setLinkerAddress(address(realEstateLinker));

        // ================================================ POOL ADDRESS ================================================

        // Deploy LKLendingPool
        LKLendingPool lkLendingPool = new LKLendingPool(address(lkToken));

        // ================================================ RESULT ================================================

        return DeployResult({
            realEstateKYC: address(realEstateKYC),
            realEstateToken: address(realEstateToken),
            issuer: address(issuer),
            realEstatePriceOracle: address(realEstatePriceOracle),
            lkToken: address(lkToken),
            realEstateLinker: address(realEstateLinker),
            lkLendingPool: address(lkLendingPool)
        });
    }
}
