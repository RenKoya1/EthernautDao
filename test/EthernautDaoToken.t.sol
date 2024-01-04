// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "../src/EthernautDaoToken/EthernautDaoToken.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract EthernautDaoTokenTest is Test {
    address alice;
    address contractAddress = 0xF3Cfa05F1eD0F5eB7A8080f1109Ad7E424902121;
    uint256 private constant WALLET_PRIVATE_KEY =
        uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
    address wallet = vm.addr(WALLET_PRIVATE_KEY);

    function setUp() public {
        string memory RPC = vm.envString("GOERLI_RPC_URL");
        vm.createSelectFork(RPC, 7318910);
        alice = makeAddr("alice");
    }

    function testEthernautDaoToken() public {
        EthernautDaoToken ethernautDaoToken = EthernautDaoToken(payable(contractAddress));
        vm.startPrank(wallet);

        uint256 balance = ethernautDaoToken.balanceOf(wallet);
        ethernautDaoToken.transfer(alice, balance);
        assertEq(ethernautDaoToken.balanceOf(wallet), 0);
        vm.stopPrank();
    }
}
