// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseMatchSystem_Test } from "../../matchmaking/BaseMatchSystem.t.sol";
import { BaseBuySystem_Test } from "../BaseBuySystem.t.sol";
import { console } from "forge-std/console.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";

import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
import { Commit } from "src/codegen/tables/Commit.sol";
import { SpawnStatus } from "src/codegen/tables/SpawnStatus.sol";

import { SystemIds } from "src/libraries/SystemIds.sol";
import { LibEntity } from "src/libraries/LibEntity.sol";
import { LibSpawnStatusType } from "src/libraries/types/LibSpawnStatusType.sol";
import { LibMatchStatusType } from "src/libraries/types/LibMatchStatusType.sol";
import { LibPieceType } from "src/libraries/types/LibPieceType.sol";

import { TTW_NAMESPACES, BUY_SYSTEM, BUY_PREP_TIME } from "src/common/constants.sol";
import { MatchStatusTypes, SpawnStatusTypes, PieceType } from "src/common/types.sol";
import { Errors } from "src/common/Errors.sol";

contract CommitBuy_Unit_Concrete_Test is
    BaseMatchSystem_Test,
    BaseBuySystem_Test
{
    using LibEntity for address payable;
    using LibEntity for bytes32;

    using LibMatchStatusType for MatchStatusTypes;
    using LibMatchStatusType for uint8;

    using LibSpawnStatusType for SpawnStatusTypes;
    using LibSpawnStatusType for uint8;

    using LibPieceType for PieceType;
    using LibPieceType for uint256;

    using LibEntity for bytes32;

    bytes32 constant boardEntity = keccak256(abi.encode("BoardEntity"));
    bytes32 constant modeEntity = keccak256(abi.encode("ModeEntity"));
    bytes32 matchEntity;

    function setUp() public override(BaseMatchSystem_Test, BaseBuySystem_Test) {
        BaseMatchSystem_Test.setUp();
        BaseBuySystem_Test.setUp();
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
        uint256[] memory pieceTypes = new uint256[](1);
        pieceTypes[0] = PieceType.FootSoldier.toUint256();
        bytes32 secret = bytes32("randomHashForAlice");
        bytes32 encodedCommitHash = keccak256(abi.encode(pieceTypes, secret));
        matchEntity = keccak256(
            abi.encodePacked(
                block.timestamp,
                bytes32(0),
                users.alice.toPlayerEntity(),
                users.eve.toPlayerEntity()
            )
        );

        vm.expectRevert(Errors.MatchNotActive.selector);
        _commitBuy(encodedCommitHash, matchEntity);
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

    modifier givenPreparationTimeIsOver() {
        uint256 exceededPrepTime = BUY_PREP_TIME + 1;
        vm.warp(block.timestamp + exceededPrepTime);
        _;
    }

    function test_RevertGiven_PreparationTimeOver()
        public
        givenMatchFound
        givenMatchIsActive
        givenPreparationTimeIsOver
        whenCallerAlice
    {
        uint256[] memory pieceTypes = new uint256[](1);
        pieceTypes[0] = PieceType.FootSoldier.toUint256();
        bytes32 secret = bytes32("randomHashForAlice");
        bytes32 encodedCommitHash = keccak256(abi.encode(pieceTypes, secret));

        vm.expectRevert(Errors.PreparationTimeOver.selector);
        _commitBuy(encodedCommitHash, matchEntity);
    }

    function test_RevertGiven_NoCommitHash()
        public
        givenMatchFound
        givenMatchIsActive
        whenCallerAlice
    {
        uint256[] memory pieceTypes = new uint256[](1);
        pieceTypes[0] = PieceType.FootSoldier.toUint256();
        bytes32 emptyCommitHash = bytes32(0);

        vm.expectRevert(Errors.NoCommitHash.selector);
        _commitBuy(emptyCommitHash, matchEntity);
    }

    function test_commitBuy()
        public
        givenMatchFound
        givenMatchIsActive
        whenCallerAlice
    {
        uint256[] memory pieceTypes = new uint256[](1);
        pieceTypes[0] = PieceType.FootSoldier.toUint256();
        bytes32 secret = bytes32("randomHashForAlice");
        bytes32 encodedCommitHash = keccak256(abi.encode(pieceTypes, secret));

        _commitBuy(encodedCommitHash, matchEntity);

        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
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
                .isLockCommitBuying(),
            "should spawn status is LockCommitBuying"
        );
    }

    modifier givenSpawnStatusIsRevealBuying() {
        uint256[] memory pieceTypesForAlice = new uint256[](1);
        pieceTypesForAlice[0] = PieceType.FootSoldier.toUint256();
        bytes32 secretForAlice = bytes32("randomHashForAlice");
        bytes32 encodedCommitHashForAlice = keccak256(
            abi.encode(pieceTypesForAlice, secretForAlice)
        );

        changePrank(users.alice);
        _commitBuy(encodedCommitHashForAlice, matchEntity);

        uint256[] memory pieceTypesForEve = new uint256[](1);
        pieceTypesForEve[0] = PieceType.Lancer.toUint256();
        bytes32 secretForEve = bytes32("randomHashForEve");
        bytes32 encodedCommitHashForEve = keccak256(
            abi.encode(pieceTypesForEve, secretForEve)
        );

        changePrank(users.eve);
        _commitBuy(encodedCommitHashForEve, matchEntity);
        _;
    }

    function test_RevertGiven_IncorrectCommitStatus()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        whenCallerAlice
    {
        uint256[] memory pieceTypes = new uint256[](1);
        pieceTypes[0] = PieceType.Lancer.toUint256();
        bytes32 secret = bytes32("randomHashForAlice");
        bytes32 encodedCommitHash = keccak256(abi.encode(pieceTypes, secret));

        vm.expectRevert(Errors.IncorrectCommitStatus.selector);
        _commitBuy(encodedCommitHash, matchEntity);
    }

    function test_two_player_commits()
        public
        givenMatchFound
        givenMatchIsActive
    {
        uint256[] memory pieceTypesForAlice = new uint256[](1);
        pieceTypesForAlice[0] = PieceType.FootSoldier.toUint256();
        bytes32 secretForAlice = bytes32("randomHashForAlice");
        bytes32 encodedCommitHashForAlice = keccak256(
            abi.encode(pieceTypesForAlice, secretForAlice)
        );

        changePrank(users.alice);
        _commitBuy(encodedCommitHashForAlice, matchEntity);

        uint256[] memory pieceTypesForEve = new uint256[](1);
        pieceTypesForEve[0] = PieceType.Lancer.toUint256();
        bytes32 secretForEve = bytes32("randomHashForEve");
        bytes32 encodedCommitHashForEve = keccak256(
            abi.encode(pieceTypesForEve, secretForEve)
        );

        changePrank(users.eve);
        _commitBuy(encodedCommitHashForEve, matchEntity);

        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        bytes32 committedHashOfAlice = Commit.get(
            matchEntity,
            matchPlayerEntityAlice
        );
        assertEq(
            committedHashOfAlice,
            encodedCommitHashForAlice,
            "should be a valid committed hash of alice"
        );

        bytes32 matchPlayerEntityEve = MatchPlayer.get(matchEntity, users.eve);
        bytes32 committedHashOfEve = Commit.get(
            matchEntity,
            matchPlayerEntityEve
        );
        assertEq(
            committedHashOfEve,
            encodedCommitHashForEve,
            "should be a valid committed hash of eve"
        );

        assertTrue(
            SpawnStatus
                .get(matchEntity, matchPlayerEntityAlice)
                .toSpawnStatusTypes()
                .isRevealBuying(),
            "should spawn status of alice is RevealBuying"
        );

        assertTrue(
            SpawnStatus
                .get(matchEntity, matchPlayerEntityEve)
                .toSpawnStatusTypes()
                .isRevealBuying(),
            "should spawn status of eve is RevealBuying"
        );
    }
}
