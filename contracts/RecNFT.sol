// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./RoleControl.sol";
import "./MessageSign.sol";

contract RecNFTMarketplace is ERC1155URIStorage, RoleControl, MessageSign  {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping (uint256 => OrderItem) private _idToOrderItemMap;
    mapping (uint256 => OfferItem) private _offerItemMap;
    event AwardItem(address holder, uint256 tokenId, uint256 amount, string tokenURI);
    event SellItem(address seller, uint256 orderId, uint256 tokenId, uint256 amount, uint256 price);
    event BuyItem(address buyer, uint256 orderId, uint256 tokenId, uint256 amount, uint256 price);

    struct OrderItem {
        uint256 orderId;
        uint256 tokenId;
        address payable seller;
        uint256 price;
        uint256 amount;
    }

    struct OfferItem{
        uint256 offerId;
        uint256 orderId;
        uint256 tokenId;
        address payable seller;
        uint256 price;
        uint256 amount;
    }

    constructor() ERC1155("") RoleControl(msg.sender) {
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl, ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function awardItem(address holder, uint256 amount, string memory tokenURI)
        onlyFeePayer
        external
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _mint(holder, newItemId, amount, "");
        _setURI(newItemId, tokenURI);

        _tokenIds.increment();
        emit AwardItem(holder, newItemId, amount, tokenURI);
        return newItemId;
    }

    function sellItem(address seller, uint256 orderId, uint256 tokenId, uint256 amount, uint256 price, bytes memory signature)
        onlyFeePayer
        external
    {
        require(verifySign(seller, orderId, tokenId, amount, price, signature), "signature is not matched");
        require(balanceOf(seller, tokenId) >= amount, "seller has not enough amount to sell");
        require(price > 0, "price must bigger than 0");
        require(amount > 0, "amount must bigger than 0");
        require(orderId > 0, "order id is required");
        if(_idToOrderItemMap[orderId].price > 0)
        {
            delete _idToOrderItemMap[orderId];
        }
        _idToOrderItemMap[orderId] = OrderItem(orderId, tokenId, payable(seller), price, amount);
        emit SellItem(seller, orderId, tokenId, amount, price);
    }

    function buyItem(address buyer, uint256 orderId, uint256 tokenId, uint256 amount, uint256 price, bytes memory signature)
        onlyFeePayer
        external
    {
        require(verifySign(buyer, orderId, tokenId, amount, price, signature), "signature is not matched");
        require(_idToOrderItemMap[orderId].price > 0, "order item is not on sale");
        require(_idToOrderItemMap[orderId].amount >= amount, "order has not enough amount to sell");
        address seller = _idToOrderItemMap[orderId].seller;
        require(balanceOf(seller, tokenId) >= amount, "seller has not enough amount to sell");
        require(price > 0, "price must bigger than 0");
        require(amount > 0, "amount must bigger than 0");
        require(orderId > 0, "order id is required");
        _safeTransferFrom(seller, buyer, tokenId, amount, "");
        uint256 orderItemAmount = _idToOrderItemMap[orderId].amount;
        if(orderItemAmount == amount){
            delete _idToOrderItemMap[orderId];
        } else {
            _idToOrderItemMap[orderId].amount = orderItemAmount - amount;
        }
        emit BuyItem(buyer, orderId, tokenId, amount, price);
    }

    function makeOffer(address buyer, uint256 offerId, uint256 orderId, uint256 tokenId, uint256 amount, uint256 price, bytes memory signature)
        onlyFeePayer
        external
    {
        require(verifySign(buyer, orderId, tokenId, amount, price, signature), "signature is not matched");
        require(_idToOrderItemMap[orderId].price > 0, "order item is not on sale");
        require(_idToOrderItemMap[orderId].amount >= amount, "order has not enough amount to sell");
        address seller = _idToOrderItemMap[orderId].seller;
        require(balanceOf(seller, tokenId) >= amount, "seller has not enough amount to sell");
        require(price > 0, "price must bigger than 0");
        require(amount > 0, "amount must bigger than 0");
        require(orderId > 0, "order id is required");
        require(offerId > 0, "offer id is required");
        _offerItemMap[offerId] = OfferItem(offerId, orderId, tokenId, payable(seller), price, amount);
    }

    function cancelOffer()
}
