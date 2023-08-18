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
     * @dev This function is PAYABLE to allow native tokens
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

    /**
     * @notice Calculates the amount of ERC20 tokens that would be received,
     * in exchange for _ethInputAmount of ETH. BE AWARE OF THE SLIPPAGE!
     */
    function getTokenAmount(uint256 _ethInputAmount) public view returns (uint256) {
        require(_ethInputAmount > 0, "Input amount has to be > 0");

        uint256 tokenReserves = getReserves();

        return _getAmount(_ethInputAmount, address(this).balance, tokenReserves);
    }

    /* @audit-issue This does not consider diff in decimals? */
    /**
     * @notice Calculates the amount of ETH that would be received,
     * in exchange for _tokenInputAmount of ERC20 tokens. BE AWARE OF THE SLIPPAGE!
     */
    function getEthAmount(uint256 _tokenInputAmount) public view returns (uint256) {
        require(_tokenInputAmount > 0, "Input amount has to be > 0");

        uint256 tokenReserves = getReserves();

        return _getAmount(_tokenInputAmount, tokenReserves, address(this).balance);
    }

    ////////////////////////////////////////////////////////////////////
    //                            Private                             //
    ////////////////////////////////////////////////////////////////////

    /**
     * @dev In case of UniswapV1 one of the tokens is always ETH.
     * @param _inputAmount Amount of token 'x' to be exchanged for token 'y'
     * @param _inputReserves Amount of token 'x' held in the exchange contract
     * @param _outputReserves Amount of token 'y' held in the exchange contract
     * @return Amount of token 'y' to be received in exchange for token 'x'
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
