// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {OwnerIsCreator} from "@chainlink/contracts/src/v0.8/shared/access/OwnerIsCreator.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

/**
 * @title RealEstatePriceDetails
 * @author James Wong
 * @notice This contract is used to get the price details of a real estate property.
 */
contract RealEstatePriceOracle is FunctionsClient, OwnerIsCreator {
    using FunctionsRequest for FunctionsRequest.Request;

    address internal s_automationForwarderAddress;

    // 估值(USDC)
    mapping(uint256 => uint256) internal s_valuationInUsdc;

    // 估值(USD)
    string private s_priceScript;

    string private s_requestUrl;

    error OnlyAutomationForwarderOrOwnerCanCall();

    modifier onlyAutomationForwarderOrOwner() {
        if (msg.sender != s_automationForwarderAddress && msg.sender != owner()) {
            revert OnlyAutomationForwarderOrOwnerCanCall();
        }
        _;
    }

    constructor(address functionsRouterAddress, string memory priceScript, string memory requestUrl) FunctionsClient(functionsRouterAddress) {
        s_priceScript = priceScript;
        s_requestUrl = requestUrl;
    }

    function setAutomationForwarder(address automationForwarderAddress) external onlyOwner {
        s_automationForwarderAddress = automationForwarderAddress;
    }

    function updatePriceDetails(string memory tokenId, uint64 subscriptionId, uint32 gasLimit, bytes32 donID)
        external
        onlyAutomationForwarderOrOwner
        returns (bytes32 requestId)
    {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(s_priceScript);
        string[] memory args = new string[](1);
        args[0] = tokenId;
        req.setArgs(args);
        requestId = _sendRequest(req.encodeCBOR(), subscriptionId, gasLimit, donID);
    }

    function getValuationInUsdc(uint256 tokenId) external view returns (uint256) {
        return s_valuationInUsdc[tokenId];
    }

    function setPriceScript(string memory priceScript) external onlyOwner {
        s_priceScript = priceScript;
    }

    function setRequestUrl(string memory requestUrl) external onlyOwner {
        s_requestUrl = requestUrl;
    }

    function fulfillRequest(
        bytes32,
        /*requestId*/
        bytes memory response,
        bytes memory err
    ) internal override {
        if (err.length != 0) {
            revert(string(err));
        }
        (uint256 tokenId, uint256 valuationInUsdc) = abi.decode(response, (uint256, uint256));
        s_valuationInUsdc[tokenId] = valuationInUsdc;
    }
}
