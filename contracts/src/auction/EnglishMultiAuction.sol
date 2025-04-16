// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MultiAuction, IERC1155} from "./MultiAuction.sol";

contract EnglishAuction is MultiAuction {
    constructor(address _paymentToken) MultiAuction(_paymentToken) {}

    function bid(
        uint256 _auctionId,
        uint256 _bidAmount
    ) external payable override whenNotPaused nonReentrant(_auctionId) {
        Auction storage auction = auctions[_auctionId];

        if (!auction.isActive) revert AuctionNotActive();
        if (block.timestamp >= auction.endTime) revert AuctionEnded();

        uint256 currentPrice = getCurrentPrice(_auctionId);

        if (_bidAmount < currentPrice) revert InsufficientBid();
        if (_bidAmount <= auction.latestBid) revert InsufficientBid();

        // 若有人出过价, 则标记退还之前的最高出价
        if (auction.latestBidder != address(0)) {
            auction.bids[auction.latestBidder] += auction.latestBid;
        }

        // 转移资金
        IERC20(paymentToken).transferFrom(
            msg.sender,
            address(this),
            _bidAmount
        );

        auction.latestBidder = msg.sender;
        auction.latestBid = _bidAmount;

        emit BidPlaced(_auctionId, msg.sender, _bidAmount);
    }

    function endAuction(
        uint256 _auctionId
    ) external payable override whenNotPaused nonReentrant(_auctionId) {
        Auction storage auction = auctions[_auctionId];

        if (!auction.isActive) revert AuctionNotActive();
        if (block.timestamp < auction.endTime) revert AuctionStillOngoing();
        // 若从未有人出过价且未到结束时间, 则不允许结束
        if (auction.latestBidder == address(0)) revert AuctionNoBidsNotEnd();

        auction.isActive = false;

        // 转移资金给卖家
        IERC20(paymentToken).transfer(auction.seller, auction.latestBid);

        // 转移 NFT 给最新出价者(最高出价者)
        IERC1155(auction.nftContract).safeTransferFrom(
            address(this),
            auction.latestBidder,
            auction.tokenId,
            auction.amount,
            ""
        );

        emit EndedAuction(_auctionId, auction.latestBidder, auction.latestBid);
    }

    function withdrawBid(
        uint256 _auctionId
    ) external payable override whenNotPaused nonReentrant(_auctionId) {
        Auction storage auction = auctions[_auctionId];

        if (msg.sender == auction.latestBidder) revert NothingToWithdraw();

        uint256 bidAmount = auction.bids[msg.sender];
        if (bidAmount == 0) revert NothingToWithdraw();

        auction.bids[msg.sender] = 0;

        // Refund to bidder.
        IERC20(paymentToken).transfer(msg.sender, bidAmount);
    }

    function getCurrentPrice(
        uint256 _auctionId
    ) public view override returns (uint256) {
        Auction storage auction = auctions[_auctionId];
        return auction.latestBid; // Montonically increasing, currenly price from latest bid.
    }
}
