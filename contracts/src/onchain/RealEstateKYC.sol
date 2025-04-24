// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstateKYC is Ownable {
    // 用户的验证状态
    mapping(address => bool) public isVerified;

    // 用户的信息
    mapping(address => UserInfo) public userInfos;

    // 用户信息结构体
    struct UserInfo {
        string name;
        string country;
        uint256 verificationTime;
        bytes32 documentHash; // 用户文档的哈希值，保护隐私
    }

    event VerifierAdded(address indexed verifier);
    event VerifierRemoved(address indexed verifier);
    event UserVerified(address indexed user, string name, string country, bytes32 documentHash);

    constructor() Ownable(msg.sender) {}

    modifier onlyVerifier() {
        require(msg.sender == owner() || isVerified[msg.sender], "Not a verifier");
        _;
    }

    function addVerifier(address _verifier) external onlyOwner {
        isVerified[_verifier] = true;
        emit VerifierAdded(_verifier);
    }

    function removeVerifier(address _verifier) external onlyOwner {
        isVerified[_verifier] = false;
        emit VerifierRemoved(_verifier);
    }

    function verifyUser(address _user, string memory _name, string memory _country, bytes32 _documentHash)
        external
        onlyVerifier
    {
        userInfos[_user] =
            UserInfo({name: _name, country: _country, verificationTime: block.timestamp, documentHash: _documentHash});
        isVerified[_user] = true;
        emit UserVerified(_user, _name, _country, _documentHash);
    }

    function revokeVerfication(address _user) external onlyVerifier {
        isVerified[_user] = false;
        emit UserVerified(_user, "", "", bytes32(0));
    }

    // Function to check if a user is verified
    function isUserVerified(address _user) public view returns (bool) {
        return isVerified[_user];
    }
}
