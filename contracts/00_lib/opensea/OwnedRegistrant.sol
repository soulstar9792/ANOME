// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IOperatorFilterRegistry} from "./IOperatorFilterRegistry.sol";
import {Ownable} from "../zeppelin/access/Ownable.sol";
import {Ownable2Step} from "../zeppelin/access/Ownable2Step.sol";
import {CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS} from "./lib/Constants.sol";

/**
 * @title  OwnedRegistrant
 * @notice Ownable contract that registers itself with the OperatorFilterRegistry and administers its own entries,
 *         to facilitate a subscription whose ownership can be transferred.
 */
contract OwnedRegistrant is Ownable2Step {
    /// @dev The constructor that is called when the contract is being deployed.
    constructor(address _owner) Ownable(_owner) {
        IOperatorFilterRegistry(CANONICAL_OPERATOR_FILTER_REGISTRY_ADDRESS).register(address(this));
        transferOwnership(_owner);
    }
}
