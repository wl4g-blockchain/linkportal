// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// import {IERC1155Receiver, IERC165} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
// import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
// import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
// import {MultiReentrancyGuard} from "../utils/MultiReentrancyGuard.sol";

// contract MultiNFTDutchAuction is
//     IERC1155Receiver,
//     MultiReentrancyGuard,
//     Ownable
// {
//     struct Auction {
//         address nftContract;
//         uint256 tokenId;
//         address seller;
//         uint256 startPrice;
//         uint256 endPrice;
//         uint256 startTime;
//         uint256 duration;
//         address highestBidder;
//         uint256 highestBid;
//         bool isActive;
//     }

//     error InvalidAuctionParameters();
//     error AuctionNotActive();
//     error AuctionAlreadyStarted();
//     error AuctionNotStarted();
//     error AuctionEnded();
//     error UnsupportedPaymentToken();
//     error InsufficientBid();
//     error OnlySellerCanCall();
//     error TransferFailed();
//     error NothingToWithdraw();

//     event CreatedAuction(
//         uint256 indexed auctionId,
//         uint256 indexed tokenId,
//         uint256 amount,
//         uint48 endTimestamp
//     );
//     event StartedAuction(uint256 indexed auctionId);

//     mapping(uint256 => Auction) internal auctions;
//     uint256 internal auctionCount;
//     address internal immutable paymentToken;

//     constructor(
//         address _paymentToken,
//         address _initialOwner
//     ) Ownable(_initialOwner) {
//         paymentToken = _paymentToken;
//     }

//     function createAuction(
//         address _nftContract,
//         uint256 _tokenId,
//         uint256 _startPrice,
//         uint256 _endPrice,
//         uint256 _duration
//     ) external {
//         require(_startPrice > _endPrice, "Invalid price range");

//         IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

//         auctions[auctionCount] = Auction({
//             nftContract: _nftContract,
//             tokenId: _tokenId,
//             seller: msg.sender,
//             startPrice: _startPrice,
//             endPrice: _endPrice,
//             startTime: 0,
//             duration: _duration,
//             highestBidder: address(0),
//             highestBid: 0,
//             isActive: false
//         });

//         auctionCount++;
//     }

//     function startAuction(uint256 _auctionId) external {
//         Auction storage auction = auctions[_auctionId];

//         if (auction.isActive) revert AuctionAlreadyStarted();
//         if (auction.seller != msg.sender) revert OnlySellerCanCall();

//         auction.isActive = true;
//         auction.startTime = SafeCast.toUint48(block.timestamp);

//         emit StartedAuction(_auctionId);
//     }

//     function bid(uint256 _auctionId, uint256 _bidAmount) external {
//         Auction storage auction = auctions[_auctionId];
//         require(auction.isActive, "Auction is not active");

//         uint256 currentPrice = getCurrentPrice(_auctionId);
//         require(_bidAmount >= currentPrice, "Bid too low");

//         if (auction.highestBidder != address(0)) {
//             paymentToken.transfer(auction.highestBidder, auction.highestBid);
//         }

//         paymentToken.transferFrom(msg.sender, address(this), _bidAmount);

//         auction.highestBidder = msg.sender;
//         auction.highestBid = _bidAmount;

//         if (block.timestamp >= auction.startTime + auction.duration) {
//             endAuction(_auctionId);
//         }
//     }

//     function getCurrentPrice(uint256 _auctionId) public view returns (uint256) {
//         Auction storage auction = auctions[_auctionId];
//         if (block.timestamp >= auction.startTime + auction.duration) {
//             return auction.endPrice;
//         }

//         uint256 timeElapsed = block.timestamp - auction.startTime;
//         uint256 priceDiff = auction.startPrice - auction.endPrice;
//         uint256 currentPrice = auction.startPrice -
//             ((priceDiff * timeElapsed) / auction.duration);

//         return currentPrice;
//     }

//     function endAuction(uint256 _auctionId) public {
//         Auction storage auction = auctions[_auctionId];
//         require(auction.isActive, "Auction already completed");
//         require(
//             block.timestamp >= auction.startTime + auction.duration,
//             "Auction not ended"
//         );

//         paymentToken.transfer(auction.seller, auction.highestBid);
//         IERC721(auction.nftContract).transferFrom(
//             address(this),
//             auction.highestBidder,
//             auction.tokenId
//         );

//         auction.isActive = false;
//     }

//     function withdrawUnsoldNFT(uint256 _auctionId) external {
//         Auction storage auction = auctions[_auctionId];
//         require(
//             !auction.isActive && auction.highestBidder == address(0),
//             "NFT can't be withdrawn"
//         );
//         require(auction.seller == msg.sender, "Not the seller");

//         IERC721(auction.nftContract).transferFrom(
//             address(this),
//             msg.sender,
//             auction.tokenId
//         );
//     }

//     // 继承自 IERC1155Receiver 的其他方法保持不变
//     function onERC1155Received(
//         address /*operator*/,
//         address /*from*/,
//         uint256 /*id*/,
//         uint256 /*value*/,
//         bytes calldata /*data*/
//     ) external view returns (bytes4) {
//         if (msg.sender != address(paymentToken)) {
//             revert UnsupportedPaymentToken();
//         }
//         return IERC1155Receiver.onERC1155Received.selector;
//     }

//     function onERC1155BatchReceived(
//         address /*operator*/,
//         address /*from*/,
//         uint256[] calldata /*ids*/,
//         uint256[] calldata /*values*/,
//         bytes calldata /*data*/
//     ) external view returns (bytes4) {
//         if (msg.sender != address(paymentToken)) {
//             revert UnsupportedPaymentToken();
//         }
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
