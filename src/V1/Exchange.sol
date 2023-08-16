// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

/**
 * @notice In UniswapV1 it is only possible to exchange 1 type of token for ETH.
 */
contract Exchange {
    address public tokenAddress;

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Token address cannot be 0");
        tokenAddress = _tokenAddress;
    }

    /**
     * @notice Provide _amount of tokens to the exchange contract as liquidity.
     * Before calling this function make sure to approve the exchange contract.
     */
    function addLiquidity(uint256 _amount) public payable {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
    }
}
