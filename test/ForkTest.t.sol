// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {TokenWrapper} from "../src/TokenWrapper.sol";
import {ERC20} from "solady/tokens/ERC20.sol";

contract ForkTest is Test {
    TokenWrapper public wrapper = TokenWrapper(0x641849aEf20Ab4c52EE8dDcbB1F0139aA77d13bF);
    ERC20 public ekubo = ERC20(0x04C46E830Bb56ce22735d5d8Fc9CB90309317d0f);

    address user = makeAddr("user");

    function setUp() public {
        vm.createSelectFork("https://eth.llamarpc.com");
        // Give user some EKUBO tokens for testing
        deal(address(ekubo), user, 100e18);
        vm.prank(user);
        ekubo.approve(address(wrapper), type(uint256).max);
    }

    function testWrapperInfo() public view {
        console.log("Wrapper name:", wrapper.name());
        console.log("Wrapper symbol:", wrapper.symbol());
        console.log("Unlock time:", wrapper.unlockTime());
        console.log("Current time:", block.timestamp);

        assertEq(wrapper.symbol(), "gEKUBO 26Q1");
        assertEq(wrapper.name(), "Ekubo Protocol Mar/31/2026");
        assertEq(wrapper.unlockTime(), 1774915200);
    }

    function testWrapUnwrap() public {
        uint256 wrapAmount = 50e18;
        uint256 initialBalance = ekubo.balanceOf(user);

        console.log("Initial EKUBO balance:", initialBalance / 1e18);

        // Lock tokens
        vm.prank(user);
        wrapper.wrap(wrapAmount);

        console.log("Wrapped", wrapAmount / 1e18, "EKUBO");
        console.log("Wrapper balance:", wrapper.balanceOf(user) / 1e18);

        // Try to unlock early (should fail)
        vm.expectRevert(TokenWrapper.TooEarly.selector);
        vm.prank(user);
        wrapper.unwrap(wrapAmount);

        console.log("Early unlock correctly blocked");

        // Fast forward to unlock time
        vm.warp(wrapper.unlockTime());
        console.log("Time warped to unlock time");

        // Unlock tokens
        vm.prank(user);
        wrapper.unwrap(wrapAmount);

        assertEq(ekubo.balanceOf(user), initialBalance);
        assertEq(wrapper.balanceOf(user), 0);

        console.log("Full cycle complete - tokens unlocked successfully");
    }
}
