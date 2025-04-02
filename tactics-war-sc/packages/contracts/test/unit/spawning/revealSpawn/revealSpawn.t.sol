// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseMatchSystem_Test } from "../../matchmaking/BaseMatchSystem.t.sol";
import { BaseBuySystem_Test } from "../../buying/BaseBuySystem.t.sol";
import { BaseSpawnSystem_Test } from "../BaseSpawnSystem.t.sol";
import { console } from "forge-std/console.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";

import { BoardConfig } from "src/codegen/tables/BoardConfig.sol";
import { PositionData, Position } from "src/codegen/tables/Position.sol";
import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
import { ActivePlayer, ActivePlayerData } from "src/codegen/tables/ActivePlayer.sol";
import { Commit } from "src/codegen/tables/Commit.sol";
import { Inventory } from "src/codegen/tables/Inventory.sol";
import { SpawnStatus } from "src/codegen/tables/SpawnStatus.sol";

import { SystemIds } from "src/libraries/SystemIds.sol";
import { LibEntity } from "src/libraries/LibEntity.sol";
import { LibSpawnStatusType } from "src/libraries/types/LibSpawnStatusType.sol";
import { LibMatchStatusType } from "src/libraries/types/LibMatchStatusType.sol";
import { LibPieceType } from "src/libraries/types/LibPieceType.sol";

import { TTW_NAMESPACES, SPAWN_SYSTEM, SPAWN_PREP_TIME } from "src/common/constants.sol";
import { MatchStatusTypes, SpawnStatusTypes, PieceType } from "src/common/types.sol";
import { Errors } from "src/common/Errors.sol";

contract CommitSpawn_Unit_Concrete_Test is
    BaseMatchSystem_Test,
    BaseBuySystem_Test,
    BaseSpawnSystem_Test
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

    function setUp()
        public
        override(BaseMatchSystem_Test, BaseBuySystem_Test, BaseSpawnSystem_Test)
    {
        BaseMatchSystem_Test.setUp();
        BaseBuySystem_Test.setUp();
        BaseSpawnSystem_Test.setUp();
    }

    modifier givenMatchFound() {
        changePrank(users.alice);
        _joinQueue(boardEntity, modeEntity);
        changePrank(users.eve);
        _joinQueue(boardEntity, modeEntity);

        _;
    }

    function test_RevertGiven_MatchNotActive()
        public
        givenMatchFound
        whenCallerAlice
    {
        PositionData[] memory coordinates = new PositionData[](1);
        coordinates[0] = PositionData(1, 1);
        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        bytes32[] memory pieces = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityAlice
        );
        bytes32 secret = bytes32("randomHashForAlice");
        matchEntity = keccak256(
            abi.encodePacked(
                block.timestamp,
                bytes32(0),
                users.alice.toPlayerEntity(),
                users.eve.toPlayerEntity()
            )
        );

        vm.expectRevert(Errors.MatchNotActive.selector);
        _revealSpawn(matchEntity, coordinates, pieces, secret);
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

    modifier givenPreparationTimeIsOver() {
        uint256 exceededPrepTime = SPAWN_PREP_TIME + 1;
        vm.warp(block.timestamp + exceededPrepTime);
        _;
    }

    function test_RevertGiven_PreparationTimeOver()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenPreparationTimeIsOver
        whenCallerAlice
    {
        PositionData[] memory coordinates = new PositionData[](1);
        coordinates[0] = PositionData(1, 1);
        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        bytes32[] memory pieces = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityAlice
        );
        bytes32 secret = bytes32("randomHashForAlice");

        vm.expectRevert(Errors.PreparationTimeOver.selector);
        _revealSpawn(matchEntity, coordinates, pieces, secret);
    }

    function test_RevertGiven_IncorrectRevealStatus()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        whenCallerAlice
    {
        PositionData[] memory coordinates = new PositionData[](1);
        coordinates[0] = PositionData(1, 1);
        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        bytes32[] memory pieces = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityAlice
        );
        bytes32 secret = bytes32("randomHashForAlice");

        vm.expectRevert(Errors.IncorrectRevealStatus.selector);
        _revealSpawn(matchEntity, coordinates, pieces, secret);
    }

    function test_RevertGiven_InvalidReveal()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        whenCallerAlice
    {
        PositionData[] memory coordinates = new PositionData[](2);
        coordinates[0] = PositionData(1, 1);
        coordinates[1] = PositionData(2, 2);
        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        bytes32[] memory pieces = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityAlice
        );
        bytes32 secret = bytes32("invalidRevealSecret");

        vm.expectRevert(Errors.InvalidReveal.selector);
        _revealSpawn(matchEntity, coordinates, pieces, secret);
    }

    modifier givenPlayerSpawnedPiecesOutsideBoardRowsAndColumns() {
        PositionData[] memory coordinatesForAlice = new PositionData[](2);
        coordinatesForAlice[0] = PositionData(0, 0);
        coordinatesForAlice[1] = PositionData(1, 0);
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
        coordinatesForEve[0] = PositionData(10, 10);
        coordinatesForEve[1] = PositionData(11, 10);
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

    function test_RevertGiven_CoordinateNotAllowed()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenPlayerSpawnedPiecesOutsideBoardRowsAndColumns
        whenCallerAlice
    {
        PositionData[] memory coordinates = new PositionData[](2);
        coordinates[0] = PositionData(0, 0);
        coordinates[1] = PositionData(1, 0);
        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        bytes32[] memory pieces = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityAlice
        );
        bytes32 secret = bytes32("randomHashForAlice");

        vm.expectRevert(Errors.CoordinateNotAllowed.selector);
        _revealSpawn(matchEntity, coordinates, pieces, secret);
    }

    modifier givenPlayerSpawnedPiecesNotInThereSpawnArea() {
        PositionData[] memory coordinatesForAlice = new PositionData[](2);
        coordinatesForAlice[0] = PositionData(1, 8);
        coordinatesForAlice[1] = PositionData(2, 7);
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
        coordinatesForEve[0] = PositionData(1, 1);
        coordinatesForEve[1] = PositionData(2, 2);
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

    function test_RevertGiven_NotInSpawnArea()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenPlayerSpawnedPiecesNotInThereSpawnArea
        whenCallerAlice
    {
        PositionData[] memory coordinates = new PositionData[](2);
        coordinates[0] = PositionData(1, 8);
        coordinates[1] = PositionData(2, 7);
        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        bytes32[] memory pieces = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityAlice
        );
        bytes32 secret = bytes32("randomHashForAlice");

        vm.expectRevert(Errors.NotInSpawnArea.selector);
        _revealSpawn(matchEntity, coordinates, pieces, secret);
    }

    modifier givenPlayerSpawnedPieceCoordinateAlreadyOccupied() {
        PositionData[] memory coordinatesForAlice = new PositionData[](2);
        coordinatesForAlice[0] = PositionData(1, 1);
        coordinatesForAlice[1] = PositionData(1, 1);
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
        coordinatesForEve[1] = PositionData(1, 9);
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

    function test_RevertGiven_PositionOccupied()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenPlayerSpawnedPieceCoordinateAlreadyOccupied
        whenCallerAlice
    {
        PositionData[] memory coordinates = new PositionData[](2);
        coordinates[0] = PositionData(1, 1);
        coordinates[1] = PositionData(1, 1);
        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        bytes32[] memory pieces = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityAlice
        );
        bytes32 secret = bytes32("randomHashForAlice");

        vm.expectRevert(Errors.PositionOccupied.selector);
        _revealSpawn(matchEntity, coordinates, pieces, secret);
    }

    function test_reveal_buy()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        whenCallerAlice
    {
        PositionData[] memory coordinates = new PositionData[](2);
        coordinates[0] = PositionData(1, 1);
        coordinates[1] = PositionData(2, 2);
        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        bytes32[] memory pieces = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityAlice
        );
        bytes32 secret = bytes32("randomHashForAlice");

        _revealSpawn(matchEntity, coordinates, pieces, secret);

        PositionData memory footSoldierPosition = Position.get(
            matchEntity,
            pieces[0]
        );
        assertEq(
            coordinates[0].x,
            footSoldierPosition.x,
            "should have equal value of x for alice's footsoldier"
        );
        assertEq(
            coordinates[0].y,
            footSoldierPosition.y,
            "should have equal value of y for alice's footsoldier"
        );

        PositionData memory fortressPosition = Position.get(
            matchEntity,
            pieces[1]
        );
        assertEq(
            coordinates[1].x,
            fortressPosition.x,
            "should have equal value of y for alice's fortress"
        );
        assertEq(
            coordinates[1].y,
            fortressPosition.y,
            "should have equal value of y for alice's fortress"
        );

        assertTrue(
            SpawnStatus
                .get(matchEntity, matchPlayerEntityAlice)
                .toSpawnStatusTypes()
                .isLockRevealSpawning(),
            "should spawn status of alice is LockRevealSpawning"
        );
    }

    function test_two_players_reveal()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
    {
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

        assertTrue(
            SpawnStatus
                .get(matchEntity, matchPlayerEntityAlice)
                .toSpawnStatusTypes()
                .isReady(),
            "should spawn status of alice is Ready"
        );

        assertTrue(
            SpawnStatus
                .get(matchEntity, matchPlayerEntityEve)
                .toSpawnStatusTypes()
                .isReady(),
            "should spawn status of eve is Ready"
        );

        ActivePlayerData memory activePlayer = ActivePlayer.get(matchEntity);
        assertEq(activePlayer.playerIndex, 0, "should have equal to index 0");
        assertEq(
            activePlayer.timestamp,
            block.timestamp,
            "should have equal to current date & time"
        );
    }
}
