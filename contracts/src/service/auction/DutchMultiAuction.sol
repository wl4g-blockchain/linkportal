// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MultiAuction, IERC1155} from "./MultiAuction.sol";

contract DutchAuction is MultiAuction {
    error WithdrawalNotSupported(uint256 auctionId);

    constructor(address _paymentToken) MultiAuction(_paymentToken) {}

    function bid(
        uint256 _auctionId,
        uint256 _bidAmount
    ) external payable override {
        Auction storage auction = auctions[_auctionId];

        if (!auction.isActive) revert AuctionNotActive();
        if (block.timestamp >= auction.endTime) revert AuctionEnded();

        uint256 currentPrice = getCurrentPrice(_auctionId);
        if (_bidAmount < currentPrice) revert InsufficientBid();

        // 直接成交, 转移资金
        IERC20(paymentToken).transferFrom(
            msg.sender,
            address(this),
            _bidAmount
        );

        auction.latestBidder = msg.sender;
        auction.latestBid = _bidAmount;

        emit BidPlaced(_auctionId, msg.sender, _bidAmount);
    }

    function endAuction(uint256 _auctionId) external payable override {
        Auction storage auction = auctions[_auctionId];

        if (!auction.isActive) revert AuctionNotActive();
        // 若从未有人出过价且未到结束时间, 则不允许结束
        if (auction.latestBidder == address(0)) revert AuctionNoBidsNotEnd();

        auction.isActive = false;

        // 转移资金给卖家
        IERC20(paymentToken).transfer(auction.seller, auction.latestBid);

        // 转移 NFT 给出价者
        IERC1155(auction.nftContract).safeTransferFrom(
            address(this),
            auction.latestBidder,
            auction.tokenId,
            auction.amount,
            ""
        );

        emit EndedAuction(_auctionId, auction.latestBidder, auction.latestBid);
    }

    function withdrawBid(uint256 _auctionId) external payable override {
        // 重写设计为: 竞拍者的出价一旦提交就不可撤回.
        revert WithdrawalNotSupported(_auctionId);
    }

    function getCurrentPrice(
        uint256 _auctionId
    ) public view override returns (uint256) {
        Auction storage auction = auctions[_auctionId];

        if (block.timestamp >= auction.endTime) return auction.endPrice;

        uint256 timeElapsed = block.timestamp - auction.startTime;
        uint256 priceDiff = auction.startPrice - auction.endPrice;
        uint256 currentPrice = auction.startPrice -
            ((priceDiff * timeElapsed) / (auction.endTime - auction.startTime));

        return currentPrice;
    }
}
