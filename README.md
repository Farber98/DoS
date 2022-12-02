# Denial of service vulnerability

The basic idea behind this vulnerability is to reject ether being sent from a smart contract. This is achieved by not defining fallback nor receive function inside a malicious smart contract that is used as a caller. This could prevent the rest of the logic inside the vulnerable smart contract to execute, forever.

## Reproduction

### 📜 Involves two smart contracts

    1. A vulnerable contract that tries to send ether.
    2. A malicious contract that doesn't define receive nor fallback function.

## How to prevent it

👁️ Use the Pull over Push pattern, making users withdraw their funds (pull) instead of sending (push) them.
