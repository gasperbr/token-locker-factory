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
2. Call `unwrap(amount)`

## Deployments

**Ethereum Mainnet**

Factory: `0xBB8D6719EC7a56EF0a13d935453B5ebB7B99cc09`

gEKUBO-26Q1: `0x641849aEf20Ab4c52EE8dDcbB1F0139aA77d13bF`

- Underlying: EKUBO (`0x04C46E830Bb56ce22735d5d8Fc9CB90309317d0f`)
- Unlocks: March 31, 2026

## Test

```bash
forge test
```
