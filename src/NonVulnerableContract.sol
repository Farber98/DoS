// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract NonVulnerableContract {
    address public king;
    uint256 public kingBalance;
    mapping(address => uint256) balance;

    function claimThrone() external payable {
        require(msg.value > kingBalance, "Need to pay more to become the king");

        balance[king] += kingBalance;

        kingBalance = msg.value;
        king = msg.sender;
    }

    function claimFunds() external {
        require(msg.sender != king, "Not king.");
        uint256 bal = balance[msg.sender];
        require(bal > 0, "Nothing to withdraw.");

        balance[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
    }
}
