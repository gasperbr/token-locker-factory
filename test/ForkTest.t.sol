// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {TokenWrapper} from "../src/TokenWrapper.sol";
import {TokenWrapperFactory} from "../src/TokenWrapperFactory.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {LibString} from "solady/utils/LibString.sol";

contract ForkTest is Test {
    using LibString for *;

    ERC20 ekubo = ERC20(0x04C46E830Bb56ce22735d5d8Fc9CB90309317d0f);
    TokenWrapper wrapper;

    uint256 unlockTime;

    address user = makeAddr("user");

    function setUp() public {
        vm.createSelectFork("https://eth.llamarpc.com");

        unlockTime = vm.getBlockTimestamp() + 86_400; // one day from now

        // Create the wrapper
        TokenWrapperFactory factory = new TokenWrapperFactory();
        wrapper = factory.deployWrapper(ekubo, "g", unlockTime);

        // Give user some EKUBO tokens for testing
        deal(address(ekubo), user, 100e18);

        // Approve the wrapper
        vm.prank(user);
        ekubo.approve(address(wrapper), type(uint256).max);
    }

    function testWrapperInfo() public view {
        assertTrue(wrapper.symbol().startsWith("gEKUBO "));
        assertTrue(wrapper.name().startsWith("Ekubo Protocol "));
        assertEq(wrapper.unlockTime(), unlockTime);
    }

    function testWrapUnwrap() public {
        uint256 wrapAmount = 75e18;
        uint256 initialBalance = ekubo.balanceOf(user);

        assertEq(initialBalance, 100e18);

        // Lock tokens
        vm.prank(user);
        wrapper.wrap(wrapAmount);

        assertEq(wrapper.balanceOf(user), 75e18);
        assertEq(ekubo.balanceOf(user), 25e18);

        // Try to unlock early (should fail)
        vm.expectRevert(TokenWrapper.TooEarly.selector);
        vm.prank(user);
        wrapper.unwrap(wrapAmount);

        // Fast forward to unlock time
        vm.warp(wrapper.unlockTime());

        // Unlock tokens
        vm.prank(user);
        wrapper.unwrap(wrapAmount);

        assertEq(ekubo.balanceOf(user), initialBalance);
        assertEq(wrapper.balanceOf(user), 0);
    }
}
