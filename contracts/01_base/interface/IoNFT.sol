// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IoNFT {
    struct Metadata {
        uint256 boost;
        uint256 loyalty;
        uint256 stakeDays;
    }

    function anomeIdByTokenId(uint256 tokenId) external view returns (uint256 anomeId);

    function tokenIdByAnomeId(uint256 anomeId) external view returns (uint256 tokenId);

    function metadata(uint256 tokenId) external view returns (Metadata memory);

    function mint(address to, uint256 _anomeId, uint256 _stakeDays, uint256 _boost, uint256 _loyalty) external;

    function burn(uint256 tokenId) external;

    function totalMinted() external view returns (uint256);

    function setBaseURI(string calldata baseURI) external;

    error ApprovalCallerNotOwnerNorApproved();

    error ApprovalQueryForNonexistentToken();

    error BalanceQueryForZeroAddress();

    error MintToZeroAddress();

    error MintZeroQuantity();

    error OwnerQueryForNonexistentToken();

    error TransferCallerNotOwnerNorApproved();

    error TransferFromIncorrectOwner();

    error TransferToNonERC721ReceiverImplementer();

    error TransferToZeroAddress();

    error URIQueryForNonexistentToken();

    error MintERC2309QuantityExceedsLimit();

    error OwnershipNotInitializedForExtraData();

    struct TokenOwnership {
        address addr;
        uint64 startTimestamp;
        bool burned;
        uint24 extraData;
    }

    function totalSupply() external view returns (uint256);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external payable;

    function safeTransferFrom(address from, address to, uint256 tokenId) external payable;

    function transferFrom(address from, address to, uint256 tokenId) external payable;

    function approve(address to, uint256 tokenId) external payable;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed from, address indexed to);
}
