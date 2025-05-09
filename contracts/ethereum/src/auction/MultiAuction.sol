// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {MultiReentrancyGuard} from "../utils/MultiReentrancyGuard.sol";

abstract contract MultiAuction is
    IERC1155Receiver,
    MultiReentrancyGuard,
    Ownable,
    Initializable,
    Pausable
{
    struct Auction {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 amount;
        uint256 startPrice;
        uint256 endPrice;
        uint48 startTime;
        uint48 endTime;
        address latestBidder;
        uint256 latestBid;
        bool isActive;
        mapping(address => uint256) bids;
    }

    // Error Definitions
    error InvalidAuctionParameters();
    error AuctionNotActive();
    error AuctionAlreadyStarted();
    error AuctionStillOngoing();
    error AuctionEnded();
    error InsufficientBid();
    error OnlySellerCanCall();
    error TransferFailed();
    error AuctionNoBidsNotEnd();
    error NothingToWithdraw();

    // Event Definitions
    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        uint256 tokenId,
        uint256 amount
    );
    event StartedAuction(
        uint256 indexed auctionId,
        uint48 startTime,
        uint48 endTime
    );
    event BidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 bidAmount
    );
    event EndedAuction(
        uint256 indexed auctionId,
        address indexed winner,
        uint256 winningBid
    );

    address public /*immutable*/ paymentToken;
    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCount;

    constructor(address _paymentToken) Ownable(msg.sender) {
        paymentToken = _paymentToken;
    }

    function initialize(address _paymentToken) public initializer {
        // __Ownable_init();
        // __Pausable_init();
        paymentToken = _paymentToken;
    }

    function createAuction(
        address _nftContract,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _startPrice,
        uint256 _endPrice,
        uint48 _duration
    ) external whenNotPaused returns (uint256 auctionId) {
        if (!(_startPrice > 0 && _startPrice <= _endPrice))
            revert InvalidAuctionParameters();

        IERC1155(_nftContract).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _amount,
            ""
        );

        Auction storage auction = auctions[auctionCount];
        auction.seller = msg.sender;
        auction.nftContract = _nftContract;
        auction.tokenId = _tokenId;
        auction.amount = _amount;
        auction.startPrice = _startPrice;
        auction.endPrice = _endPrice;
        auction.startTime = SafeCast.toUint48(block.timestamp);
        auction.endTime = SafeCast.toUint48(block.timestamp + _duration);
        auction.isActive = false;

        auctionId = auctionCount;
        auctionCount++;

        emit AuctionCreated(auctionId, msg.sender, _tokenId, _amount);

        return auctionId;
    }

    function startAuction(
        uint256 _auctionId
    ) external whenNotPaused nonReentrant(_auctionId) {
        Auction storage auction = auctions[_auctionId];

        if (auction.isActive) revert AuctionAlreadyStarted();
        if (auction.seller != msg.sender) revert OnlySellerCanCall();

        auction.isActive = true;
        auction.startTime = SafeCast.toUint48(block.timestamp);

        emit StartedAuction(_auctionId, auction.startTime, auction.endTime);
    }

    function bid(
        uint256 _auctionId,
        uint256 _bidAmount
    ) external payable virtual;

    function endAuction(uint256 _auctionId) external payable virtual;

    function withdrawBid(uint256 _auctionId) external payable virtual;

    function getCurrentPrice(
        uint256 _auctionId
    ) public view virtual returns (uint256);

    // IERC1155Receiver 接口实现
    function onERC1155Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*id*/,
        uint256 /*value*/,
        bytes calldata /*data*/
    ) external pure override returns (bytes4) {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address /*operator*/,
        address /*from*/,
        uint256[] calldata /*ids*/,
        uint256[] calldata /*values*/,
        bytes calldata /*data*/
    ) external pure override returns (bytes4) {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external pure override returns (bool) {
        return
            interfaceId == type(IERC1155Receiver).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
