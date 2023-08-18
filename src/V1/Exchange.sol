// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

/**
 * @notice In UniswapV1 it is only possible to exchange 1 type of token for ETH.
 */
contract Exchange {
    /**
     * @notice Address of the token that is being traded on this exchange.
     */
    address public tokenAddress;

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Token address cannot be 0");
        tokenAddress = _tokenAddress;
    }

    ////////////////////////////////////////////////////////////////////
    //                            Public                              //
    ////////////////////////////////////////////////////////////////////

    /**
     * @notice Provide _amount of tokens to the exchange contract as liquidity.
     * Before calling this function make sure to approve the exchange contract.
     *
     * @dev This function is payable to allow native tokens
     * to be added as liquidity as well.
     */
    function addLiquidity(uint256 _amount) public payable {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
    }

    /*~*~*~*~*~*~*~*~*~*~*~*~* View Functions ~*~*~*~*~*~*~*~*~*~*~*~*~/
    /**
     * @notice Get the amount of tokens held in the exchange contract.
     * These tokens are available for trading.
     */
    function getReserves() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    ////////////////////////////////////////////////////////////////////
    //                            Private                             //
    ////////////////////////////////////////////////////////////////////
    /**
    * @param _inputAmount Amount of token 'x' to be exchanged for token 'y'
    * @param _inputReserves Amount of token 'x' held in the exchange contract
    * @param _outputReserves Amount of token 'y' held in the exchange contract
    */
    function _getAmount(uint256 _inputAmount, uint256 _inputReserves, uint256 _outputReserves)
        private
        pure
        returns (uint256)
    {
        require(_inputReserves > 0 && _outputReserves > 0, "Reserves cannot be 0");
        return (_inputAmount * _outputReserves) / _inputReserves;
    }
}
