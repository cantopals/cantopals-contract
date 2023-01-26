// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CantoPals is ERC721Enumerable, ERC721URIStorage, Ownable {

    uint256 public maxSupply;
    uint256 public userLimit;
    string private baseUrl;
    string private unrevealedUrl;
    bool private isRevealed;
    mapping(address => uint) public walletMints;

    constructor(uint256 _maxSupply, uint256 _userLimit, string memory _collectionName, string memory _collectionSymbol, string memory _baseUrl, string memory _unrevealedUrl) ERC721(_collectionName, _collectionSymbol) {
            maxSupply = _maxSupply;
            userLimit = _userLimit;
            baseUrl = _baseUrl;
            unrevealedUrl = _unrevealedUrl;
            isRevealed = false;
        }

    function safeMint(uint256 _mintAmount) public {
        uint256 _supply = totalSupply();
        require(_supply <= maxSupply, "Sold out!");
        require(walletMints[msg.sender] + _mintAmount <= userLimit, string.concat("You can only mint ", Strings.toString(userLimit), " NFTs"));
        for (uint256 i = 1; i <= _mintAmount; i++) {
            uint256 _tokenId = _supply + i;
            _safeMint(msg.sender, _tokenId);
            _setTokenURI(_tokenId, string.concat(baseUrl, Strings.toString(_tokenId), ".json"));
        }
        walletMints[msg.sender] = walletMints[msg.sender] + _mintAmount;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        require(_exists(tokenId), "NFT with this ID doesn't exist");
        if(isRevealed){
            return super.tokenURI(tokenId);
        } else {
            return unrevealedUrl;
        }
    }

    // Only owner

    function revealCollection() public onlyOwner {
        isRevealed = true;
    }
}