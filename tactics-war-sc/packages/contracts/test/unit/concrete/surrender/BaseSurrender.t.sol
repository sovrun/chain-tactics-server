// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Base_Test } from "../../Base.t.sol";

import { console } from "forge-std/console.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { SystemIds } from "src/libraries/SystemIds.sol";

import { MatchPlayers } from "src/codegen/tables/MatchPlayers.sol";
import { ActivePlayer, ActivePlayerData } from "src/codegen/tables/ActivePlayer.sol";

import { createMatchEntity, createPlayerEntity, createPieceEntity, createFortress } from "src/utils/MatchEntityUtils.sol";
import { resetPlayerActions } from "src/utils/GameUtils.sol";

import { TTW_NAMESPACES } from "src/common/constants.sol";
import { ICombatSystem } from "src/systems/interfaces/ICombatSystem.sol";

contract BaseSurrender_Test is Base_Test {
    using SystemIds for bytes14;

    bytes32 internal matchEntity;

    bytes32 internal aliceEntity;
    bytes32 internal eveEntity;
    bytes32 internal bobEntity;

    function setUp() public override {
        Base_Test.setUp();

        changePrankToMudAdmin();

        matchEntity = createMatchEntity(keccak256("MatchEntity"));
        aliceEntity = createPlayerEntity(matchEntity, users.alice);
        eveEntity = createPlayerEntity(matchEntity, users.eve);
        bobEntity = createPlayerEntity(matchEntity, users.bob);

        // Set up match players
        bytes32[] memory players = new bytes32[](2);
        players[0] = aliceEntity;
        players[1] = eveEntity;
        MatchPlayers.set(matchEntity, players);

        // Set current active player
        ActivePlayer.set(
            matchEntity,
            ActivePlayerData({ playerIndex: 0, timestamp: block.timestamp })
        );
    }
}
