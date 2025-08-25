pragma solidity ^0.8.4;

import {TokenWrapper} from "./TokenWrapper.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {toDescriptors} from "./TimeDescriptor.sol";

/// @title TokenWrapperFactory - Factory for creating time-locked token wrappers
/// @notice Creates TokenWrapper contracts with formatted names and symbols based on unlock dates
contract TokenWrapperFactory {
    event TokenWrapperDeployed(ERC20 underlyingToken, uint256 unlockTime, TokenWrapper tokenWrapper);

    /// @notice Deploy a new TokenWrapper with auto-generated name and symbol
    /// @param underlyingToken The token to be wrapped
    /// @param prefix Prefix for the wrapper token symbol
    /// @param unlockTime Timestamp when tokens can be unwrapped
    /// @return tokenWrapper The deployed TokenWrapper contract
    function deployWrapper(ERC20 underlyingToken, string memory prefix, uint256 unlockTime)
        external
        returns (TokenWrapper tokenWrapper)
    {
        (string memory quarterLabel, string memory dateLabel) = toDescriptors(unlockTime);

        // Generate name and symbol with date formatting
        string memory tokenSymbol = string.concat(prefix, underlyingToken.symbol(), " ", quarterLabel);
        string memory tokenName = string.concat(underlyingToken.name(), " ", dateLabel);

        bytes32 salt = keccak256(abi.encode(underlyingToken, unlockTime));

        tokenWrapper = new TokenWrapper{salt: salt}(underlyingToken, tokenName, tokenSymbol, unlockTime);

        emit TokenWrapperDeployed(underlyingToken, unlockTime, tokenWrapper);
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
