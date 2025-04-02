// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { BaseMatchSystem_Test } from "../../matchmaking/BaseMatchSystem.t.sol";
import { BaseBuySystem_Test } from "../../buying/BaseBuySystem.t.sol";
import { BaseSpawnSystem_Test } from "../BaseSpawnSystem.t.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";

import { PositionData } from "src/codegen/tables/Position.sol";
import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
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

    bytes32 constant boardEntity = keccak256(abi.encode("BoardEntity"));
    bytes32 constant modeEntity = keccak256(abi.encode("ModeEntity"));
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
        bytes32 encodedCommitHash = keccak256(
            abi.encode(coordinates, pieces, secret)
        );
        matchEntity = keccak256(
            abi.encodePacked(
                block.timestamp,
                bytes32(0),
                users.alice.toPlayerEntity(),
                users.eve.toPlayerEntity()
            )
        );

        vm.expectRevert(Errors.MatchNotActive.selector);
        _commitSpawn(encodedCommitHash, matchEntity);
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
        bytes32 encodedCommitHash = keccak256(
            abi.encode(coordinates, pieces, secret)
        );

        vm.expectRevert(Errors.PreparationTimeOver.selector);
        _commitSpawn(encodedCommitHash, matchEntity);
    }

    function test_RevertGiven_NoCommitHash()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        whenCallerAlice
    {
        bytes32 emptyCommitHash = bytes32(0);

        vm.expectRevert(Errors.NoCommitHash.selector);
        _commitSpawn(emptyCommitHash, matchEntity);
    }

    function test_RevertGiven_IncorrectCommitStatus()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
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
        bytes32 encodedCommitHash = keccak256(
            abi.encode(coordinates, pieces, secret)
        );

        vm.expectRevert(Errors.IncorrectCommitStatus.selector);
        _commitSpawn(encodedCommitHash, matchEntity);
    }

    function test_commitSpawn()
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
        bytes32 encodedCommitHash = keccak256(
            abi.encode(coordinates, pieces, secret)
        );

        _commitSpawn(encodedCommitHash, matchEntity);

        bytes32 committedHash = Commit.get(matchEntity, matchPlayerEntityAlice);
        assertEq(
            committedHash,
            encodedCommitHash,
            "should be a valid committed hash"
        );

        assertTrue(
            SpawnStatus
                .get(matchEntity, matchPlayerEntityAlice)
                .toSpawnStatusTypes()
                .isLockCommitSpawning(),
            "should spawn status of alice is LockCommitSpawning"
        );
    }
}
