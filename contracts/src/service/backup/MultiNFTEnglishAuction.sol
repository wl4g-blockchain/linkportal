// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
// import {IERC1155Receiver, IERC165} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
// import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
// import {MultiReentrancyGuard} from "../utils/MultiReentrancyGuard.sol";

// contract MultiNFTEnglishAuction is
//     IERC1155Receiver,
//     MultiReentrancyGuard,
//     Ownable
// {
//     struct Auction {
//         address seller;
//         uint256 tokenId;
//         uint256 amount;
//         uint48 endTimestamp;
//         address highestBidder;
//         uint256 highestBid;
//         bool started;
//         mapping(address => uint256) bids;
//     }

//     error OnlySellerCanCall();
//     error AuctionAlreadyStarted();
//     error NoAuctionsInProgress();
//     error AuctionEnded();
//     error BidNotHighEnough();
//     error CannotWithdrawHighestBid();
//     error TooEarlyToEnd();
//     error FailedToWithdrawBid(address bidder, uint256 amount);
//     error NothingToWithdraw();
//     error FailedToSendEth(address recipient, uint256 amount);

//     mapping(uint256 => Auction) internal auctions;
//     uint256 internal auctionCount;
//     address internal immutable i_fractionalizedRealEstateToken;

//     event CreatedAuction(
//         uint256 indexed auctionId,
//         uint256 indexed tokenId,
//         uint256 indexed amount,
//         uint48 endTimestamp
//     );
//     event Bid(
//         uint256 indexed auctionId,
//         address indexed bidder,
//         uint256 indexed amount
//     );
//     event EndedAuction(
//         uint256 indexed auctionId,
//         uint256 tokenId,
//         uint256 amount,
//         address indexed winner,
//         uint256 indexed winningBid
//     );

//     constructor(
//         address _paymentToken,
//         address _initialOwner
//     ) Ownable(_initialOwner) {
//         paymentToken = IERC20(_paymentToken);
//     }

//     function createAuction(
//         uint256 tokenId,
//         uint256 amount,
//         bytes calldata data,
//         uint256 startingBid
//     ) external nonReentrant returns (uint256 auctionId) {
//         Auction storage auction = auctions[auctionCount];

//         if (auction.started) revert AuctionAlreadyStarted();

//         IERC1155(i_fractionalizedRealEstateToken).safeTransferFrom(
//             msg.sender,
//             address(this),
//             tokenId,
//             amount,
//             data
//         );

//         auction.seller = msg.sender;
//         auction.tokenId = tokenId;
//         auction.amount = amount;
//         auction.started = true;
//         auction.endTimestamp = SafeCast.toUint48(block.timestamp + 7 days);
//         auction.highestBidder = msg.sender;
//         auction.highestBid = startingBid;

//         auctionId = auctionCount;
//         auctionCount++;

//         emit CreatedAuction(auctionId, tokenId, amount, auction.endTimestamp);
//         return auctionId;
//     }

//     function bid(uint256 auctionId) external payable nonReentrant {
//         Auction storage auction = auctions[auctionId];

//         if (!auction.started) revert NoAuctionsInProgress();
//         if (block.timestamp >= auction.endTimestamp) revert AuctionEnded();
//         if (msg.value <= auction.highestBid) revert BidNotHighEnough();

//         auction.highestBidder = msg.sender;
//         auction.highestBid = msg.value;
//         auction.bids[msg.sender] += msg.value;

//         emit Bid(auctionId, msg.sender, msg.value);
//     }

//     function withdrawBid(uint256 auctionId) external nonReentrant {
//         Auction storage auction = auctions[auctionId];

//         if (msg.sender == auction.highestBidder)
//             revert CannotWithdrawHighestBid();

//         uint256 amount = auction.bids[msg.sender];
//         if (amount == 0) revert NothingToWithdraw();

//         auction.bids[msg.sender] = 0;

//         (bool sent, ) = msg.sender.call{value: amount}("");
//         if (!sent) revert FailedToWithdrawBid(msg.sender, amount);
//     }

//     function endAuction(uint256 auctionId) external nonReentrant {
//         Auction storage auction = auctions[auctionId];

//         if (!auction.started) revert NoAuctionsInProgress();
//         if (block.timestamp < auction.endTimestamp) revert TooEarlyToEnd();

//         auction.started = false;

//         IERC1155(i_fractionalizedRealEstateToken).safeTransferFrom(
//             address(this),
//             auction.highestBidder,
//             auction.tokenId,
//             auction.amount,
//             ""
//         );

//         (bool sent, ) = auction.seller.call{value: auction.highestBid}("");
//         if (!sent) revert FailedToSendEth(auction.seller, auction.highestBid);

//         emit EndedAuction(
//             auctionId,
//             auction.tokenId,
//             auction.amount,
//             auction.highestBidder,
//             auction.highestBid
//         );
//     }

//     // 继承自 IERC1155Receiver 的其他方法保持不变
//     function onERC1155Received(
//         address /*operator*/,
//         address /*from*/,
//         uint256 /*id*/,
//         uint256 /*value*/,
//         bytes calldata /*data*/
//     ) external pure returns (bytes4) {
//         return IERC1155Receiver.onERC1155Received.selector;
//     }

//     function onERC1155BatchReceived(
//         address /*operator*/,
//         address /*from*/,
//         uint256[] calldata /*ids*/,
//         uint256[] calldata /*values*/,
//         bytes calldata /*data*/
//     ) external pure returns (bytes4) {
//         return IERC1155Receiver.onERC1155BatchReceived.selector;
//     }

//     function supportsInterface(
//         bytes4 interfaceId
//     ) public view virtual override(IERC165) returns (bool) {
//         return
//             interfaceId == type(IERC1155Receiver).interfaceId ||
//             interfaceId == type(IERC165).interfaceId;
//     }
// }
