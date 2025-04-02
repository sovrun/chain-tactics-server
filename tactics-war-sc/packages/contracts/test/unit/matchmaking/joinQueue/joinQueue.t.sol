// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseMatchSystem_Test } from "../BaseMatchSystem.t.sol";
import { console } from "forge-std/console.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";

import { SystemIds } from "src/libraries/SystemIds.sol";

import { TTW_NAMESPACES, MATCH_SYSTEM } from "src/common/constants.sol";
import { MatchStatusTypes, MatchPlayerStatusTypes, PlayerStatusTypes } from "src/common/types.sol";

import { MatchConfig, MatchConfigData } from "src/codegen/tables/MatchConfig.sol";
import { MatchPlayers } from "src/codegen/tables/MatchPlayers.sol";
import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
import { MatchPlayerStatus } from "src/codegen/tables/MatchPlayerStatus.sol";
import { MatchPool } from "src/codegen/tables/MatchPool.sol";

import { PlayerStatus, PlayerStatusData } from "src/codegen/tables/PlayerStatus.sol";
import { PlayerQueue } from "src/codegen/tables/PlayerQueue.sol";
import { PlayersInMatch } from "src/codegen/tables/PlayersInMatch.sol";

import { MatchSystem } from "src/systems/MatchSystem.sol";
import { Errors } from "src/common/Errors.sol";

import { MatchStatus } from "src/codegen/tables/MatchStatus.sol";
import { Player } from "src/codegen/tables/Player.sol";

import { LibEntity } from "src/libraries/LibEntity.sol";
import { LibPlayerStatusType } from "src/libraries/types/LibPlayerStatusType.sol";
import { LibMatchPlayerStatusType } from "src/libraries/types/LibMatchPlayerStatusType.sol";
import { LibMatchStatusType } from "src/libraries/types/LibMatchStatusType.sol";

contract JoinQueue_Unit_Concrete_Test is BaseMatchSystem_Test {
    using LibEntity for address payable;
    using LibEntity for bytes32;

    using LibPlayerStatusType for PlayerStatusTypes;
    using LibPlayerStatusType for uint8;

    using LibMatchPlayerStatusType for MatchPlayerStatusTypes;
    using LibMatchPlayerStatusType for uint8;

    using LibMatchStatusType for MatchStatusTypes;
    using LibMatchStatusType for uint8;

    bytes32 constant boardEntity = keccak256(abi.encode("BoardEntity"));
    bytes32 constant modeEntity = keccak256(abi.encode("ModeEntity"));

    function test_RevertGiven_PlayerInQueue() public whenCallerAlice {
        _joinQueue(boardEntity, modeEntity);

        vm.expectRevert(Errors.PlayerAlreadyInQueue.selector);
        _joinQueue(boardEntity, modeEntity);
    }

    function test_RevertGiven_PlayerHasOnGoingMatch() public {
        changePrank(users.alice);
        _joinQueue(boardEntity, modeEntity);

        changePrank(users.eve);
        _joinQueue(boardEntity, modeEntity);

        vm.expectRevert(Errors.PlayerHasOngoingMatch.selector);
        changePrank(users.alice);
        _joinQueue(boardEntity, modeEntity);
    }

    modifier givenPlayerCanJoinQueue() {
        _;
    }

    function test_JoinQueue() public givenPlayerCanJoinQueue {
        changePrank(users.alice);
        _joinQueue(boardEntity, modeEntity);

        bytes32 playerEntity = users.alice.toPlayerEntity();

        assertEq(
            PlayerStatus
                .get(playerEntity)
                .status
                .toPlayerStatusTypes()
                .isQueueing(),
            true
        );

        bytes32 queueEntity = boardEntity.toQueueEntity(modeEntity);
        bytes32 actualValue = PlayerQueue.get(playerEntity);
        assertEq(actualValue, queueEntity);

        bytes32[] memory playerEntities = MatchPool.get(queueEntity);
        assertEq(playerEntities.length, 1);
        assertEq(playerEntities[0], playerEntity);
    }

    modifier givenMatchFound() {
        changePrank(users.alice);
        _joinQueue(boardEntity, modeEntity);
        changePrank(users.eve);
        _joinQueue(boardEntity, modeEntity);

        _;
    }

    function test_JoinQueue_WhenTwoPlayersJoin() public givenMatchFound {
        bytes32 queueEntity = boardEntity.toQueueEntity(modeEntity);
        bytes32 matchEntity = keccak256(
            abi.encodePacked(
                block.timestamp,
                queueEntity,
                users.alice.toPlayerEntity(),
                users.eve.toPlayerEntity()
            )
        );

        // Assert the MatchConfig is correctly created
        MatchConfigData memory config = MatchConfig.get(matchEntity);
        assertEq(config.boardEntity, boardEntity);
        assertEq(config.gameModeEntity, modeEntity);
        assertEq(config.playerCount, 2);
        assertEq(config.isPrivate, false);
        assertEq(config.createdBy, users.alice);

        // Assert that match players are correctly created and {MatchPlayerStatus} is set to {Match}
        bytes32[] memory matchPlyerEntities = MatchPlayers.get(matchEntity);
        assertEq(matchPlyerEntities.length, 2);
        assertEq(
            MatchPlayerStatus
                .getValue(matchEntity, matchPlyerEntities[0])
                .toMatchPlayerStatusTypes()
                .isPlayerInMatch(),
            true
        );
        assertEq(
            MatchPlayerStatus
                .getValue(matchEntity, matchPlyerEntities[1])
                .toMatchPlayerStatusTypes()
                .isPlayerInMatch(),
            true
        );

        // Assert that players are set in {PlayersInMatch}
        bytes32[] memory playerEntities = PlayersInMatch.get(matchEntity);
        assertEq(playerEntities.length, 2);
        assertEq(playerEntities[0], users.alice.toPlayerEntity());
        assertEq(playerEntities[1], users.eve.toPlayerEntity());

        // Assert that players {PlayerStatus} are correctly set to {Playing}
        assertEq(
            PlayerStatus
                .get(playerEntities[0])
                .status
                .toPlayerStatusTypes()
                .isPlaying(),
            true
        );
        assertEq(
            PlayerStatus
                .get(playerEntities[1])
                .status
                .toPlayerStatusTypes()
                .isPlaying(),
            true
        );

        // Assert that players {PlayerQueue} are set to (bytes(0))
        assertEq(PlayerQueue.get(playerEntities[0]), bytes32(0));
        assertEq(PlayerQueue.get(playerEntities[1]), bytes32(0));

        // Assert that players are removed from {MatchPool}
        assertEq(MatchPool.get(queueEntity).length, 0);

        // Assert that {MatchStatus} is set to {Preparing}
        assertEq(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isPreparing(),
            true
        );
    }

    function test_JoinQueue_ThirdPlayerJoin() public givenMatchFound {
        bytes32 queueEntity = boardEntity.toQueueEntity(modeEntity);
        bytes32 matchEntity = keccak256(
            abi.encodePacked(
                block.timestamp,
                queueEntity,
                users.alice.toPlayerEntity(),
                users.eve.toPlayerEntity()
            )
        );

        // Assert that when Alice and Eve are matched, they are removed from {MatchPool}
        assertEq(MatchPool.get(queueEntity).length, 0);

        bytes32[] memory playerEntities = PlayersInMatch.get(matchEntity);

        // Assert that players in created match {PlayerQueue} are set to (bytes(0))
        assertEq(PlayerQueue.get(playerEntities[0]), bytes32(0));
        assertEq(PlayerQueue.get(playerEntities[1]), bytes32(0));

        // Bob join queue
        changePrank(users.bob);
        _joinQueue(boardEntity, modeEntity);

        // Assert that Bob is in MatchPool
        assertEq(MatchPool.get(queueEntity).length, 1);
        assertEq(MatchPool.get(queueEntity)[0], users.bob.toPlayerEntity());

        // Assert that Bob {PlayerStatus} is set to {Queueing}
        assertEq(
            PlayerStatus
                .get(users.bob.toPlayerEntity())
                .status
                .toPlayerStatusTypes()
                .isQueueing(),
            true
        );

        // Assert that Bon {PlayerQueue} is set to (queueEntity)
        assertEq(PlayerQueue.get(users.bob.toPlayerEntity()), queueEntity);
    }

    function test_JoinQueue_MultiplePlayersJoinAtTheSameTimeWithDifferentUsers()
        public
    {
        // setup same timestamp
        uint256 blockTimestamp = block.timestamp;
        bytes32 queueEntity = boardEntity.toQueueEntity(modeEntity);
        bytes32 matchEntityOfAliceAndEve = keccak256(
            abi.encodePacked(
                blockTimestamp,
                queueEntity,
                users.alice.toPlayerEntity(),
                users.eve.toPlayerEntity()
            )
        );

        // Alice join queue
        vm.warp(blockTimestamp);
        changePrank(users.alice);
        _joinQueue(boardEntity, modeEntity);

        // Eve join queue
        vm.warp(blockTimestamp);
        changePrank(users.eve);
        _joinQueue(boardEntity, modeEntity);

        // Assert that when Alice and Eve are matched, they are removed from {MatchPool}
        assertEq(MatchPool.get(queueEntity).length, 0);

        // Assert that players in created match {PlayerQueue} are set to (bytes(0))
        bytes32[] memory playerEntitiesOfAliceAndEve = PlayersInMatch.get(
            matchEntityOfAliceAndEve
        );

        assertEq(PlayerQueue.get(playerEntitiesOfAliceAndEve[0]), bytes32(0));
        assertEq(PlayerQueue.get(playerEntitiesOfAliceAndEve[1]), bytes32(0));

        // Assert the MatchConfig is correctly created
        MatchConfigData memory configOfAliceAndEve = MatchConfig.get(
            matchEntityOfAliceAndEve
        );
        assertEq(configOfAliceAndEve.boardEntity, boardEntity);
        assertEq(configOfAliceAndEve.gameModeEntity, modeEntity);
        assertEq(configOfAliceAndEve.playerCount, 2);
        assertEq(configOfAliceAndEve.isPrivate, false);
        assertEq(configOfAliceAndEve.createdBy, users.alice);

        bytes32 matchEntityOfBobAndCharles = keccak256(
            abi.encodePacked(
                blockTimestamp,
                queueEntity,
                users.bob.toPlayerEntity(),
                users.charlie.toPlayerEntity()
            )
        );

        // Bob join queue
        vm.warp(blockTimestamp);
        changePrank(users.bob);
        _joinQueue(boardEntity, modeEntity);

        // Charlie join queue
        vm.warp(blockTimestamp);
        changePrank(users.charlie);
        // vm.expectRevert(Errors.MatchNotAvailable.selector);
        _joinQueue(boardEntity, modeEntity);

        // Assert that when Alice and Eve are matched, they are removed from {MatchPool}
        assertEq(MatchPool.get(queueEntity).length, 0);

        // Assert that players in created match {PlayerQueue} are set to (bytes(0))
        bytes32[] memory playerEntitiesOfBobAndCharles = PlayersInMatch.get(
            matchEntityOfBobAndCharles
        );

        assertEq(PlayerQueue.get(playerEntitiesOfBobAndCharles[0]), bytes32(0));
        assertEq(PlayerQueue.get(playerEntitiesOfBobAndCharles[1]), bytes32(0));

        // Assert the MatchConfig is correctly created
        MatchConfigData memory configOfBobAndCharles = MatchConfig.get(
            matchEntityOfBobAndCharles
        );
        assertEq(configOfBobAndCharles.boardEntity, boardEntity);
        assertEq(configOfBobAndCharles.gameModeEntity, modeEntity);
        assertEq(configOfBobAndCharles.playerCount, 2);
        assertEq(configOfBobAndCharles.isPrivate, false);
        assertEq(configOfBobAndCharles.createdBy, users.bob);
    }
}
