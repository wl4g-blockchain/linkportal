// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title MultiReentrancyGuard
 * @author James Wong
 * @notice refer to see: @openzeppelin/contracts/utils/ReentrancyGuard.sol
 */
abstract contract MultiReentrancyGuard {
    mapping(uint256 => bool) private _taskGuards;

    modifier nonReentrant(uint256 taskId) {
        require(!_taskGuards[taskId], "ReentrancyGuard: reentrant call");
        _taskGuards[taskId] = true;
        _;
        _taskGuards[taskId] = false;
    }
}
