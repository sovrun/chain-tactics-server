// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseMatchSystem_Test } from "../BaseMatchSystem.t.sol";
import { console } from "forge-std/console.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";

import { SystemIds } from "src/libraries/SystemIds.sol";

import { TTW_NAMESPACES, MATCH_SYSTEM, BUY_PREP_TIME, SPAWN_PREP_TIME, GOLD_BALANCE } from "src/common/constants.sol";
import { MatchStatusTypes, MatchPlayerStatusTypes, PlayerStatusTypes, SpawnStatusTypes } from "src/common/types.sol";

import { MatchConfig, MatchConfigData } from "src/codegen/tables/MatchConfig.sol";
import { MatchPlayerSurrenders } from "src/codegen/tables/MatchPlayerSurrenders.sol";
import { SpawnStatus } from "src/codegen/tables/SpawnStatus.sol";
import { MatchPreparationTime } from "src/codegen/tables/MatchPreparationTime.sol";
import { MatchPlayers } from "src/codegen/tables/MatchPlayers.sol";
import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
import { MatchPlayerStatus } from "src/codegen/tables/MatchPlayerStatus.sol";
import { MatchPool } from "src/codegen/tables/MatchPool.sol";
import { MatchWinner } from "src/codegen/tables/MatchWinner.sol";

import { PlayerStatus, PlayerStatusData } from "src/codegen/tables/PlayerStatus.sol";
import { Inventory } from "src/codegen/tables/Inventory.sol";
import { PlayerQueue } from "src/codegen/tables/PlayerQueue.sol";
import { PlayersInMatch } from "src/codegen/tables/PlayersInMatch.sol";

import { MatchSystem } from "src/systems/MatchSystem.sol";
import { Errors } from "src/common/Errors.sol";

import { playerFromAddress } from "src/libraries/LibUtils.sol";

import { MatchStatus } from "src/codegen/tables/MatchStatus.sol";
import { Player } from "src/codegen/tables/Player.sol";

import { LibEntity } from "src/libraries/LibEntity.sol";
import { LibPlayerStatusType } from "src/libraries/types/LibPlayerStatusType.sol";
import { LibMatchPlayerStatusType } from "src/libraries/types/LibMatchPlayerStatusType.sol";
import { LibMatchStatusType } from "src/libraries/types/LibMatchStatusType.sol";
import { LibSpawnStatusType } from "src/libraries/types/LibSpawnStatusType.sol";

contract ClaimVictory_Unit_Concrete_Test is BaseMatchSystem_Test {
    using LibEntity for address payable;
    using LibEntity for bytes32;

    using LibPlayerStatusType for PlayerStatusTypes;
    using LibPlayerStatusType for uint8;

    using LibMatchPlayerStatusType for MatchPlayerStatusTypes;
    using LibMatchPlayerStatusType for uint8;

    using LibMatchStatusType for MatchStatusTypes;
    using LibMatchStatusType for uint8;

    using LibSpawnStatusType for SpawnStatusTypes;
    using LibSpawnStatusType for uint8;

    bytes32 constant boardEntity = keccak256(abi.encode("BoardEntity"));
    bytes32 constant modeEntity = keccak256(abi.encode("ModeEntity"));

    bytes32 queueEntity;
    bytes32 matchEntity;

    function setUp() public override {
        super.setUp();
        queueEntity = boardEntity.toQueueEntity(modeEntity);
        matchEntity = keccak256(
            abi.encodePacked(
                block.timestamp,
                queueEntity,
                users.alice.toPlayerEntity(),
                users.eve.toPlayerEntity()
            )
        );
    }

    function test_RevertGiven_MatchNotActive() public {
        changePrank(users.alice);
        vm.expectRevert(Errors.MatchNotActive.selector);
        _claimVictory(bytes32(0));
    }

    modifier givenMatchIsActive() {
        changePrank(users.alice);
        _joinQueue(boardEntity, modeEntity);
        changePrank(users.eve);
        _joinQueue(boardEntity, modeEntity);
        changePrank(users.alice);
        _setPlayerReadyAndStart(matchEntity);
        changePrank(users.eve);
        _setPlayerReadyAndStart(matchEntity);
        _;
    }

    function test_RevertGiven_PlayerNotInMatch() public givenMatchIsActive {
        changePrank(users.bob);
        vm.expectRevert(Errors.PlayerNotInMatch.selector);
        _claimVictory(matchEntity);
    }

    modifier givenCallerSpawnStatusNone() {
        changePrankToMudAdmin();
        // By default, the caller's {SpawnStatus} is set to {None}
        // Just set it to {None} for testing
        SpawnStatus.set(
            matchEntity,
            playerFromAddress(matchEntity, users.alice),
            SpawnStatusTypes.None.toUint8()
        );
        _;
    }

    function test_RevertGiven_PlayerSpawnStatusNone()
        public
        givenMatchIsActive
        givenCallerSpawnStatusNone
    {
        changePrank(users.alice);
        vm.expectRevert(Errors.PlayerSpawnStatusNone.selector);
        _claimVictory(matchEntity);
    }

    modifier givenOpponentIsStillActive() {
        changePrankToMudAdmin();
        SpawnStatus.set(
            matchEntity,
            playerFromAddress(matchEntity, users.alice),
            SpawnStatusTypes.Ready.toUint8()
        );
        SpawnStatus.set(
            matchEntity,
            playerFromAddress(matchEntity, users.eve),
            SpawnStatusTypes.Ready.toUint8()
        );

        vm.warp(block.timestamp + BUY_PREP_TIME + 1);
        _;
    }

    function test_RevertWhen_PreparationPhaseIsStillOngoing()
        public
        givenMatchIsActive
        givenOpponentIsStillActive
    {
        changePrank(users.alice);
        vm.expectRevert(Errors.OpponentActive.selector);
        _claimVictory(matchEntity);
    }

    function test_RevertWhen_PlayerStillActiveAfterPrepPhase()
        public
        givenMatchIsActive
        givenOpponentIsStillActive
    {
        // Eve match player entity
        bytes32 eveMatchPlayerEntity = playerFromAddress(
            matchEntity,
            users.eve
        );

        changePrankToMudAdmin();
        // Set eve spawn status to ready
        SpawnStatus.set(
            matchEntity,
            eveMatchPlayerEntity,
            SpawnStatusTypes.Ready.toUint8()
        );

        changePrank(users.alice);
        vm.expectRevert(Errors.OpponentActive.selector);
        _claimVictory(matchEntity);
    }

    modifier givenOpponentBecomeInActive() {
        changePrankToMudAdmin();
        SpawnStatus.set(
            matchEntity,
            playerFromAddress(matchEntity, users.alice),
            SpawnStatusTypes.LockCommitBuying.toUint8()
        );
        SpawnStatus.set(
            matchEntity,
            playerFromAddress(matchEntity, users.eve),
            SpawnStatusTypes.None.toUint8()
        );

        vm.warp(block.timestamp + BUY_PREP_TIME + 1);
        _;
    }

    function test_ClaimVictory()
        public
        givenMatchIsActive
        givenOpponentBecomeInActive
    {
        changePrank(users.alice);
        _claimVictory(matchEntity);

        // Assert opponent's {MatchPlayerSurrenders} status is set to true
        assertEq(
            MatchPlayerSurrenders.get(
                matchEntity,
                playerFromAddress(matchEntity, users.eve)
            ),
            true
        );

        // Assert that the caller (alice) is the winner
        assertEq(
            MatchWinner.get(matchEntity),
            playerFromAddress(matchEntity, users.alice)
        );

        // Assert that the {MatchStatus} is set to {Finished}
        assertEq(
            MatchStatus.get(matchEntity),
            MatchStatusTypes.Finished.toUint8()
        );

        // Assert that the player's {PlayerStatus} reset
        PlayerStatusData memory alicePlayerStatusData = PlayerStatus.get(
            users.alice.toPlayerEntity()
        );
        assertEq(alicePlayerStatusData.matchEntity, bytes32(0));
        assertEq(alicePlayerStatusData.matchPlayerEntity, bytes32(0));
        assertEq(
            alicePlayerStatusData.status.toPlayerStatusTypes().isNone(),
            true
        );

        PlayerStatusData memory evePlayerStatusData = PlayerStatus.get(
            users.eve.toPlayerEntity()
        );
        assertEq(evePlayerStatusData.matchEntity, bytes32(0));
        assertEq(evePlayerStatusData.matchPlayerEntity, bytes32(0));
        assertEq(
            evePlayerStatusData.status.toPlayerStatusTypes().isNone(),
            true
        );
    }
}
