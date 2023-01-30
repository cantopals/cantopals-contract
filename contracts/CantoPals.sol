// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CantoPals is ERC721Enumerable, ERC721URIStorage, Pausable, Ownable {
    using Counters for Counters.Counter;

    uint256 public maxMint;
    uint256 public maxClaim;
    Counters.Counter private mintCount;
    Counters.Counter private claimCount;
    mapping(address => bool) private whitelistedWallets;
    string private baseUrl;
    string private unrevealedUrl;
    bool private isRevealed;
    uint256 public cost = 25 ether;

    constructor(string memory _baseUrl, string memory _unrevealedUrl) ERC721('CantoPals', 'CPALS') {
        maxMint = 2667;
        maxClaim = 666;
        baseUrl = _baseUrl;
        unrevealedUrl = _unrevealedUrl;
        isRevealed = false;
    }

    // Write an owner mint function

    function mint(uint256 _mintAmount) public whenNotPaused payable {
        require(maxMint >= mintCount.current() + _mintAmount, string.concat("Only ", Strings.toString(maxMint - mintCount.current()), " left to mint!"));
        require(msg.value >= cost * _mintAmount);
        for (uint256 i = 1; i <= _mintAmount; i++) {
            uint256 tokenId = totalSupply() + 1;
            _safeMint(msg.sender, tokenId);
            _setTokenURI(tokenId, string.concat(baseUrl, Strings.toString(tokenId), ".json"));
            mintCount.increment();
        }
    }

    function claim() public whenNotPaused {
        require(whitelistedWallets[msg.sender], "You are not eligible to claim this NFT. Please try minting!");
        require(maxClaim >= claimCount.current() + 1, "No NFT left to claim!");
        uint256 tokenId = totalSupply() + 1;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, string.concat(baseUrl, Strings.toString(tokenId), ".json"));
        claimCount.increment();
        whitelistedWallets[msg.sender] = false;
    }

    /* Only owner can execute these functions. */
    function revealCollection() public onlyOwner {
        isRevealed = true;
    }

    function populateWhitelist(address[] calldata _wallets) public onlyOwner {
        for(uint256 i; i < _wallets.length; i++) {
            whitelistedWallets[_wallets[i]] = true;
        }
    }

    function setCost(uint256 _cost) public onlyOwner {
        cost = _cost * (1 ether);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    /* The following functions are overrides required by Solidity. */
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
}