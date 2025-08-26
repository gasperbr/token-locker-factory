# Token Locker

A simple time-locked token wrapper system that allows users to lock tokens for a specified period.

## Contracts

**TokenWrapperFactory** - Creates new wrappers

- Auto-generates names with dates
- Quarter-based symbols (Q1, Q2, etc.)

**TokenWrapper** - The main wrapper contract

- Lock tokens for a specific time period
- No early withdrawals
- 1:1 exchange rate with underlying token after unlock date passes

## Usage

Deploy wrapper:

1. Call `deployWrapper(address, string, uint256)` with the underlying token address, prefix and unlock date (unix timestamp)

Lock tokens:

1. `approve()` the wrapper contract
2. Call `wrap(amount)`

Unlock tokens:

1. Wait until unlock time
2. Call `unwrapTo(recipient, amount)` from the token holder

## Deployments

See the broadcast directory to find the deployments.

## Test

```bash
forge test
```
