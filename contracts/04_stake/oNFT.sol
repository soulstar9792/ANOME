// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../00_lib/zeppelin/utils/Strings.sol";
import "../00_lib/zeppelin/access/Ownable.sol";
import "../00_lib/zeppelin/utils/Pausable.sol";
import "../00_lib/zeppelin/utils/cryptography/MerkleProof.sol";

import "../00_lib/erc721a/ERC721A.sol";
import "../00_lib/erc721a/extensions/ERC721ABurnable.sol";
import "../00_lib/erc721a/extensions/ERC721AQueryable.sol";

import "../01_base/DefaultAccessControl.sol";

contract oNFT is ERC721A, ERC721AQueryable, DefaultAccessControl {
    using Strings for uint256;

    error InvalidTokenId();
    error TransferDisabled();

    struct Metadata {
        uint256 boost;
        uint256 loyalty;
        uint256 stakeDays;
    }

    string private _baseTokenURI = "ipfs://QmWktdUKSh4aZ7c8xrRXPz8Eo2wxA8eZy4pWrX23J1tF8p/";

    mapping(uint256 => uint256) public anomeIdByTokenId;
    mapping(uint256 => uint256) public tokenIdByAnomeId;
    mapping(uint256 => Metadata) public metadata;

    constructor() ERC721A("Anome", "Anome") {
        _setupRoles(msg.sender, msg.sender);
    }

    function mint(
        address to,
        uint256 _anomeId,
        uint256 _stakeDays,
        uint256 _boost,
        uint256 _loyalty
    ) external onlyCaller {
        uint256 tokenId = _nextTokenId();

        metadata[tokenId] = Metadata({boost: _boost, loyalty: _loyalty, stakeDays: _stakeDays});

        anomeIdByTokenId[tokenId] = _anomeId;
        tokenIdByAnomeId[_anomeId] = tokenId;

        _mint(to, 1);
    }

    function burn(uint256 tokenId) external onlyCaller {
        _burn(tokenId, false);
        delete metadata[tokenId];
        delete tokenIdByAnomeId[anomeIdByTokenId[tokenId]];
        delete anomeIdByTokenId[tokenId];
    }

    function _beforeTokenTransfers(address from, address to, uint256, uint256) internal pure override {
        if (from != address(0) && to != address(0)) {
            revert TransferDisabled();
        }
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 999;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(tokenId)) revert InvalidTokenId();
        return string(abi.encodePacked(_baseURI(), tokenId.toString(), ".json"));
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function totalMinted() external view returns (uint256) {
        return _totalMinted();
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721A, IERC721A, AccessControlEnumerable) returns (bool) {
        return ERC721A.supportsInterface(interfaceId) || AccessControlEnumerable.supportsInterface(interfaceId);
    }

    function setBaseURI(string calldata baseURI) external onlyConfigurator {
        _baseTokenURI = baseURI;
    }
}
