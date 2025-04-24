// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MockERC1155
 * @dev 用于测试的简单ERC1155合约
 */
contract MockERC1155 is ERC1155, Ownable {
    constructor() ERC1155("https://mock-uri.com/{id}.json") Ownable(msg.sender) {}

    /**
     * @dev 铸造代币给指定地址
     * @param to 接收者地址
     * @param id 代币ID
     * @param amount 铸造数量
     * @param data 附加数据
     */
    function mint(address to, uint256 id, uint256 amount, bytes memory data) public onlyOwner {
        _mint(to, id, amount, data);
    }

    /**
     * @dev 批量铸造代币给指定地址
     * @param to 接收者地址
     * @param ids 代币ID数组
     * @param amounts 铸造数量数组
     * @param data 附加数据
     */
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev 设置URI
     * @param newuri 新的URI
     */
    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data)
        public
        override
    {
        super.safeTransferFrom(from, to, id, value, data);
    }
}

