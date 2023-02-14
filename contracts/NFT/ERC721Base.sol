//    ▄████████    ▄████████    ▄████████  ▄█   ▄████████    ▄████████    ▄████████    ▄████████    ▄████████    ▄████████
//   ███    ███   ███    ███   ███    ███ ███  ███    ███   ███    ███   ███    ███   ███    ███   ███    ███   ███    ███
//   ███    ███   ███    █▀    ███    ███ ███▌ ███    █▀    ███    ███   ███    ███   ███    ███   ███    ███   ███    █▀
//   ███    ███  ▄███▄▄▄      ▄███▄▄▄▄██▀ ███▌ ███          ███    ███  ▄███▄▄▄▄██▀   ███    ███  ▄███▄▄▄▄██▀  ▄███▄▄▄
// ▀███████████ ▀▀███▀▀▀     ▀▀███▀▀▀▀▀   ███▌ ███        ▀███████████ ▀▀███▀▀▀▀▀   ▀███████████ ▀▀███▀▀▀▀▀   ▀▀███▀▀▀
//   ███    ███   ███        ▀███████████ ███  ███    █▄    ███    ███ ▀███████████   ███    ███ ▀███████████   ███    █▄
//   ███    ███   ███          ███    ███ ███  ███    ███   ███    ███   ███    ███   ███    ███   ███    ███   ███    ███
//   ███    █▀    ███          ███    ███ █▀   ████████▀    ███    █▀    ███    ███   ███    █▀    ███    ███   ██████████

// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

/// @custom:security-contact security@africarare.io
contract ERC721Base is
    ERC721Upgradeable,
    PausableUpgradeable,
    OwnableUpgradeable,
    ERC721BurnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using StringsUpgradeable for uint256;

    CountersUpgradeable.Counter private _tokenIdCounter;

    string public baseUri;
    bool public singleItemCollection;

    constructor() ERC721Upgradeable() {}

    function initialize(
        string memory name_,
        string memory symbol_,
        string memory uri_,
        address ownerAddress,
        bool singleItemCollection_
    ) external initializer nonReentrant {
        __ERC721_init(name_, symbol_);
        __Ownable_init();
        transferOwnership(ownerAddress);
        baseUri = uri_;
        singleItemCollection = singleItemCollection_;
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable)
    {
        super._burn(tokenId);
    }

    /**
    returns URI+id if multicollection, otherwise same URI for all ID's
    **/
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable)
        returns (string memory)
    {
        if(singleItemCollection) {
            return baseUri;
        } else {
        return super.tokenURI(tokenId);
        }
    }

    /**
    * @dev Mints 1 NFT to senders address
    */
    function mintSingleNFT() internal onlyOwner {
        safeMint(msg.sender);

    }


    /**
    * @dev Mints 1 NFT to specified address
    */
    function mintToAddressSingleNFT(address receiver) internal onlyOwner {
        safeMint(receiver);
    }

    /**
    * @dev Mints batch of n number of NFTs
    */
    function mintBatchOfNFT(uint256 numToMint) external onlyOwner {
        for (uint i=0; i < numToMint; i++) {
            mintSingleNFT();
        }
    }

    /**
    * @dev Mints batch of n number of NFTs to specified address
    */
    function mintToAddressBatchOfNFT(uint256 numToMint, address receiver) external onlyOwner {
        for (uint i=0; i < numToMint; i++) {
            mintToAddressSingleNFT(receiver);
        }
    }

    /**
    * @dev Mints batch of n number of NFTs to each specified addresses
    */
    function AirdropNFT(uint256 numToMintToEachReceiver, address[] memory receivers) external onlyOwner {
        for(uint i=0; i < receivers.length; i++) {
            for (uint j=0; j < numToMintToEachReceiver; j++) {
                mintToAddressSingleNFT(receivers[i]);
            }
        }
    }

    /**
    * @dev Withdraw funds from this contract (Callable by owner)
    */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        address payable ownerAddress = payable(msg.sender);
        require(ownerAddress != address(0), "ERC20: transfer to the zero address");
        ownerAddress.transfer(balance);
    }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
