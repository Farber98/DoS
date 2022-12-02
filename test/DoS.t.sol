// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/VulnerableContract.sol";
import "../src/NonVulnerableContract.sol";
import "../src/MaliciousContract.sol";

contract Reentrancy is Test {
    VulnerableContract vulnerable;
    NonVulnerableContract nonVulnerable;
    MaliciousContract maliciousVulnerable;
    MaliciousContract maliciousNonVulnerable;

    address payable vulnerableContractDeployer1 = payable(address(0x1));
    address payable maliciousContractDeployer2 = payable(address(0x2));
    address payable victim3 = payable(address(0x3));

    function setUp() public {
        vm.startPrank(vulnerableContractDeployer1);
        vulnerable = new VulnerableContract();
        vm.stopPrank();

        vm.startPrank(vulnerableContractDeployer1);
        nonVulnerable = new NonVulnerableContract();
        vm.stopPrank();

        vm.startPrank(maliciousContractDeployer2);
        maliciousVulnerable = new MaliciousContract(address(vulnerable));
        vm.stopPrank();

        vm.startPrank(maliciousContractDeployer2);
        maliciousNonVulnerable = new MaliciousContract(address(nonVulnerable));
        vm.stopPrank();
    }

    function testVulnerableContract() public {
        //victim sends funds
        vm.startPrank(victim3);
        vm.deal(victim3, 2 ether);
        vulnerable.claimThrone{value: 2 ether}();
        assertEq(vulnerable.king(), victim3);
        assertEq(vulnerable.balance(), 2 ether);
        vm.stopPrank();

        //malicious contract claims throne and victim gets funds back.
        vm.startPrank(maliciousContractDeployer2);
        vm.deal(maliciousContractDeployer2, 3 ether);
        maliciousVulnerable.attack{value: 3 ether}();
        assertEq(vulnerable.king(), address(maliciousVulnerable));
        assertEq(vulnerable.balance(), 3 ether);
        assertEq(victim3.balance, 2 ether);
        vm.stopPrank();

        //victim tries to reclaimthrone but this will fail to send eth forever.
        vm.startPrank(victim3);
        vm.deal(victim3, 4 ether);
        vm.expectRevert("Failed to send Ether");
        vulnerable.claimThrone{value: 4 ether}();
        vm.expectRevert("Failed to send Ether");
        vulnerable.claimThrone{value: 4 ether}();
        vm.expectRevert("Failed to send Ether");
        vulnerable.claimThrone{value: 4 ether}();
        assertEq(vulnerable.king(), address(maliciousVulnerable));
        assertEq(vulnerable.balance(), 3 ether);
        vm.stopPrank();
    }

    function testNonVulnerableContract() public {
        //victim sends funds
        vm.startPrank(victim3);
        vm.deal(victim3, 2 ether);
        nonVulnerable.claimThrone{value: 2 ether}();
        assertEq(nonVulnerable.king(), victim3);
        assertEq(nonVulnerable.kingBalance(), 2 ether);
        vm.stopPrank();

        //malicious contract claims throne.
        vm.startPrank(maliciousContractDeployer2);
        vm.deal(maliciousContractDeployer2, 3 ether);
        maliciousNonVulnerable.attack{value: 3 ether}();
        assertEq(nonVulnerable.king(), address(maliciousNonVulnerable));
        assertEq(nonVulnerable.kingBalance(), 3 ether);
        vm.stopPrank();

        // victim reclaim funds
        vm.startPrank(victim3);
        nonVulnerable.claimFunds();
        assertEq(victim3.balance, 2 ether);
        vm.stopPrank();

        //victim reclaims throne.
        vm.startPrank(victim3);
        vm.deal(victim3, 4 ether);
        nonVulnerable.claimThrone{value: 4 ether}();
        assertEq(nonVulnerable.king(), victim3);
        assertEq(nonVulnerable.kingBalance(), 4 ether);
        vm.stopPrank();

        // malicious contract tries to reclaim funds and gets himself denied.
        vm.startPrank(address(maliciousNonVulnerable));
        vm.expectRevert("Failed to send Ether");
        nonVulnerable.claimFunds();
        vm.stopPrank();
    }
}
