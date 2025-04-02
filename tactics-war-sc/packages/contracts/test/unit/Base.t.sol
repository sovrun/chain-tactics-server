//SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";

import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";

import { ROOT_NAMESPACE, ROOT_NAMESPACE_ID } from "@latticexyz/world/src/constants.sol";
import { NamespaceOwner } from "@latticexyz/world/src/codegen/tables/NamespaceOwner.sol";

import { SystemBuilder } from "./SystemBuilder.t.sol";

struct Users {
    // Default admin for creatorverse contracts.
    address payable admin;
    // Impartial user.
    address payable alice;
    address payable bob;
    address payable charlie;
    // Malicious user.
    address payable eve;
}

contract Base_Test is MudTest {
    IWorld internal world;
    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    modifier whenCallerAdmin() {
        changePrank(users.admin);
        _;
    }

    modifier whenCallerAlice() {
        changePrank(users.alice);
        _;
    }

    modifier whenCallerEve() {
        changePrank(users.eve);
        _;
    }

    function setUp() public virtual override {
        MudTest.setUp();
        // Users for testing
        users = Users({
            admin: createUser("Admin"),
            alice: createUser("Alice"),
            bob: createUser("Bob"),
            charlie: createUser("Charlie"),
            eve: createUser("Eve")
        });

        world = IWorld(worldAddress);

        vm.label({ account: address(world), newLabel: "World Address" });
    }

    function createUser(string memory name) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.label({ account: user, newLabel: name });
        vm.deal({ account: user, newBalance: 100 ether });
        return user;
    }

    function changePrank(address msgSender) internal override {
        vm.stopPrank();
        vm.startPrank(msgSender);
    }

    function changePrankToMudAdmin() internal {
        changePrank(NamespaceOwner.get(ROOT_NAMESPACE_ID));
    }

    function visualizeBoard(
        uint startX,
        uint startY,
        uint targetX,
        uint targetY,
        bool isValid
    ) internal view {
        console.log("Board Visualization:");
        for (uint x = 1; x <= 6; x++) {
            string memory row = "";
            for (uint y = 1; y <= 6; y++) {
                if (x == startX && y == startY) {
                    row = string(abi.encodePacked(row, " U ")); // Unit position
                } else if (x == targetX && y == targetY) {
                    if (isValid) {
                        row = string(abi.encodePacked(row, " V ")); // Valid attack position
                    } else {
                        row = string(abi.encodePacked(row, " X ")); // Invalid attack position
                    }
                } else {
                    row = string(abi.encodePacked(row, " . ")); // Empty space
                }
            }
            console.log(row); // Print the entire row as a single string
        }
        console.log("-----------------------------"); // Separator for clarity
    }
}
