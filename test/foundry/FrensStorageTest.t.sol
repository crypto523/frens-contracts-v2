// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/*
 test command:
 forge test --via-ir --fork-url https://mainnet.infura.io/v3/7b367f3e8f1d48e5b43e1b290a1fde16
*/

import "forge-std/Test.sol";

//Frens Contracts
import "../../contracts/FrensStorage.sol";

contract FrensStorageTest is Test {
    FrensStorage public frensStorage;

    address payable public alice =
        payable(0x00000000000000000000000000000000000A11cE);
    address payable public bob =
        payable(0x0000000000000000000000000000000000000B0b);

    function setUp() public {
        //deploy storage
        frensStorage = new FrensStorage();
    }

    function testSetGuardian() public {
        // setGuardian
        frensStorage.setGuardian(alice);
        //
        startHoax(alice);
        frensStorage.confirmGuardian();
        frensStorage.burnKeys();
        startHoax(bob);
        vm.expectRevert("Account is not a guardian");
        frensStorage.setGuardian(bob);
    }

    function testBool() public {
        frensStorage.setBool(
            keccak256(abi.encodePacked("test.bool", "mybool")),
            true
        );
        bool f = frensStorage.getBool(
            keccak256(abi.encodePacked("test.bool", "mybool"))
        );

        assertEq(f, true);
    }

    function testMisc() public {
        frensStorage.deleteAddress(
            keccak256(abi.encodePacked("test.address", "0x0"))
        );
        frensStorage.deleteBool(keccak256(abi.encodePacked("test.bool")));
        frensStorage.deleteUint(
            keccak256(abi.encodePacked("test.number", "0x0"))
        );
        frensStorage.addUint(
            keccak256(abi.encodePacked("test.number")),
            uint256(1)
        );
        frensStorage.subUint(
            keccak256(abi.encodePacked("test.number")),
            uint256(1)
        );
    }
}
