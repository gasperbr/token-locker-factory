pragma solidity ^0.8.4;

import {TokenWrapper} from "./TokenWrapper.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {DateTimeLib} from "solady/utils/DateTimeLib.sol";
import {LibString} from "solady/utils/LibString.sol";

/// @title TokenWrapperFactory - Factory for creating time-locked token wrappers
/// @notice Creates TokenWrapper contracts with formatted names and symbols based on unlock dates
contract TokenWrapperFactory {
    using DateTimeLib for uint256;
    using LibString for uint256;

    event TokenWrapperDeployed(ERC20 underlyingToken, TokenWrapper tokenWrapper, uint256 unlockTime);

    /// @notice Deploy a new TokenWrapper with auto-generated name and symbol
    /// @param underlyingToken The token to be wrapped
    /// @param prefix Prefix for the wrapper token symbol
    /// @param unlockTime Timestamp when tokens can be unwrapped
    /// @return tokenWrapper The deployed TokenWrapper contract
    function deployWrapper(ERC20 underlyingToken, string memory prefix, uint256 unlockTime)
        external
        returns (TokenWrapper tokenWrapper)
    {
        (uint256 year, uint256 month, uint256 day) = unlockTime.timestampToDate();
        string memory yearStr = year.toString();
        string memory shortenedYearStr = (year % 100).toString();
        string memory monthStr = _getMonthAbbreviation(month);
        string memory quarterStr = string.concat("Q", (1 + (month - 1) / 3).toString());
        string memory dayStr = day.toString();

        // Generate name and symbol with date formatting
        string memory tokenSymbol = string.concat(prefix, underlyingToken.symbol(), " ", shortenedYearStr, quarterStr);
        string memory tokenName = string.concat(underlyingToken.name(), " ", monthStr, "/", dayStr, "/", yearStr);

        tokenWrapper = new TokenWrapper(underlyingToken, tokenName, tokenSymbol, unlockTime);

        emit TokenWrapperDeployed(underlyingToken, tokenWrapper, unlockTime);
    }

    // Returns the 3-letter month abbreviation for a given month number (1-12)
    function _getMonthAbbreviation(uint256 month) internal pure returns (string memory) {
        if (month == 1) return "Jan";
        if (month == 2) return "Feb";
        if (month == 3) return "Mar";
        if (month == 4) return "Apr";
        if (month == 5) return "May";
        if (month == 6) return "Jun";
        if (month == 7) return "Jul";
        if (month == 8) return "Aug";
        if (month == 9) return "Sep";
        if (month == 10) return "Oct";
        if (month == 11) return "Nov";
        if (month == 12) return "Dec";
        return "";
    }
}
