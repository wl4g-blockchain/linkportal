// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {RealEstateToken} from "./RealEstateToken.sol";
import {OwnerIsCreator} from "@chainlink/contracts/src/v0.8/shared/access/OwnerIsCreator.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {RealEstateKYC} from "./RealEstateKYC.sol";

/**
 * @title RealEstateIssuer
 * @author James Wong
 * @notice Issuer contract for fractionalizing RWA NFTs.
 */
    contract RealEstateIssuer is FunctionsClient, OwnerIsCreator {
    using FunctionsRequest for FunctionsRequest.Request;

    error LatestIssueInProgress();

    enum IssuStatus {
        Pending,
        Approved,
        Rejected
    }

    struct FractionalizedNft {
        address to;
        uint256 amount;
        IssuStatus status;
        uint256 tokenId;
        string tokenURI;
    }

    // KYC验证
    RealEstateKYC internal immutable i_realEstateKYC;
    // 资产
    RealEstateToken internal immutable i_realEstateToken;
    // 请求ID
    bytes32 internal s_lastRequestId;
    // 下一个tokenID
    uint256 private s_nextTokenId;

    string private s_nftMetadataScript;

    string private s_requestUrl;

    // 请求ID => 请求
    mapping(bytes32 requestId => FractionalizedNft) internal s_issuesInProgress;

    event IssueRequested(bytes32 indexed requestId, address indexed to, uint256 amount);
    event IssueApproved(bytes32 indexed requestId, address indexed to, uint256 status);

    // 只允许KYC验证的用户
    modifier onlyKYCVerified() {
        require(i_realEstateKYC.isUserVerified(msg.sender), "Not KYC verified");
        _;
    }

    constructor(
        address _realEstateToken,
        address _functionsRouterAddress,
        address _realEstateKYC,
        string memory _nftMetadataScript,
        string memory _requestUrl
    ) FunctionsClient(_functionsRouterAddress) {
        i_realEstateToken = RealEstateToken(_realEstateToken);
        i_realEstateKYC = RealEstateKYC(_realEstateKYC);
        s_nftMetadataScript = _nftMetadataScript;
        s_requestUrl = _requestUrl;
    }

    // 请求发布
    function requestIssue(uint256 amount, uint64 subscriptionId, uint32 gasLimit, bytes32 donID)
        external
        onlyKYCVerified
        returns (bytes32 requestId)
    {
        if (s_issuesInProgress[requestId].status == IssuStatus.Pending) revert LatestIssueInProgress();

        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(s_nftMetadataScript);
        string[] memory args = new string[](1);
        args[0] = s_requestUrl;
        req.setArgs(args);
        requestId = _sendRequest(req.encodeCBOR(), subscriptionId, gasLimit, donID);

        s_issuesInProgress[requestId] = FractionalizedNft(msg.sender, amount, IssuStatus.Pending, 0, "");
        emit IssueRequested(requestId, msg.sender, amount);
    }

    // 批准发布
    function approveIssue(bytes32 requestId, uint256 status) external onlyOwner {
        require(status == uint256(IssuStatus.Approved) || status == uint256(IssuStatus.Rejected), "Invalid status");
        require(s_issuesInProgress[requestId].status == IssuStatus.Pending, "Request not pending");

        FractionalizedNft storage fracNft = s_issuesInProgress[requestId];
        if (status == uint256(IssuStatus.Approved)) {
            fracNft.status = IssuStatus.Approved;
            i_realEstateToken.mint(fracNft.to, fracNft.tokenId, fracNft.amount, "", fracNft.tokenURI);
        } else {
            fracNft.status = IssuStatus.Rejected;
        }
        emit IssueApproved(requestId, fracNft.to, status);
    }

    function setNftMetadataScript(string memory _nftMetadataScript) external onlyOwner {
        s_nftMetadataScript = _nftMetadataScript;
    }

    // 回填url
    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (err.length != 0) {
            revert(string(err));
        }
        if (s_lastRequestId == requestId) {
            string memory tokenURI = string(response);
            uint256 tokenId = s_nextTokenId++;
            FractionalizedNft memory fracNft = s_issuesInProgress[requestId];

            if (s_issuesInProgress[requestId].status == IssuStatus.Pending) {
                s_issuesInProgress[requestId] =
                    FractionalizedNft(fracNft.to, fracNft.amount, IssuStatus.Pending, tokenId, tokenURI);
            }
        }
    }
}
