// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../00_lib/zeppelin/utils/Strings.sol";
import "../00_lib/zeppelin/access/Ownable.sol";
import "../00_lib/zeppelin/utils/Pausable.sol";
import "../00_lib/zeppelin/utils/cryptography/MerkleProof.sol";

import "../00_lib/erc721a/ERC721A.sol";
import "../00_lib/erc721a/extensions/ERC721ABurnable.sol";
import "../00_lib/erc721a/extensions/ERC721AQueryable.sol";

contract CardNft is Ownable, ERC721A, ERC721AQueryable, ERC721ABurnable, Pausable {
    using Strings for uint256;

    error InvalidTokenId();

    string private _baseTokenURI;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC721A(_name, _symbol) Ownable(msg.sender) {
        _baseTokenURI = _uri;
    }

    function mint(address to, uint256 quantity) external payable {
        _mint(to, quantity);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(tokenId)) revert InvalidTokenId();
        return string(abi.encodePacked(_baseURI(), tokenId.toString(), ".json"));
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721A, IERC721A) returns (bool) {
        return ERC721A.supportsInterface(interfaceId);
    }
}
