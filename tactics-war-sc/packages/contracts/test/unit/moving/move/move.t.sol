// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { BaseMatchSystem_Test } from "../../matchmaking/BaseMatchSystem.t.sol";
import { BaseBuySystem_Test } from "../../buying/BaseBuySystem.t.sol";
import { BaseSpawnSystem_Test } from "../../spawning/BaseSpawnSystem.t.sol";
import { BaseMoveSystem_Test } from "../../moving/BaseMoveSystem.t.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";

import { PositionData, Position } from "src/codegen/tables/Position.sol";
import { EntityAtPosition } from "src/codegen/tables/EntityAtPosition.sol";
import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
import { MatchPlayers } from "src/codegen/tables/MatchPlayers.sol";
import { Commit } from "src/codegen/tables/Commit.sol";
import { Inventory } from "src/codegen/tables/Inventory.sol";
import { SpawnStatus } from "src/codegen/tables/SpawnStatus.sol";
import { ActionStatus } from "src/codegen/tables/ActionStatus.sol";
import { LastMoveCommitedData, LastMoveCommited } from "src/codegen/tables/LastMoveCommited.sol";

import { SystemIds } from "src/libraries/SystemIds.sol";
import { LibEntity } from "src/libraries/LibEntity.sol";
import { LibSpawnStatusType } from "src/libraries/types/LibSpawnStatusType.sol";
import { LibMatchStatusType } from "src/libraries/types/LibMatchStatusType.sol";
import { LibPieceType } from "src/libraries/types/LibPieceType.sol";

import { calculateCurrentTurnIndex } from "src/utils/TurnUtils.sol";

import { TTW_NAMESPACES, SPAWN_SYSTEM, SPAWN_PREP_TIME, TURN_DURATION } from "src/common/constants.sol";
import { MatchStatusTypes, SpawnStatusTypes, PieceType } from "src/common/types.sol";
import { Errors } from "src/common/Errors.sol";

contract Move_Unit_Concrete_Test is
    BaseMatchSystem_Test,
    BaseBuySystem_Test,
    BaseSpawnSystem_Test,
    BaseMoveSystem_Test
{
    using LibEntity for address payable;
    using LibEntity for bytes32;

    using LibMatchStatusType for MatchStatusTypes;
    using LibMatchStatusType for uint8;

    using LibSpawnStatusType for SpawnStatusTypes;
    using LibSpawnStatusType for uint8;

    using LibPieceType for PieceType;
    using LibPieceType for uint256;

    bytes32 constant boardEntity = bytes32(uint256(1));
    bytes32 constant modeEntity = bytes32(uint256(2));
    bytes32 matchEntity;
    address matchActivePlayer;

    function setUp()
        public
        override(
            BaseMatchSystem_Test,
            BaseBuySystem_Test,
            BaseSpawnSystem_Test,
            BaseMoveSystem_Test
        )
    {
        BaseMatchSystem_Test.setUp();
        BaseBuySystem_Test.setUp();
        BaseSpawnSystem_Test.setUp();
        BaseMoveSystem_Test.setUp();
    }

    modifier givenMatchFound() {
        changePrank(users.alice);
        _joinQueue(boardEntity, modeEntity);
        changePrank(users.eve);
        _joinQueue(boardEntity, modeEntity);

        _;
    }

    modifier givenMatchIsActive() {
        bytes32 queueEntity = boardEntity.toQueueEntity(modeEntity);
        matchEntity = keccak256(
            abi.encodePacked(
                block.timestamp,
                queueEntity,
                users.alice.toPlayerEntity(),
                users.eve.toPlayerEntity()
            )
        );

        changePrank(users.alice);
        _setPlayerReadyAndStart(matchEntity);
        changePrank(users.eve);
        _setPlayerReadyAndStart(matchEntity);

        _;
    }

    function test_RevertGiven_MatchNotActive()
        public
        givenMatchFound
        whenCallerAlice
    {
        matchEntity = keccak256(
            abi.encodePacked(
                block.timestamp,
                bytes32(0),
                users.alice.toPlayerEntity(),
                users.eve.toPlayerEntity()
            )
        );
        bytes32 pieceEntity = bytes32(uint256(3));
        PositionData[] memory coordinates = new PositionData[](2);
        coordinates[0] = PositionData(1, 2);
        coordinates[1] = PositionData(1, 3);

        vm.expectRevert(Errors.MatchNotActive.selector);
        _move(matchEntity, pieceEntity, coordinates);
    }

    modifier givenSpawnStatusIsRevealBuying() {
        uint256[] memory pieceTypesForAlice = new uint256[](1);
        pieceTypesForAlice[0] = PieceType.FootSoldier.toUint256();
        bytes32 secretForAlice = bytes32("randomHashForAlice");
        bytes32 encodedRevealHashForAlice = keccak256(
            abi.encode(pieceTypesForAlice, secretForAlice)
        );

        changePrank(users.alice);
        _commitBuy(encodedRevealHashForAlice, matchEntity);

        uint256[] memory pieceTypesForEve = new uint256[](1);
        pieceTypesForEve[0] = PieceType.Lancer.toUint256();
        bytes32 secretForEve = bytes32("randomHashForEve");
        bytes32 encodedRevealHashForEve = keccak256(
            abi.encode(pieceTypesForEve, secretForEve)
        );

        changePrank(users.eve);
        _commitBuy(encodedRevealHashForEve, matchEntity);
        _;
    }

    modifier givenSpawnStatusIsCommitSpawning() {
        uint256[] memory pieceTypesForAlice = new uint256[](1);
        pieceTypesForAlice[0] = PieceType.FootSoldier.toUint256();
        bytes32 secretForAlice = bytes32("randomHashForAlice");

        changePrank(users.alice);
        _revealBuy(matchEntity, pieceTypesForAlice, secretForAlice);

        uint256[] memory pieceTypesForEve = new uint256[](1);
        pieceTypesForEve[0] = PieceType.Lancer.toUint256();
        bytes32 secretForEve = bytes32("randomHashForEve");

        changePrank(users.eve);
        _revealBuy(matchEntity, pieceTypesForEve, secretForEve);
        _;
    }

    modifier givenSpawnStatusIsRevealSpawning() {
        PositionData[] memory coordinatesForAlice = new PositionData[](2);
        coordinatesForAlice[0] = PositionData(1, 1);
        coordinatesForAlice[1] = PositionData(2, 2);
        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        bytes32[] memory piecesForAlice = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityAlice
        );
        bytes32 secretForAlice = bytes32("randomHashForAlice");
        bytes32 encodedCommitHashForAlice = keccak256(
            abi.encode(piecesForAlice, coordinatesForAlice, secretForAlice)
        );

        changePrank(users.alice);
        _commitSpawn(encodedCommitHashForAlice, matchEntity);

        PositionData[] memory coordinatesForEve = new PositionData[](2);
        coordinatesForEve[0] = PositionData(1, 9);
        coordinatesForEve[1] = PositionData(2, 8);
        bytes32 matchPlayerEntityEve = MatchPlayer.get(matchEntity, users.eve);
        bytes32[] memory piecesForEve = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityEve
        );
        bytes32 secretForEve = bytes32("randomHashForEve");
        bytes32 encodedCommitHashForEve = keccak256(
            abi.encode(piecesForEve, coordinatesForEve, secretForEve)
        );

        changePrank(users.eve);
        _commitSpawn(encodedCommitHashForEve, matchEntity);
        _;
    }

    modifier givenMatchIsActionPhase() {
        PositionData[] memory coordinatesForAlice = new PositionData[](2);
        coordinatesForAlice[0] = PositionData(1, 1);
        coordinatesForAlice[1] = PositionData(2, 2);
        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        bytes32[] memory piecesForAlice = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityAlice
        );
        bytes32 secretForAlice = bytes32("randomHashForAlice");

        changePrank(users.alice);
        _revealSpawn(
            matchEntity,
            coordinatesForAlice,
            piecesForAlice,
            secretForAlice
        );

        PositionData[] memory coordinatesForEve = new PositionData[](2);
        coordinatesForEve[0] = PositionData(1, 9);
        coordinatesForEve[1] = PositionData(2, 8);
        bytes32 matchPlayerEntityEve = MatchPlayer.get(matchEntity, users.eve);
        bytes32[] memory piecesForEve = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityEve
        );
        bytes32 secretForEve = bytes32("randomHashForEve");

        changePrank(users.eve);
        _revealSpawn(
            matchEntity,
            coordinatesForEve,
            piecesForEve,
            secretForEve
        );
        _;
    }

    modifier givenActivePlayerHasBeenDetermined() {
        bytes32[] memory matchPlayerEntities = MatchPlayers.getValue(
            matchEntity
        );
        bytes32 activeMatchPlayerEntity = matchPlayerEntities[0];

        matchActivePlayer = activeMatchPlayerEntity == bytes32(uint256(1))
            ? users.alice
            : users.eve;
        _;
    }

    function test_RevertGiven_NotYourTurn()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
    {
        address caller = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        changePrank(caller);
        bytes32 pieceEntity = bytes32(uint256(3));
        PositionData[] memory coordinates = new PositionData[](1);
        coordinates[0] = PositionData(1, 2);

        vm.expectRevert(
            abi.encodeWithSelector(Errors.NotPlayerTurn.selector, caller)
        );
        _move(matchEntity, pieceEntity, coordinates);
    }

    modifier givenPlayerAlreadyMadeAMoveBefore() {
        changePrank(matchActivePlayer);
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFootSoldier = pieceEntities[0];
        PositionData[] memory coordinates = new PositionData[](1);

        if (matchActivePlayer == users.alice) {
            coordinates[0] = PositionData(1, 2);
        } else {
            coordinates[0] = PositionData(1, 8);
        }

        _move(matchEntity, pieceEntityFootSoldier, coordinates);
        _;
    }

    function test_RevertGiven_ExceededMovesAllowed()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenPlayerAlreadyMadeAMoveBefore
    {
        changePrank(matchActivePlayer);
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFootSoldier = pieceEntities[0];

        PositionData[] memory coordinates = new PositionData[](1);

        if (matchActivePlayer == users.alice) {
            coordinates[0] = PositionData(1, 3);
        } else {
            coordinates[0] = PositionData(1, 7);
        }

        vm.expectRevert(Errors.ExceededMovesAllowed.selector);
        _move(matchEntity, pieceEntityFootSoldier, coordinates);
    }

    modifier givenPlayerPerformAnAttack() {
        // @note made a direct table change to save time
        // beware that if there are tables that was not able to be changed,
        // it can lead to bugs not able to catch
        changePrankToMudAdmin();
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFootSoldier = pieceEntities[0];
        uint256 movesExecuted = 0;
        uint256 battlesExecuted = 1;
        ActionStatus.set(
            matchEntity,
            matchPlayerEntity,
            pieceEntityFootSoldier,
            movesExecuted,
            battlesExecuted
        );
        _;
    }

    function test_RevertGiven_NotSelectedPiece()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenPlayerPerformAnAttack
    {
        changePrank(matchActivePlayer);
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFortress = pieceEntities[1];

        PositionData[] memory coordinates = new PositionData[](1);

        if (matchActivePlayer == users.alice) {
            coordinates[0] = PositionData(1, 2);
        } else {
            coordinates[0] = PositionData(1, 8);
        }

        vm.expectRevert(Errors.NotSelectedPiece.selector);
        _move(matchEntity, pieceEntityFortress, coordinates);
    }

    function test_RevertGiven_PieceNotOwned()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
    {
        changePrank(matchActivePlayer);
        address opponentPlayerAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfOpponent = MatchPlayer.get(
            matchEntity,
            opponentPlayerAddress
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFortress = pieceEntitiesOfOpponent[1];

        PositionData[] memory coordinates = new PositionData[](1);

        if (opponentPlayerAddress == users.alice) {
            coordinates[0] = PositionData(1, 2);
        } else {
            coordinates[0] = PositionData(1, 8);
        }

        vm.expectRevert(Errors.PieceNotOwned.selector);
        _move(matchEntity, pieceEntityFortress, coordinates);
    }

    modifier givenPieceHasBeenKilled() {
        changePrank(matchActivePlayer);
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFootSoldier = pieceEntities[0];
        PositionData memory coordinates = Position.get(
            matchEntity,
            pieceEntityFootSoldier
        );

        // @note made a direct table change to save time
        // beware that if there are tables that was not able to be changed,
        // it can lead to bugs not able to catch
        changePrankToMudAdmin();
        Position.deleteRecord(matchEntity, pieceEntityFootSoldier);
        EntityAtPosition.deleteRecord(
            matchEntity,
            coordinates.x,
            coordinates.y
        );
        _;
    }

    function test_RevertGiven_PieceNotExists()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenPieceHasBeenKilled
    {
        changePrank(matchActivePlayer);
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFootSoldier = pieceEntities[0];

        PositionData[] memory coordinates = new PositionData[](1);

        if (matchActivePlayer == users.alice) {
            coordinates[0] = PositionData(1, 2);
        } else {
            coordinates[0] = PositionData(1, 8);
        }

        vm.expectRevert(Errors.PieceNotExists.selector);
        _move(matchEntity, pieceEntityFootSoldier, coordinates);
    }

    function test_RevertGiven_InvalidPath()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
    {
        changePrank(matchActivePlayer);
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFortress = pieceEntities[1];

        PositionData[] memory coordinates = new PositionData[](1);

        if (matchActivePlayer == users.alice) {
            coordinates[0] = PositionData(3, 3);
        } else {
            coordinates[0] = PositionData(3, 7);
        }

        vm.expectRevert(Errors.InvalidPath.selector);
        _move(matchEntity, pieceEntityFortress, coordinates);
    }

    function test_RevertGiven_InvalidMove()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
    {
        changePrank(matchActivePlayer);
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFootSoldier = pieceEntities[0];

        PositionData[] memory coordinates = new PositionData[](4);

        if (matchActivePlayer == users.alice) {
            coordinates[0] = PositionData(1, 2);
            coordinates[1] = PositionData(1, 3);
            coordinates[2] = PositionData(1, 4);
            coordinates[3] = PositionData(2, 4);
        } else {
            coordinates[0] = PositionData(1, 8);
            coordinates[1] = PositionData(1, 7);
            coordinates[2] = PositionData(1, 6);
            coordinates[3] = PositionData(2, 6);
        }

        vm.expectRevert(Errors.InvalidMove.selector);
        _move(matchEntity, pieceEntityFootSoldier, coordinates);
    }

    function test_RevertGiven_PositionOccupied()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
    {
        changePrank(matchActivePlayer);
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFootSoldier = pieceEntities[0];

        PositionData[] memory coordinates = new PositionData[](3);

        if (matchActivePlayer == users.alice) {
            coordinates[0] = PositionData(2, 1);
            coordinates[1] = PositionData(2, 2);
            coordinates[2] = PositionData(2, 3);
        } else {
            coordinates[0] = PositionData(2, 9);
            coordinates[1] = PositionData(2, 8);
            coordinates[2] = PositionData(3, 8);
        }

        vm.expectRevert(Errors.PositionOccupied.selector);
        _move(matchEntity, pieceEntityFootSoldier, coordinates);
    }

    function test_move()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
    {
        changePrank(matchActivePlayer);
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFootSoldier = pieceEntities[0];

        PositionData[] memory coordinates = new PositionData[](2);

        if (matchActivePlayer == users.alice) {
            coordinates[0] = PositionData(1, 2);
            coordinates[1] = PositionData(1, 3);
        } else {
            coordinates[0] = PositionData(1, 8);
            coordinates[1] = PositionData(1, 7);
        }

        _move(matchEntity, pieceEntityFootSoldier, coordinates);

        // should have old position empty
        PositionData[] memory coordinatesOfPieceBefore = new PositionData[](1);

        if (matchActivePlayer == users.alice) {
            coordinatesOfPieceBefore[0] = PositionData(1, 1);
        } else {
            coordinatesOfPieceBefore[0] = PositionData(1, 9);
        }

        bytes32 pieceEntityOnCoordinates = EntityAtPosition.get(
            matchEntity,
            coordinatesOfPieceBefore[0].x,
            coordinatesOfPieceBefore[0].y
        );
        assertEq(
            pieceEntityOnCoordinates,
            bytes32(0),
            "should have equal to no piece entity"
        );

        // should have created a new position
        PositionData memory coordinatesOfPieceAfter = Position.get(
            matchEntity,
            pieceEntityFootSoldier
        );
        assertEq(
            coordinatesOfPieceAfter.x,
            coordinates[1].x,
            "should have equal value of x"
        );
        assertEq(
            coordinatesOfPieceAfter.y,
            coordinates[1].y,
            "should have equal value of y"
        );

        // should have incremented the moves executed
        assertEq(
            ActionStatus.getMovesExecuted(matchEntity, matchPlayerEntity),
            1,
            "should have equal value of moves executed"
        );

        // should have been the selected piece
        assertEq(
            ActionStatus.getSelectedPiece(matchEntity, matchPlayerEntity),
            pieceEntityFootSoldier,
            "should have equal value of selected piece"
        );
    }

    function test_move_last_move_commited()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
    {
        changePrank(matchActivePlayer);
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFootSoldier = pieceEntities[0];

        PositionData[] memory coordinates = new PositionData[](2);

        if (matchActivePlayer == users.alice) {
            coordinates[0] = PositionData(1, 2);
            coordinates[1] = PositionData(1, 3);
        } else {
            coordinates[0] = PositionData(1, 8);
            coordinates[1] = PositionData(1, 7);
        }

        _move(matchEntity, pieceEntityFootSoldier, coordinates);

        // start here
        LastMoveCommitedData memory lastMoveCommitedData = LastMoveCommited.get(
            matchEntity
        );

        assertEq(
            pieceEntityFootSoldier,
            lastMoveCommitedData.pieceEntity,
            "should have been the piece entity"
        );

        assertEq(
            matchActivePlayer,
            lastMoveCommitedData.playerAddress,
            "should have been the expected player"
        );

        assertEq(
            coordinates[1].x,
            lastMoveCommitedData.x,
            "should have been the x-coordinate"
        );

        assertEq(
            coordinates[1].y,
            lastMoveCommitedData.y,
            "should have been the y-coordinate"
        );
    }

    modifier givenTurnSkipsOneTurn() {
        uint256 exceededDuration = TURN_DURATION;
        vm.warp(block.timestamp + exceededDuration);
        _;
    }

    function test_move_and_one_skip()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenTurnSkipsOneTurn
    {
        // get the current active player
        uint256 currentActivePlayerIndex = calculateCurrentTurnIndex(
            matchEntity
        );
        bytes32 activeMatchPlayerEntity = MatchPlayers.get(matchEntity)[
            currentActivePlayerIndex
        ];

        matchActivePlayer = activeMatchPlayerEntity == bytes32(uint256(1))
            ? users.alice
            : users.eve;

        changePrank(matchActivePlayer);
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFootSoldier = pieceEntities[0];

        PositionData[] memory coordinates = new PositionData[](2);

        if (matchActivePlayer == users.alice) {
            coordinates[0] = PositionData(1, 2);
            coordinates[1] = PositionData(1, 3);
        } else {
            coordinates[0] = PositionData(1, 8);
            coordinates[1] = PositionData(1, 7);
        }

        _move(matchEntity, pieceEntityFootSoldier, coordinates);
    }

    modifier givenTurnSkipsTwoTurns() {
        uint256 exceededDuration = TURN_DURATION * 2;
        vm.warp(block.timestamp + exceededDuration);
        _;
    }

    function test_move_and_two_skips()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenPlayerAlreadyMadeAMoveBefore
        givenTurnSkipsTwoTurns
    {
        changePrank(matchActivePlayer);
        bytes32 matchPlayerEntity = MatchPlayer.get(
            matchEntity,
            matchActivePlayer
        );
        bytes32[] memory pieceEntities = Inventory.getPieces(
            matchEntity,
            matchPlayerEntity
        );
        bytes32 pieceEntityFootSoldier = pieceEntities[0];

        PositionData[] memory coordinates = new PositionData[](2);

        if (matchActivePlayer == users.alice) {
            coordinates[0] = PositionData(1, 3);
            coordinates[1] = PositionData(1, 4);
        } else {
            coordinates[0] = PositionData(1, 7);
            coordinates[1] = PositionData(1, 6);
        }

        _move(matchEntity, pieceEntityFootSoldier, coordinates);
    }
}
