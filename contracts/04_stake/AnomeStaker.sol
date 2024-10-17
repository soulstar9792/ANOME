// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../00_lib/zeppelin/token/ERC721/IERC721.sol";
import "../00_lib/zeppelin/token/ERC721/IERC721Receiver.sol";

import "../00_lib/zeppelin/access/Ownable.sol";

import "../02_anome_eth/AnomeNft.sol";

contract AnomeStaker is Ownable, IERC721Receiver {
    error NotOwner();
    error NotVaultToken();
    error InvalidPeriod();
    error VaultStaked();
    error NotComplete();

    event NFTStaked(address owner, uint256 tokenId, uint256 time, uint256 period);
    event NFTUnstaked(address owner, bool isForce, uint256 tokenId, uint256 time, uint256 period);

    struct Stake {
        uint24 tokenId;
        uint48 timestamp;
        address owner;
        uint96 period;
    }

    AnomeNft public token;
    uint256 public periodUnit = 30 days;
    uint256 public totalStaked;
    mapping(uint24 => Stake) internal _vaults;

    constructor() Ownable(msg.sender) {

    }

    function stake(uint256[] calldata tokenIds, uint256 period) external {
        if (period != 1 && period != 3 && period != 6 && period != 12 && period != 24) revert InvalidPeriod();

        totalStaked += tokenIds.length;

        for (uint i = 0; i < tokenIds.length; i++) {
            uint24 tokenId = uint24(tokenIds[i]);

            if (token.ownerOf(tokenId) != msg.sender) revert NotOwner();
            if (_vaults[tokenId].tokenId != 0) revert VaultStaked();

            token.safeTransferFrom(msg.sender, address(this), tokenId);
            emit NFTStaked(msg.sender, tokenId, block.timestamp, period);

            _vaults[tokenId] = Stake({
                owner: msg.sender,
                tokenId: uint24(tokenId),
                timestamp: uint48(block.timestamp),
                period: uint96(period)
            });
        }
    }

    function unstake(uint256[] calldata tokenIds, bool isForce) external {
        totalStaked -= tokenIds.length;

        for (uint i = 0; i < tokenIds.length; i++) {
            uint24 tokenId = uint24(tokenIds[i]);

            Stake memory staked = _vaults[tokenId];
            if (staked.owner != msg.sender) revert NotOwner();

            if (!isForce) {
                if (block.timestamp < stakeEndsTime(tokenId)) revert NotComplete();
            }

            delete _vaults[tokenId];
            emit NFTUnstaked(msg.sender, isForce, tokenId, block.timestamp, staked.period);
            token.transferFrom(address(this), msg.sender, tokenId);
        }
    }

    function stakeEndsTime(uint256 tokenId) public view returns (uint256) {
        Stake memory staked = _vaults[uint24(tokenId)];
        return staked.timestamp + uint256(staked.period) * periodUnit;
    }

    function balanceOf(address account) external view returns (uint256) {
        uint256 balance = 0;
        uint256 supply = token.totalMinted();
        for (uint24 i = 1; i <= supply; i++) {
            if (_vaults[i].owner == account) {
                balance += 1;
            }
        }
        return balance;
    }

    function accountStakeds(address account) external view returns (Stake[] memory ownerTokens) {
        uint256 index = 0;

        uint256 supply = token.totalMinted();
        Stake[] memory tmp = new Stake[](supply);
        for (uint24 tokenId = 1; tokenId <= supply; tokenId++) {
            if (_vaults[tokenId].owner == account) {
                tmp[index] = _vaults[tokenId];
                index += 1;
            }
        }

        Stake[] memory tokens = new Stake[](index);
        for (uint i = 0; i < index; i++) {
            tokens[i] = tmp[i];
        }

        return tokens;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function setPeriodUnit(uint256 _periodUnit) external onlyOwner {
        periodUnit = _periodUnit;
    }

    function setVaultToken(address _token) external onlyOwner {
        token = AnomeNft(_token);
    }

    function sendNft(uint256 id) external onlyOwner {
        token.safeTransferFrom(address(this), owner(), id);
    }
}
