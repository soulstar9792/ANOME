// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "../00_lib/zeppelin/token/ERC20/ERC20.sol";

contract SimpleToken is ERC20 {
    constructor(string memory name, uint256 mintAmount) ERC20(name, name) {
        _mint(msg.sender, mintAmount);
    }
}
