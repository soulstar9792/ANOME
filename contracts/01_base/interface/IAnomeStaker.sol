// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBasicAccessControl.sol";

interface IAnomeStaker is IBasicAccessControl {
    event NFTStaked(address owner, uint256 tokenId, uint256 time, uint256 period);
    event NFTUnstaked(address owner, bool isForce, uint256 tokenId, uint256 time, uint256 period);

    struct Stake {
        uint24 tokenId;
        uint48 timestamp;
        address owner;
        uint96 period;
    }

    function token() external view returns (address);

    function periodUnit() external view returns (uint256);

    function totalStaked() external view returns (uint256);

    function stake(uint256[] calldata tokenIds, uint256 period) external;

    function unstake(uint256[] calldata tokenIds, bool isForce) external;

    function stakeEndsTime(uint256 tokenId) external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function accountStakeds(address account) external view returns (Stake[] memory ownerTokens);

    function setPeriodUnit(uint256 _periodUnit) external;

    function setVaultToken(address _token) external;

    function sendNft(uint256 id) external;
}
