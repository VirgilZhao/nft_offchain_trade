// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./RoleControl.sol";

contract NFTItem is ERC721URIStorage, RoleControl  {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _listSells;
    mapping (uint256 => MarketItem) private _idToMarketItem;

    struct NFTData {
        uint256 tokenId;
        string tokenURI;
    }

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        uint256 price;
    }

    constructor() ERC721("NFTItem", "MNFT") RoleControl(msg.sender) {
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function awardItem(address buyer, string memory tokenURI)
        onlyFeePayer
        public
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _mint(buyer, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }

    function sellItem(address seller, uint256 tokenId, uint256 price, bytes memory signature) 
        onlyFeePayer
        public 
    {
        require(verifySign(seller, tokenId, price, signature), "signature is not matched");
        require(ownerOf(tokenId) == seller, "seller not owned tokenId");
        require(price > 0, "price must bigger than 0");
        if(_idToMarketItem[tokenId].price > 0) {
            delete _idToMarketItem[tokenId];
        }
        _idToMarketItem[tokenId] = MarketItem(tokenId, payable(seller), price);
        _listSells.increment();
    }

    function buyItem(address seller, address buyer, uint256 tokenId, uint256 price, bytes memory signature) 
        onlyFeePayer
        public 
    {
        require(verifySign(buyer, tokenId, price, signature), "signature is not matched");
        require(ownerOf(tokenId) == seller, "seller not owned tokenId");
        require(price > 0, "price must bigger than 0");
        require(_idToMarketItem[tokenId].price > 0, "item not in market");
        _transfer(seller, buyer, tokenId);
        delete _idToMarketItem[tokenId];
        _listSells.decrement();
    }

    function getSellNFTs() public view returns(MarketItem[] memory) {
        uint256 totalNFTCount = _tokenIds.current();
        uint256 currentIndex = 0;
        uint256 totalSells = _listSells.current();

        MarketItem[] memory items = new MarketItem[](totalSells);
        for (uint256 i = 0; i < totalNFTCount; i++) {
            if(_idToMarketItem[i].price > 0) {
                MarketItem memory item = _idToMarketItem[i];
                items[currentIndex] = item;
                currentIndex += 1;
            }
        }
        return items;
    }

    function getMyNFTs() public view returns(NFTData[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = balanceOf(msg.sender);
        uint256 currentIndex = 0;
        NFTData[] memory items = new NFTData[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++){
            address nftOwner = ownerOf(i);
            if(nftOwner == msg.sender) {
                string memory tokenURI = tokenURI(i);
                items[currentIndex] = NFTData(i, tokenURI);
                currentIndex += 1;
            }
        }
        return items;
    }

    function getMessageHash(address addr, uint256 tokenId, uint256 price) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(addr, tokenId, price));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function verifySign(address seller, uint256 tokenId, uint256 price, bytes memory signature) public pure returns (bool) {
        bytes32 msssageHash = getMessageHash(seller, tokenId, price);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(msssageHash);
        return recoverSigner(ethSignedMessageHash, signature) == seller;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}