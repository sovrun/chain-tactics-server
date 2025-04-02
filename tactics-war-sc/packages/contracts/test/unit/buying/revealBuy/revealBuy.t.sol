// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseMatchSystem_Test } from "../../matchmaking/BaseMatchSystem.t.sol";
import { BaseBuySystem_Test } from "../BaseBuySystem.t.sol";
import { console } from "forge-std/console.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";

import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
import { Commit } from "src/codegen/tables/Commit.sol";
import { Inventory } from "src/codegen/tables/Inventory.sol";
import { Piece } from "src/codegen/tables/Piece.sol";
import { SpawnStatus } from "src/codegen/tables/SpawnStatus.sol";

import { SystemIds } from "src/libraries/SystemIds.sol";
import { LibEntity } from "src/libraries/LibEntity.sol";
import { LibSpawnStatusType } from "src/libraries/types/LibSpawnStatusType.sol";
import { LibMatchStatusType } from "src/libraries/types/LibMatchStatusType.sol";
import { LibPieceType } from "src/libraries/types/LibPieceType.sol";
import { PieceLibrary } from "src/libraries/PieceLibrary.sol";

import { TTW_NAMESPACES, BUY_SYSTEM, BUY_PREP_TIME } from "src/common/constants.sol";
import { MatchStatusTypes, SpawnStatusTypes, PieceType } from "src/common/types.sol";
import { Errors } from "src/common/Errors.sol";

contract RevealBuy_Unit_Concrete_Test is
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
        matchEntity = keccak256(
            abi.encodePacked(
                block.timestamp,
                bytes32(0),
                users.alice.toPlayerEntity(),
                users.eve.toPlayerEntity()
            )
        );

        vm.expectRevert(Errors.MatchNotActive.selector);
        _revealBuy(matchEntity, pieceTypes, secret);
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

        vm.expectRevert(Errors.PreparationTimeOver.selector);
        _revealBuy(matchEntity, pieceTypes, secret);
    }

    modifier givenSpawnStatusIsRevealSpawning() {
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

    function test_RevertGiven_IncorrectRevealStatus()
        public
        givenMatchFound
        givenMatchIsActive
        whenCallerAlice
    {
        uint256[] memory pieceTypes = new uint256[](1);
        pieceTypes[0] = PieceType.FootSoldier.toUint256();
        bytes32 secret = bytes32("randomHashForAlice");

        vm.expectRevert(Errors.IncorrectRevealStatus.selector);
        _revealBuy(matchEntity, pieceTypes, secret);
    }

    function test_RevertGiven_InvalidReveal()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealSpawning
        whenCallerAlice
    {
        uint256[] memory pieceTypes = new uint256[](1);
        pieceTypes[0] = PieceType.IceMage.toUint256();
        bytes32 secret = bytes32("invalidRevealSecret");

        vm.expectRevert(Errors.InvalidReveal.selector);
        _revealBuy(matchEntity, pieceTypes, secret);
    }

    modifier givenOneOfPlayersBoughtAFortress() {
        uint256[] memory pieceTypesForAlice = new uint256[](1);
        pieceTypesForAlice[0] = PieceType.Fortress.toUint256();
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

    function test_RevertGiven_PieceNotAllowedToBuy()
        public
        givenMatchFound
        givenMatchIsActive
        givenOneOfPlayersBoughtAFortress
        whenCallerAlice
    {
        uint256[] memory pieceTypesForAlice = new uint256[](1);
        pieceTypesForAlice[0] = PieceType.Fortress.toUint256();
        bytes32 secretForAlice = bytes32("randomHashForAlice");

        vm.expectRevert(Errors.PieceNotAllowedToBuy.selector);
        _revealBuy(matchEntity, pieceTypesForAlice, secretForAlice);
    }

    modifier givenOneOfPlayersBoughtTooManyPieces() {
        uint256[] memory pieceTypesForAlice = new uint256[](6);
        pieceTypesForAlice[0] = PieceType.Archer.toUint256();
        pieceTypesForAlice[1] = PieceType.IceMage.toUint256();
        pieceTypesForAlice[2] = PieceType.FireMage.toUint256();
        pieceTypesForAlice[3] = PieceType.FireMage.toUint256();
        pieceTypesForAlice[4] = PieceType.IceMage.toUint256();
        pieceTypesForAlice[5] = PieceType.FootSoldier.toUint256();
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

    function test_RevertGiven_NotEnoughGold()
        public
        givenMatchFound
        givenMatchIsActive
        givenOneOfPlayersBoughtTooManyPieces
        whenCallerAlice
    {
        uint256[] memory pieceTypesForAlice = new uint256[](6);
        pieceTypesForAlice[0] = PieceType.Archer.toUint256();
        pieceTypesForAlice[1] = PieceType.IceMage.toUint256();
        pieceTypesForAlice[2] = PieceType.FireMage.toUint256();
        pieceTypesForAlice[3] = PieceType.FireMage.toUint256();
        pieceTypesForAlice[4] = PieceType.IceMage.toUint256();
        pieceTypesForAlice[5] = PieceType.FootSoldier.toUint256();
        bytes32 secretForAlice = bytes32("randomHashForAlice");

        vm.expectRevert(Errors.NotEnoughGold.selector);
        _revealBuy(matchEntity, pieceTypesForAlice, secretForAlice);
    }

    function test_reveal_buy()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealSpawning
        whenCallerAlice
    {
        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        uint256 balanceBefore = Inventory.getBalance(
            matchEntity,
            matchPlayerEntityAlice
        );
        uint256[] memory pieceTypesForAlice = new uint256[](1);
        pieceTypesForAlice[0] = PieceType.FootSoldier.toUint256();
        bytes32 secretForAlice = bytes32("randomHashForAlice");

        _revealBuy(matchEntity, pieceTypesForAlice, secretForAlice);

        uint256 balanceAfter = Inventory.getBalance(
            matchEntity,
            matchPlayerEntityAlice
        );
        PieceLibrary.Piece memory piece = PieceLibrary.getPiece(
            PieceLibrary.PieceType(pieceTypesForAlice[0])
        );

        assertEq(
            balanceBefore - piece.cost,
            balanceAfter,
            "should have decrease the gold balance of alice"
        );

        bytes32[] memory pieceOfAlice = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityAlice
        );
        bool isFootSoldier = Piece
            .getValue(matchEntity, pieceOfAlice[0])
            .toPieceTypes()
            .isFootSoldier();
        assertTrue(isFootSoldier, "should be a footsoldier type for alice");

        assertTrue(
            SpawnStatus
                .get(matchEntity, matchPlayerEntityAlice)
                .toSpawnStatusTypes()
                .isLockRevealBuying(),
            "should spawn status is LockRevealBuying"
        );
    }

    function test_two_players_reveal()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealSpawning
    {
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

        bytes32 matchPlayerEntityAlice = MatchPlayer.get(
            matchEntity,
            users.alice
        );
        bytes32 matchPlayerEntityEve = MatchPlayer.get(matchEntity, users.eve);
        assertTrue(
            Commit.get(matchEntity, matchPlayerEntityAlice) == 0,
            "should have no commit record for alice"
        );
        assertTrue(
            Commit.get(matchEntity, matchPlayerEntityEve) == 0,
            "should have no commit record for eve"
        );

        bytes32[] memory pieceOfAlice = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityAlice
        );
        bool isFortressOfAlice = Piece
            .getValue(matchEntity, pieceOfAlice[1])
            .toPieceTypes()
            .isFortress();
        assertTrue(isFortressOfAlice, "should be a fortress type for alice");

        bytes32[] memory pieceOfEve = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityEve
        );
        bool isFortressOfEve = Piece
            .getValue(matchEntity, pieceOfEve[1])
            .toPieceTypes()
            .isFortress();
        assertTrue(isFortressOfEve, "should be a fortress type for eve");

        assertTrue(
            SpawnStatus
                .get(matchEntity, matchPlayerEntityAlice)
                .toSpawnStatusTypes()
                .isCommitSpawning(),
            "should spawn status of alice is CommitSpawning"
        );

        assertTrue(
            SpawnStatus
                .get(matchEntity, matchPlayerEntityEve)
                .toSpawnStatusTypes()
                .isCommitSpawning(),
            "should spawn status of eve is CommitSpawning"
        );
    }
}
