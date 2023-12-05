// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "../ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _decimals,
        uint8 _feesPercent,
        address _feeReceiver,
        uint256 _totalSupply,
        address _owner
    )
        ERC20(
            _name,
            _symbol,
            _decimals,
            _feesPercent,
            _feeReceiver,
            _totalSupply,
            _owner
        )
    {}

    function mockMint(address to, uint256 value) external {
        _mint(to, value);
    }
}