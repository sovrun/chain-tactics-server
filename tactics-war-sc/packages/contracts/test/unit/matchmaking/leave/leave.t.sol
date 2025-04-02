// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseMatchSystem_Test } from "../BaseMatchSystem.t.sol";
import { console } from "forge-std/console.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";

import { SystemIds } from "src/libraries/SystemIds.sol";

import { TTW_NAMESPACES, MATCH_SYSTEM, BUY_PREP_TIME, SPAWN_PREP_TIME } from "src/common/constants.sol";
import { MatchStatusTypes, MatchPlayerStatusTypes, PlayerStatusTypes, SpawnStatusTypes } from "src/common/types.sol";

import { MatchConfig, MatchConfigData } from "src/codegen/tables/MatchConfig.sol";
import { MatchPlayerSurrenders } from "src/codegen/tables/MatchPlayerSurrenders.sol";
import { MatchPlayers } from "src/codegen/tables/MatchPlayers.sol";
import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
import { MatchPlayerStatus } from "src/codegen/tables/MatchPlayerStatus.sol";
import { SpawnStatus } from "src/codegen/tables/SpawnStatus.sol";
import { MatchPool } from "src/codegen/tables/MatchPool.sol";
import { MatchWinner } from "src/codegen/tables/MatchWinner.sol";

import { PlayerStatus, PlayerStatusData } from "src/codegen/tables/PlayerStatus.sol";
import { Inventory } from "src/codegen/tables/Inventory.sol";
import { PlayerQueue } from "src/codegen/tables/PlayerQueue.sol";
import { PlayersInMatch } from "src/codegen/tables/PlayersInMatch.sol";
import { MatchPreparationTime } from "src/codegen/tables/MatchPreparationTime.sol";

import { MatchSystem } from "src/systems/MatchSystem.sol";
import { Errors } from "src/common/Errors.sol";

import { playerFromAddress } from "src/libraries/LibUtils.sol";

import { MatchStatus } from "src/codegen/tables/MatchStatus.sol";
import { Player } from "src/codegen/tables/Player.sol";

import { GOLD_BALANCE } from "src/common/constants.sol";

import { LibEntity } from "src/libraries/LibEntity.sol";
import { LibPlayerStatusType } from "src/libraries/types/LibPlayerStatusType.sol";
import { LibMatchPlayerStatusType } from "src/libraries/types/LibMatchPlayerStatusType.sol";
import { LibMatchStatusType } from "src/libraries/types/LibMatchStatusType.sol";
import { LibSpawnStatusType } from "src/libraries/types/LibSpawnStatusType.sol";

contract Leave_Unit_Concrete_Test is BaseMatchSystem_Test {
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

    bytes32 queueEntity = boardEntity.toQueueEntity(modeEntity);
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

    function test_RevertGiven_NotInQueueOrMatch() public {
        changePrank(users.alice);
        vm.expectRevert(Errors.NotInQueueOrMatch.selector);
        _leave();
    }

    modifier givenPlayerIsInQueue() {
        changePrank(users.alice);
        bytes32 playerEntity = users.alice.toPlayerEntity();
        _joinQueue(boardEntity, modeEntity);

        _;
    }

    function test_LeaveQueue() public givenPlayerIsInQueue {
        bytes32 playerEntity = users.alice.toPlayerEntity();

        // Assert that player is in queue
        assertEq(PlayerQueue.get(playerEntity), queueEntity);
        assertEq(
            PlayerStatus
                .get(playerEntity)
                .status
                .toPlayerStatusTypes()
                .isQueueing(),
            true
        );

        _leave();
        // Assert that player is no longer in queue
        assertEq(PlayerQueue.get(playerEntity), bytes32(0));
        assertEq(MatchPool.get(queueEntity).length, 0);

        // Assert that player status is set to None
        assertEq(
            PlayerStatus
                .get(playerEntity)
                .status
                .toPlayerStatusTypes()
                .isNone(),
            true
        );
    }

    function test_RevertWhen_PlayerLeftTheQueue() public givenPlayerIsInQueue {
        changePrank(users.alice);
        _leave();
        vm.expectRevert(Errors.NotInQueueOrMatch.selector);
        _leave();
    }

    modifier givenMatchIsInProgress() {
        changePrank(users.alice);
        _joinQueue(boardEntity, modeEntity);
        changePrank(users.eve);
        _joinQueue(boardEntity, modeEntity);

        _;
    }

    function test_Leave_CancelMatch() public givenMatchIsInProgress {
        // Assert match is in progress
        assertEq(
            MatchStatus
                .get(matchEntity)
                .toMatchStatusTypes()
                .isGameInProgress(),
            true
        );

        changePrank(users.alice);
        _leave();

        assertEq(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isCancelled(),
            true
        );

        // Assert player status is reset to None and
        // matchPlayerEntity and matchEntity are reset to 0
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

    function test_RevertWhen_PlayerAlreadyLeft() public givenMatchIsInProgress {
        changePrank(users.alice);
        _leave();
        vm.expectRevert(Errors.NotInQueueOrMatch.selector);
        _leave();
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
        // Emulate when the match is ready
        MatchPreparationTime.set(
            matchEntity,
            block.timestamp + SPAWN_PREP_TIME
        );

        vm.warp(block.timestamp + SPAWN_PREP_TIME + 1);

        _;
    }

    function test_Leave_Surrender() public givenMatchIsActive {
        // Assert match is active
        assertEq(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isActive(),
            true
        );

        changePrank(users.alice);
        _leave();

        // Assert that alice has surrendered
        bytes32 matchPlayerEntity = MatchPlayer.get(matchEntity, users.alice);
        assertEq(
            MatchPlayerSurrenders.get(matchEntity, matchPlayerEntity),
            true
        );

        // Assert that Eve wins the match after Alice surrender
        bytes32 eveMatchPlayerEntity = MatchPlayer.get(matchEntity, users.eve);
        bytes32 expectedValue = MatchWinner.get(matchEntity);
        assertEq(eveMatchPlayerEntity, expectedValue);

        // Assert the player's status is reset to None and
        //  matchPlayerEntity and matchEntity are reset to 0
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

    function test_RevertWhen_PlayerAlreadySurrendered()
        public
        givenMatchIsActive
    {
        changePrank(users.alice);
        _leave();
        vm.expectRevert(Errors.NotInQueueOrMatch.selector);
        _leave();
    }

    function test_Leave_PreparationPhase() public givenMatchIsActive {
        vm.warp(block.timestamp + SPAWN_PREP_TIME - 1 minutes);

        // Assert match is active
        assertEq(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isActive(),
            true
        );

        changePrank(users.alice);
        _leave();

        // Assert that alice has surrendered
        bytes32 matchPlayerEntity = MatchPlayer.get(matchEntity, users.alice);
        assertEq(
            MatchPlayerSurrenders.get(matchEntity, matchPlayerEntity),
            true
        );

        // Assert that Eve wins the match after Alice surrender
        bytes32 eveMatchPlayerEntity = MatchPlayer.get(matchEntity, users.eve);
        bytes32 expectedValue = MatchWinner.get(matchEntity);
        assertEq(eveMatchPlayerEntity, expectedValue);

        // Assert the player's status is reset to None and
        //  matchPlayerEntity and matchEntity are reset to 0
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

        // Assert that the match is finished
        assertEq(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isFinished(),
            true
        );
    }

    function test_Leave_OpponentDidntMakeCommitment()
        public
        givenMatchIsActive
    {
        changePrankToMudAdmin();
        // Eve doesn't commit
        SpawnStatus.set(
            matchEntity,
            playerFromAddress(matchEntity, users.eve),
            SpawnStatusTypes.None.toUint8()
        );

        // Assert match is active
        assertEq(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isActive(),
            true
        );

        changePrank(users.alice);
        _leave();

        // Assert that alice is the winner
        bytes32 actualValue = MatchWinner.get(matchEntity);
        bytes32 expectedValue = MatchPlayer.get(matchEntity, users.alice);
        assertEq(actualValue, expectedValue);

        // Assert the player's status is reset
        // Assert the player's status is reset to None and
        //  matchPlayerEntity and matchEntity are reset to 0
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

        // Assert that the match is finished
        assertEq(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isFinished(),
            true
        );

        // Assert that the match is finished
        assertEq(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isFinished(),
            true
        );
    }

    function test_Leave_BothPlayersDidntMakeCommitment()
        public
        givenMatchIsActive
    {
        // Both players don't make a commitment
        changePrankToMudAdmin();
        SpawnStatus.set(
            matchEntity,
            playerFromAddress(matchEntity, users.alice),
            SpawnStatusTypes.None.toUint8()
        );
        SpawnStatus.set(
            matchEntity,
            playerFromAddress(matchEntity, users.eve),
            SpawnStatusTypes.None.toUint8()
        );

        // Assert match is active
        assertEq(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isActive(),
            true
        );

        changePrank(users.alice);
        _leave();

        // Assert the player's status is reset to None and
        //  matchPlayerEntity and matchEntity are reset to 0
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

        // Assert that the match is cancelled
        assertEq(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isCancelled(),
            true
        );

        // Assert that no one wins
        bytes32 actualValue = MatchWinner.get(matchEntity);
        bytes32 expectedValue = bytes32(0);
        assertEq(actualValue, expectedValue, "Match winner should be 0");
    }

    function test_LeavesAfterClientTriggerDelay() public givenMatchIsActive {
        changePrankToMudAdmin();

        SpawnStatus.set(
            matchEntity,
            playerFromAddress(matchEntity, users.alice),
            SpawnStatusTypes.RevealBuying.toUint8()
        );

        SpawnStatus.set(
            matchEntity,
            playerFromAddress(matchEntity, users.eve),
            SpawnStatusTypes.RevealBuying.toUint8()
        );

        vm.warp(block.timestamp + BUY_PREP_TIME - 10 seconds);

        changePrank(users.alice);
        _leave();

        // Assert match is active
        assertEq(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isCancelled(),
            true
        );

        // Assert the player's status is reset to None and
        //  matchPlayerEntity and matchEntity are reset to 0
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

        // Assert that the match is cancelled
        assertEq(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isCancelled(),
            true
        );

        // Assert that no one wins
        bytes32 actualValue = MatchWinner.get(matchEntity);
        bytes32 expectedValue = bytes32(0);
        assertEq(actualValue, expectedValue, "Match winner should be 0");
    }
}
