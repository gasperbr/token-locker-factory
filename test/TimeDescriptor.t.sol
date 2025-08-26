// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {toQuarter, toDate} from "../src/TimeDescriptor.sol";
import {LibString} from "solady/utils/LibString.sol";

contract TimeDescriptorTest is Test {
    using LibString for *;

    function testToDate() public pure {
        string memory dateLabel = toDate(1756143502);
        assertEq(dateLabel, "Aug/25/2025");

        dateLabel = toDate(1772557200);
        assertEq(dateLabel, "Mar/3/2026");

        dateLabel = toDate(1775016000);
        assertEq(dateLabel, "Apr/1/2026");
    }

    function testToQuarter() public pure {
        string memory quarterLabel = toQuarter(1756143502);
        assertEq(quarterLabel, "25Q3");

        quarterLabel = toQuarter(1772557200);
        assertEq(quarterLabel, "26Q1");

        quarterLabel = toQuarter(1775016000);
        assertEq(quarterLabel, "26Q2");
    }

    function testNeverRevertsFollowsFormat(uint256 unlockTime) public pure {
        string memory quarterLabel = toQuarter(unlockTime);
        string[] memory quarterPieces = LibString.split(quarterLabel, "Q");
        assertEq(quarterPieces.length, 2);

        string memory dateLabel = toDate(unlockTime);
        string[] memory datePieces = LibString.split(dateLabel, "/");
        assertEq(datePieces.length, 3);
    }
}
