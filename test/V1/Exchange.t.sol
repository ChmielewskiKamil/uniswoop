// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";

import {Token} from "src/V1/Token.sol";
import {Exchange} from "src/V1/Exchange.sol";

contract ExchangeTest is Test {
    // Protocol Actors
    address public ADMIN;
    address public ALICE;

    Token public token;
    Exchange public exchange;

    function setUp() public {
        ADMIN = makeAddr("ADMIN");
        ALICE = makeAddr("ALICE");

        vm.startPrank(ADMIN);
        token = new Token("Uniswooop", "USWP", 100_000e18);
        exchange = new Exchange(address(token));

        token.transfer(ALICE, 10_000e18);
        vm.stopPrank();
    }

    // Initial supply - amount sent to Alice
    function test_AdminOwnsInitialSupply() public {
        assertEq(token.balanceOf(ADMIN), 90_000e18);
        assertEq(token.balanceOf(address(exchange)), 0);
    }

    function test_addLiquidity_OnlyToken(uint256 _tokenAmount) public {
        uint256 exchangeTokenBalanceBefore = token.balanceOf(address(exchange));
        uint256 aliceTokenBalanceBefore = token.balanceOf(address(ALICE));

        // Token amount is bounded to prevent wasted runs due to reverts like:
        // "ERC20: transfer amount exceeds balance"
        _tokenAmount = bound(_tokenAmount, 0, aliceTokenBalanceBefore);

        _addLiquidity(0, _tokenAmount, ALICE);

        uint256 exchangeTokenBalanceAfter = token.balanceOf(address(exchange));
        uint256 aliceTokenBalanceAfter = token.balanceOf(address(ALICE));

        assertEq(exchangeTokenBalanceAfter, exchangeTokenBalanceBefore + _tokenAmount);
        assertEq(aliceTokenBalanceAfter, aliceTokenBalanceBefore - _tokenAmount);
    }

    function test_addLiquidity_EthAndToken(uint256 _tokenAmount, uint256 _ethAmount) public {
        uint256 exchangeTokenBalanceBefore = token.balanceOf(address(exchange));
        uint256 exchangeEthBalanceBefore = address(exchange).balance;

        uint256 aliceTokenBalanceBefore = token.balanceOf(address(ALICE));
        uint256 aliceEthBalanceBefore = address(ALICE).balance;

        // Token amount is bounded to prevent wasted runs due to reverts like:
        // "ERC20: transfer amount exceeds balance"
        // The same goes for ETH
        _tokenAmount = bound(_tokenAmount, 0, aliceTokenBalanceBefore);
        _ethAmount = bound(_ethAmount, 0, aliceEthBalanceBefore);

        _addLiquidity(_ethAmount, _tokenAmount, ALICE);

        uint256 exchangeTokenBalanceAfter = token.balanceOf(address(exchange));
        uint256 exchangeEthBalanceAfter = address(exchange).balance;

        uint256 aliceEthBalanceAfter = address(ALICE).balance;
        uint256 aliceTokenBalanceAfter = token.balanceOf(address(ALICE));

        assertEq(exchangeTokenBalanceAfter, exchangeTokenBalanceBefore + _tokenAmount);
        assertEq(aliceTokenBalanceAfter, aliceTokenBalanceBefore - _tokenAmount);

        assertEq(exchangeEthBalanceAfter, exchangeEthBalanceBefore + _ethAmount);
        assertEq(aliceEthBalanceAfter, aliceEthBalanceBefore - _ethAmount);
    }

    function test_getEthAmount_twoTimesMoreTokensThanEth() public {
        uint256 _ethInputAmount = 1e18;
        uint256 _tokenInputAmount = 2e18;

        deal(ALICE, _ethInputAmount);

        _addLiquidity(_ethInputAmount, _tokenInputAmount, ALICE);

        uint256 ethAmount = exchange.getEthAmount({_tokenInputAmount: 1e18});

        assertEq(ethAmount, 0.5e18);
    }

    ////////////////////////////////////////////////////////////////////
    //                            Helpers                             //
    ////////////////////////////////////////////////////////////////////

    function _addLiquidity(uint256 _ethToAdd, uint256 _tokenToAdd, address _actor) private {
        vm.startPrank(_actor);
        token.approve(address(exchange), _tokenToAdd);
        exchange.addLiquidity{value: _ethToAdd}(_tokenToAdd);
        vm.stopPrank();
    }
}
