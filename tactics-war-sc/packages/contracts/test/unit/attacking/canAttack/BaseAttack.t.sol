// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Base_Test } from "../../Base.t.sol";

import { console } from "forge-std/console.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { SystemIds } from "src/libraries/SystemIds.sol";

import { createMatchEntity, createPlayerEntity, createPieceEntity } from "src/utils/MatchEntityUtils.sol";
import { PieceLibrary } from "src/libraries/PieceLibrary.sol";
import { LibUnitCombat } from "src/libraries/LibUnitCombat.sol";

contract BaseAttack_Test is Base_Test {
    using LibUnitCombat for bytes32;
    using SystemIds for bytes14;

    bytes32 internal matchEntity;

    bytes32 internal aliceEntity;

    bytes32 internal footSoldierEntity;
    bytes32 internal lancerEntity;
    bytes32 internal priestEntity;
    bytes32 internal archerEntity;
    bytes32 internal fireMageEntity;
    bytes32 internal iceMageEntity;

    function setUp() public override {
        Base_Test.setUp();

        changePrankToMudAdmin();
        matchEntity = createMatchEntity(keccak256("MatchEntity"));
        aliceEntity = createPlayerEntity(matchEntity, users.alice);

        // cross
        (footSoldierEntity, ) = createPieceEntity(matchEntity, users.alice, 2);
        (lancerEntity, ) = createPieceEntity(matchEntity, users.alice, 3);
        (priestEntity, ) = createPieceEntity(matchEntity, users.alice, 4);
        // square
        (archerEntity, ) = createPieceEntity(matchEntity, users.alice, 5);
        (fireMageEntity, ) = createPieceEntity(matchEntity, users.alice, 6);
        // diagonal
        (iceMageEntity, ) = createPieceEntity(matchEntity, users.alice, 7);
    }
}
