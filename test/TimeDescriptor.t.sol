// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {toDescriptors} from "../src/TimeDescriptor.sol";
import {LibString} from "solady/utils/LibString.sol";

contract TimeDescriptorTest is Test {
    using LibString for *;

    function testToDescriptor() public pure {
        (string memory quarterLabel, string memory dateLabel) = toDescriptors(1756143502);
        assertEq(quarterLabel, "25Q3");
        assertEq(dateLabel, "Aug/25/2025");

        (quarterLabel, dateLabel) = toDescriptors(1772557200);
        assertEq(quarterLabel, "26Q1");
        assertEq(dateLabel, "Mar/3/2026");

        (quarterLabel, dateLabel) = toDescriptors(1775016000);
        assertEq(quarterLabel, "26Q2");
        assertEq(dateLabel, "Apr/1/2026");
    }

    function testNeverRevertsFollowsFormat(uint256 unlockTime) public pure {
        (string memory quarterLabel, string memory dateLabel) = toDescriptors(unlockTime);
        string[] memory quarterPieces = LibString.split(quarterLabel, "Q");
        assertEq(quarterPieces.length, 2);
        string[] memory datePieces = LibString.split(dateLabel, "/");
        assertEq(datePieces.length, 3);
    }
}
