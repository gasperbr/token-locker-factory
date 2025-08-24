pragma solidity ^0.8.4;

import {ERC20} from "solady/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

/// @title TokenWrapper - Time-locked token wrapper
/// @notice Wraps tokens that can only be unwrapped after a specific unlock time
contract TokenWrapper is ERC20 {
    using SafeTransferLib for address;

    /// @notice The underlying token being wrapped
    ERC20 public immutable underlyingToken;
    /// @notice Timestamp when tokens can be unwrapped
    uint256 public immutable unlockTime;

    string private _name;
    string private _symbol;
    uint8 private immutable _decimals;

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /// @notice Thrown when trying to unwrap before unlock time
    error TooEarly();

    constructor(ERC20 _underlyingToken, string memory tokenName, string memory tokenSymbol, uint256 _unlockTime) {
        underlyingToken = _underlyingToken;
        unlockTime = _unlockTime;
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = underlyingToken.decimals();
    }

    /// @notice Wrap underlying tokens to receive wrapper tokens
    function wrap(uint256 amount) external {
        address(underlyingToken).safeTransferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    function unwrap(uint256 amount) external {
        unwrapTo(msg.sender, amount);
    }

    /// @notice Unwrap tokens to receive underlying tokens (only after unlock time)
    function unwrapTo(address recipient, uint256 amount) public {
        if (block.timestamp < unlockTime) revert TooEarly();
        _burn(msg.sender, amount);
        address(underlyingToken).safeTransfer(recipient, amount);
    }
}
