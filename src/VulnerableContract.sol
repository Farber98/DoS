// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
The goal of VulnerableContract is to become the king by sending more Ether than
the previous king. Previous king will be refunded with the amount of Ether
he sent.
*/

/*
1. Deploy VulnerableContract
2. Alice becomes the king by sending 1 Ether to claimThrone().
2. Bob becomes the king by sending 2 Ether to claimThrone().
   Alice receives a refund of 1 Ether.
3. Deploy MaliciousContract with address of VulnerableContract.
4. Call attack with 3 Ether.
5. Current king is the Attack contract and no one can become the new king.

What happened?
MaliciousContract became the king. All new challenge to claim the throne will be rejected
since MaliciousContract contract does not have a fallback function, denying to accept the
Ether sent from VulnerableContract before the new king is set.
*/

contract VulnerableContract {
    address public king;
    uint256 public balance;

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        (bool sent, ) = king.call{value: balance}("");
        require(sent, "Failed to send Ether");

        balance = msg.value;
        king = msg.sender;
    }
}
