// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
// import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
// import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
// import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
// import {MultiReentrancyGuard} from "../../utils/MultiReentrancyGuard.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract RWAAuctionPlatform is IERC1155Receiver, MultiReentrancyGuard {
//     enum AuctionType {
//         Dutch,
//         English
//     }

//     struct Auction {
//         address seller;
//         address nftContract;
//         uint256 tokenId;
//         uint256 amount;
//         AuctionType auctionType;
//         uint256 startPrice;
//         uint256 endPrice;
//         uint48 startTime;
//         uint48 endTime;
//         address highestBidder;
//         uint256 highestBid;
//         bool isActive;
//         mapping(address => uint256) bids;
//     }

//     // Error Definitions
//     error InvalidAuctionParameters();
//     error AuctionNotActive();
//     error AuctionAlreadyStarted();
//     error AuctionNotStarted();
//     error AuctionEnded();
//     error InsufficientBid();
//     error OnlySellerCanCall();
//     error TransferFailed();
//     error NothingToWithdraw();

//     // Event Definitions
//     event AuctionCreated(
//         uint256 indexed auctionId,
//         address indexed seller,
//         uint256 tokenId,
//         uint256 amount,
//         AuctionType auctionType
//     );
//     event StartedAuction(
//         uint256 indexed auctionId,
//         uint48 startTime,
//         uint48 endTime
//     );
//     event BidPlaced(
//         uint256 indexed auctionId,
//         address indexed bidder,
//         uint256 bidAmount
//     );
//     event EndedAuction(
//         uint256 indexed auctionId,
//         address indexed winner,
//         uint256 winningBid
//     );

//     address public immutable paymentToken;
//     mapping(uint256 => Auction) public auctions;
//     uint256 public auctionCount;

//     constructor(address _paymentToken) {
//         paymentToken = _paymentToken;
//     }

//     function createAuction(
//         address _nftContract,
//         uint256 _tokenId,
//         uint256 _amount,
//         AuctionType _auctionType,
//         uint256 _startPrice,
//         uint256 _endPrice,
//         uint48 _duration
//     ) external returns (uint256 auctionId) {
//         // 验证拍卖参数
//         if (_startPrice <= _endPrice && _auctionType == AuctionType.Dutch)
//             revert InvalidAuctionParameters();

//         // 转移NFT到合约
//         IERC1155(_nftContract).safeTransferFrom(
//             msg.sender,
//             address(this),
//             _tokenId,
//             _amount,
//             ""
//         );

//         // 创建拍卖
//         Auction storage auction = auctions[auctionCount];
//         auction.seller = msg.sender;
//         auction.nftContract = _nftContract;
//         auction.tokenId = _tokenId;
//         auction.amount = _amount;
//         auction.auctionType = _auctionType;
//         auction.startPrice = _startPrice;
//         auction.endPrice = _endPrice;
//         auction.startTime = SafeCast.toUint48(block.timestamp);
//         auction.endTime = SafeCast.toUint48(block.timestamp + _duration);
//         auction.isActive = false;

//         auctionId = auctionCount;
//         auctionCount++;

//         emit AuctionCreated(
//             auctionId,
//             msg.sender,
//             _tokenId,
//             _amount,
//             _auctionType
//         );

//         return auctionId;
//     }

//     function startAuction(uint256 _auctionId) external {
//         Auction storage auction = auctions[_auctionId];

//         if (auction.isActive) revert AuctionAlreadyStarted();
//         if (auction.seller != msg.sender) revert OnlySellerCanCall();

//         auction.isActive = true;
//         auction.startTime = SafeCast.toUint48(block.timestamp);

//         emit StartedAuction(_auctionId, auction.startTime, auction.endTime);
//     }

//     function getCurrentPrice(uint256 _auctionId) public view returns (uint256) {
//         Auction storage auction = auctions[_auctionId];

//         if (auction.auctionType == AuctionType.English) return auction.startPrice;

//         if (block.timestamp >= auction.endTime) return auction.endPrice;

//         uint256 timeElapsed = block.timestamp - auction.startTime;
//         uint256 priceDiff = auction.startPrice - auction.endPrice;
//         uint256 currentPrice = auction.startPrice -
//             ((priceDiff * timeElapsed) / (auction.endTime - auction.startTime));

//         return currentPrice;
//     }

//     function bid(uint256 _auctionId, uint256 _bidAmount) external {
//         Auction storage auction = auctions[_auctionId];

//         if (!auction.isActive) revert AuctionNotActive();
//         if (block.timestamp >= auction.endTime) revert AuctionEnded();

//         uint256 currentPrice = getCurrentPrice(_auctionId);
//         if (_bidAmount < currentPrice) revert InsufficientBid();

//         // 英式拍卖逻辑
//         if (auction.auctionType == AuctionType.English) {
//             if (_bidAmount <= auction.highestBid) revert InsufficientBid();

//             // 退还之前的最高出价
//             if (auction.highestBidder != address(0)) {
//                 auction.bids[auction.highestBidder] += auction.highestBid;
//             }
//         }

//         // 转移资金
//         IERC20(paymentToken).transferFrom(
//             msg.sender,
//             address(this),
//             _bidAmount
//         );

//         auction.highestBidder = msg.sender;
//         auction.highestBid = _bidAmount;

//         emit BidPlaced(_auctionId, msg.sender, _bidAmount);
//     }

//     function endAuction(uint256 _auctionId) external {
//         Auction storage auction = auctions[_auctionId];

//         if (!auction.isActive) revert AuctionNotActive();
//         if (block.timestamp < auction.endTime) revert AuctionNotStarted();

//         // 转移NFT给最高出价者
//         IERC1155(auction.nftContract).safeTransferFrom(
//             address(this),
//             auction.highestBidder,
//             auction.tokenId,
//             auction.amount,
//             ""
//         );

//         // 转移资金给卖家
//         IERC20(paymentToken).transfer(auction.seller, auction.highestBid);

//         auction.isActive = false;

//         emit EndedAuction(
//             _auctionId,
//             auction.highestBidder,
//             auction.highestBid
//         );
//     }

//     function withdrawBid(uint256 _auctionId) external {
//         Auction storage auction = auctions[_auctionId];

//         if (msg.sender == auction.highestBidder) revert NothingToWithdraw();

//         uint256 bidAmount = auction.bids[msg.sender];
//         if (bidAmount == 0) revert NothingToWithdraw();

//         auction.bids[msg.sender] = 0;

//         // 退款
//         IERC20(paymentToken).transfer(msg.sender, bidAmount);
//     }

//     // IERC1155Receiver 接口实现
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
//     ) external pure returns (bool) {
//         return
//             interfaceId == type(IERC1155Receiver).interfaceId ||
//             interfaceId == type(IERC165).interfaceId;
//     }
// }
