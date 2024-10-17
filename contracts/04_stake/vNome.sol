// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../00_lib/zeppelin/token/ERC20/ERC20.sol";

import "../01_base/DefaultAccessControl.sol";

contract vNome is ERC20, DefaultAccessControl {
    error TransferDisabled();

    constructor() ERC20("vNome", "vNome") {
        _setupRoles(msg.sender, msg.sender);
    }

    function mint(address account, uint256 amount) external onlyCaller {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyCaller {
        _burn(account, amount);
    }

    function _update(address from, address to, uint256 value) internal virtual override {
        value;
        
        if (from != address(0) && to != address(0)) {
            revert TransferDisabled();
        }
    }
}
