// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";

import {RealEstateLinker} from "../src/onchain/RealEstateLinker.sol";
import {LKToken} from "../src/token/LKToken.sol";
import {RealEstateToken} from "../src/onchain/RealEstateToken.sol";
import {RealEstateIssuer} from "../src/onchain/RealEstateIssuer.sol";
import {RealEstatePriceOracle} from "../src/onchain/RealEstatePriceOracle.sol";
import {RealEstateKYC} from "../src/onchain/RealEstateKYC.sol";
import {MockERC1155} from "./MockERC1155.sol";

contract MockLKToken is LKToken {
    uint256 private s_valuationDecimals = 1e6;
    uint256 private s_valuation = 1e8;

    constructor(address _usdcUsdAggregatorAddress, uint256 _usdcUsdFeedHeartbeatInterval, address _priceOracle)
        LKToken(_usdcUsdAggregatorAddress, _usdcUsdFeedHeartbeatInterval, _priceOracle)
    {}

    function setDecimalAndValuation(uint256 i_valuationDecimals, uint256 i_valuation) public {
        s_valuationDecimals = i_valuationDecimals;
        s_valuation = i_valuation;
    }

    function calcShares(uint256 tokenId) public view virtual override returns (uint256, uint256) {
        return (s_valuationDecimals, s_valuation);
    }
}

contract RWAWorkFlowTest is Test {
    RealEstateKYC internal realEstateKYC;
    RealEstateToken internal realEstateToken;
    LKToken internal lkToken;
    RealEstatePriceOracle internal realEstatePriceOracle;
    RealEstateIssuer internal realEstateIssuer;
    RealEstateLinker internal realEstateLinker;
    MockERC1155 internal mockERC1155;

    // test addresses
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address user4 = makeAddr("user4");
    address user5 = makeAddr("user5");
    address verifier = makeAddr("verifier");
    // mock address for external contract
    address mockFunctionsRouter = makeAddr("mockFunctionsRouter");
    address mockUniversalKYC = makeAddr("mockUniversalKYC");
    address mockNFTToken = makeAddr("mockNFTToken");
    address mockRWAPriceOracle = makeAddr("mockRWAPriceOracle");
    address mockCcipRouter = makeAddr("mockCcipRouter");
    address mockLinkToken = makeAddr("mockLinkToken");
    address mockUsdcUsdAggregator = makeAddr("mockUsdcUsdAggregator");
    // mock data
    uint64 mockChainSelector = 1;
    uint256 mockUsdcUsdHeartbeat = 1 hours;
    bytes32 mockRequestId = bytes32("requestId");
    uint256 mockTokenId = 1;
    string mockTokenURI = "ipfs://QmTokenURI";
    string mockEvaluateScript = "return { source: 'chainlinkFunction' }";
    string mockRequestUrl =
        "https://api.bridgedataoutput.com/api/v2/OData/test/Property('P_5dba1fb94aa4055b9f29696f')?access_token=6baca547742c6f96a6ff71b138424f21";
    string mockNftMetadataScript = "return { metadata: 'nftData' }";

    function setUp() public {
        // deploy kyc
        realEstateKYC = new RealEstateKYC();

        // deploy price oracle
        realEstatePriceOracle = new RealEstatePriceOracle(mockFunctionsRouter, mockEvaluateScript, mockRequestUrl);

        // deploy nft token
        realEstateToken = new RealEstateToken(
            "https://token-uri.com/", mockCcipRouter, mockLinkToken, mockChainSelector, mockFunctionsRouter
        );

        // deploy issue
        realEstateIssuer = new RealEstateIssuer(
            address(realEstateToken),
            address(mockFunctionsRouter),
            address(realEstateKYC),
            mockNftMetadataScript,
            mockRequestUrl
        );

        // deploy real estate linker
        realEstateLinker = new RealEstateLinker(address(lkToken));

        // deploy mock ERC1155 token
        mockERC1155 = new MockERC1155();
    }

    function testFullRWAWorkFlow() public {
        // 1. verify user
        realEstateKYC.addVerifier(verifier);
        // 2. 部署自定义LK代币；部署Linker合约
        vm.startPrank(user2);
        MockLKToken mockLKToken =
            new MockLKToken(address(mockUsdcUsdAggregator), mockUsdcUsdHeartbeat, address(realEstatePriceOracle));
        RealEstateLinker rwaLinker = new RealEstateLinker(address(mockLKToken));
        mockLKToken.setLinkerAddress(address(rwaLinker));
        vm.stopPrank();
        mockLKToken.setDecimalAndValuation(1e6, 1e8);

        // 3. 部署MockERC1155并铸造代币给用户
        MockERC1155 erc1155Token = new MockERC1155();
        vm.startPrank(address(this));
        erc1155Token.mint(user, mockTokenId, 1, "");
        vm.stopPrank();

        // 5. 用户存入ERC1155
        vm.startPrank(user);
        // 首先授权Linker合约操作代币
        erc1155Token.setApprovalForAll(address(rwaLinker), true);
        // 存入代币
        rwaLinker.depositERC1155(address(erc1155Token), mockTokenId);
        vm.stopPrank();

        // 6. 验证借款余额
        assertEq(mockLKToken.balanceOf(user), 1e8 * 60 / 100);
    }

    function verifyUser() internal view {
        assert(realEstateKYC.isUserVerified(verifier));
    }
}
