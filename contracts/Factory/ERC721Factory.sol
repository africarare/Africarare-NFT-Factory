// SPDX-License-Identifier: MIT
// Author: Africarare
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "../NFT/ERC721Base.sol";

contract CollectionFactory is Ownable {
    address[] public africarareERC721Collections;
    address public africarareERC721BaseContract;

    //@dev - event to be emitted when a new collection is created
    event createdCollection(address collectionAddress, address baseContractAddress);


    function getCollections() external view returns (address[] memory) {
    return africarareERC721Collections;
    }

    function setBaseContract(address contractAddress)
        public
        onlyOwner
        returns (address)
    {
        africarareERC721BaseContract = contractAddress;
        return africarareERC721BaseContract;
    }

    //@dev: Clones a new ERC721 collection from the africarareERC721BaseContract
    function createCollection(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) external returns (address) {
        if (africarareERC721BaseContract == address(0)) {
            revert("ERR: Set base contract");
        }
        address clone = Clones.clone(africarareERC721BaseContract);
        ERC721Base(clone).initialize(_name, _symbol, _uri, msg.sender);
        africarareERC721Collections.push(clone);
        emit createdCollection(clone, africarareERC721BaseContract);
        return clone;
    }
}
