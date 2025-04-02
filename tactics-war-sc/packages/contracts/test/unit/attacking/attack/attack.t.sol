// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { BaseMatchSystem_Test } from "../../matchmaking/BaseMatchSystem.t.sol";
import { BaseBuySystem_Test } from "../../buying/BaseBuySystem.t.sol";
import { BaseSpawnSystem_Test } from "../../spawning/BaseSpawnSystem.t.sol";
import { BaseMoveSystem_Test } from "../../moving/BaseMoveSystem.t.sol";
import { BaseTurnSystem_Test } from "../../action/BaseTurnSystem.t.sol";
import { BaseCombatSystem_Test } from "../BaseCombatSystem.t.sol";

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { IWorld } from "src/codegen/world/IWorld.sol";

import { PositionData, Position } from "src/codegen/tables/Position.sol";
import { EntityAtPosition } from "src/codegen/tables/EntityAtPosition.sol";
import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
import { MatchPlayers } from "src/codegen/tables/MatchPlayers.sol";
import { Commit } from "src/codegen/tables/Commit.sol";
import { Inventory } from "src/codegen/tables/Inventory.sol";
import { ActivePlayer } from "src/codegen/tables/ActivePlayer.sol";
import { MatchWinner } from "src/codegen/tables/MatchWinner.sol";
import { MatchStatus } from "src/codegen/tables/MatchStatus.sol";
import { SpawnStatus } from "src/codegen/tables/SpawnStatus.sol";
import { ActionStatus } from "src/codegen/tables/ActionStatus.sol";
import { BattleData, Battle } from "src/codegen/tables/Battle.sol";
import { LastAttackCommitedData, LastAttackCommited } from "src/codegen/tables/LastAttackCommited.sol";

import { SystemIds } from "src/libraries/SystemIds.sol";
import { pieceEntityCombat } from "src/libraries/LibUtils.sol";
import { LibEntity } from "src/libraries/LibEntity.sol";
import { playerFromAddress, isPositionOccupied } from "src/libraries/LibUtils.sol";
import { LibSpawnStatusType } from "src/libraries/types/LibSpawnStatusType.sol";
import { LibMatchStatusType } from "src/libraries/types/LibMatchStatusType.sol";
import { LibPieceType } from "src/libraries/types/LibPieceType.sol";

import { calculateCurrentTurnIndex } from "src/utils/TurnUtils.sol";

import { TTW_NAMESPACES, SPAWN_SYSTEM, SPAWN_PREP_TIME, TURN_DURATION } from "src/common/constants.sol";
import { MatchStatusTypes, SpawnStatusTypes, PieceType } from "src/common/types.sol";
import { Errors } from "src/common/Errors.sol";

contract Attack_Unit_Concrete_Test is
    BaseMatchSystem_Test,
    BaseBuySystem_Test,
    BaseSpawnSystem_Test,
    BaseMoveSystem_Test,
    BaseTurnSystem_Test,
    BaseCombatSystem_Test
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
            BaseMoveSystem_Test,
            BaseTurnSystem_Test,
            BaseCombatSystem_Test
        )
    {
        BaseMatchSystem_Test.setUp();
        BaseBuySystem_Test.setUp();
        BaseSpawnSystem_Test.setUp();
        BaseMoveSystem_Test.setUp();
        BaseTurnSystem_Test.setUp();
        BaseCombatSystem_Test.setUp();
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
        bytes32 targetEntityFootSoldier = bytes32(uint256(4));

        vm.expectRevert(Errors.MatchNotActive.selector);
        _attack(matchEntity, pieceEntity, targetEntityFootSoldier);
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
        pieceTypesForEve[0] = PieceType.FootSoldier.toUint256();
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
        pieceTypesForEve[0] = PieceType.FootSoldier.toUint256();
        bytes32 secretForEve = bytes32("randomHashForEve");

        changePrank(users.eve);
        _revealBuy(matchEntity, pieceTypesForEve, secretForEve);
        _;
    }

    modifier givenSpawnStatusIsRevealSpawning() {
        PositionData[] memory coordinatesForAlice = new PositionData[](2);
        coordinatesForAlice[0] = PositionData(1, 1);
        coordinatesForAlice[1] = PositionData(2, 2);
        bytes32 matchPlayerEntityAlice = playerFromAddress(
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
        bytes32 matchPlayerEntityEve = playerFromAddress(
            matchEntity,
            users.eve
        );
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
        bytes32 matchPlayerEntityAlice = playerFromAddress(
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
        bytes32 matchPlayerEntityEve = playerFromAddress(
            matchEntity,
            users.eve
        );
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
        uint256 activePlayerIndex = ActivePlayer.getPlayerIndex(matchEntity);
        bytes32[] memory matchPlayerEntities = MatchPlayers.getValue(
            matchEntity
        );
        bytes32 activeMatchPlayerEntity = matchPlayerEntities[
            activePlayerIndex
        ];

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
        address opponentAddress = matchActivePlayer != users.alice
            ? users.eve
            : users.alice;
        changePrank(caller);
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            caller
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        vm.expectRevert(
            abi.encodeWithSelector(Errors.NotPlayerTurn.selector, caller)
        );
        _attack(
            matchEntity,
            pieceEntityFootSoldierOfCaller,
            pieceEntityFootSoldierOfOpponent
        );
    }

    modifier givenFootSoldiersCanAttack() {
        // @note made a direct table change to save time
        // beware that if there are tables that was not able to be changed,
        // it can lead to bugs not able to catch
        changePrankToMudAdmin();

        bytes32 matchPlayerEntityOfAlice = playerFromAddress(
            matchEntity,
            users.alice
        );
        bytes32 matchPlayerEntityOfEve = playerFromAddress(
            matchEntity,
            users.eve
        );
        bytes32[] memory pieceEntitiesOfAlice = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfAlice
        );
        bytes32[] memory pieceEntitiesOfEve = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfEve
        );
        bytes32 pieceEntityFootSoldierOfAlice = pieceEntitiesOfAlice[0];
        bytes32 pieceEntityFootSoldierOfEve = pieceEntitiesOfEve[0];

        Position.set(matchEntity, pieceEntityFootSoldierOfAlice, 1, 4);
        EntityAtPosition.set(matchEntity, 1, 4, pieceEntityFootSoldierOfAlice);

        Position.set(matchEntity, pieceEntityFootSoldierOfEve, 1, 5);
        EntityAtPosition.set(matchEntity, 1, 5, pieceEntityFootSoldierOfEve);
        _;
    }

    modifier givenPlayerAlreadyMadeAnAttack() {
        changePrank(matchActivePlayer);
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        PositionData memory positionOfCaller = Position.get(
            matchEntity,
            pieceEntityFootSoldierOfCaller
        );
        PositionData memory positionOfOpponent = Position.get(
            matchEntity,
            pieceEntityFootSoldierOfOpponent
        );

        console.log(
            "positionOfCaller.x: %s, y: %s",
            positionOfCaller.x,
            positionOfCaller.y
        );
        console.log(
            "positionOfOpponent.x: %s, y: %s",
            positionOfOpponent.x,
            positionOfOpponent.y
        );

        _attack(
            matchEntity,
            pieceEntityFootSoldierOfCaller,
            pieceEntityFootSoldierOfOpponent
        );
        _;
    }

    function test_RevertGiven_ExceededAttacksAllowed()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenFootSoldiersCanAttack
        givenPlayerAlreadyMadeAnAttack
    {
        changePrank(matchActivePlayer);
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        vm.expectRevert(Errors.InvalidAction.selector);
        _attack(
            matchEntity,
            pieceEntityFootSoldierOfCaller,
            pieceEntityFootSoldierOfOpponent
        );
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
        givenFootSoldiersCanAttack
    {
        changePrank(matchActivePlayer);
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        vm.expectRevert(Errors.PieceNotOwned.selector);
        _attack(
            matchEntity,
            pieceEntityFootSoldierOfOpponent,
            pieceEntityFootSoldierOfCaller
        );
    }

    modifier givenFootSoldiersCannotAttack() {
        // @note made a direct table change to save time
        // beware that if there are tables that was not able to be changed,
        // it can lead to bugs not able to catch
        changePrankToMudAdmin();
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;

        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        Position.set(matchEntity, pieceEntityFootSoldierOfCaller, 1, 4);
        EntityAtPosition.set(matchEntity, 1, 4, pieceEntityFootSoldierOfCaller);

        Position.set(matchEntity, pieceEntityFootSoldierOfOpponent, 2, 5);
        EntityAtPosition.set(
            matchEntity,
            2,
            5,
            pieceEntityFootSoldierOfOpponent
        );
        _;
    }

    function test_RevertGiven_InvalidAttack()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenFootSoldiersCannotAttack
    {
        changePrank(matchActivePlayer);
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        vm.expectRevert(Errors.InvalidAttack.selector);
        _attack(
            matchEntity,
            pieceEntityFootSoldierOfCaller,
            pieceEntityFootSoldierOfOpponent
        );
    }

    function test_attack_records_last_attack_commited()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenFootSoldiersCanAttack
    {
        changePrank(matchActivePlayer);
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        _attack(
            matchEntity,
            pieceEntityFootSoldierOfCaller,
            pieceEntityFootSoldierOfOpponent
        );

        BattleData memory targetAfterData = pieceEntityCombat(
            matchEntity,
            pieceEntityFootSoldierOfOpponent
        );

        LastAttackCommitedData
            memory lastAttackCommitedData = LastAttackCommited.get(matchEntity);

        assertEq(
            pieceEntityFootSoldierOfCaller,
            lastAttackCommitedData.attackerPieceEntity,
            "should have been the attacker entity"
        );
        assertEq(
            targetAfterData.health,
            lastAttackCommitedData.targetPieceCurrentHealth,
            "should have been the target piece health"
        );
        assertEq(
            matchActivePlayer,
            lastAttackCommitedData.attackerPlayerAddress
        );
        assertEq(
            matchPlayerEntityOfCaller,
            lastAttackCommitedData.attackerPlayerEntity,
            "should have been the attacker player entity"
        );
    }

    function test_attack_reduces_health()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenFootSoldiersCanAttack
    {
        changePrank(matchActivePlayer);
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        BattleData memory targetBeforeData = pieceEntityCombat(
            matchEntity,
            pieceEntityFootSoldierOfOpponent
        );
        // check health before attack
        assertEq(targetBeforeData.health, 3, "should target health is three");

        _attack(
            matchEntity,
            pieceEntityFootSoldierOfCaller,
            pieceEntityFootSoldierOfOpponent
        );

        BattleData memory targetAfterData = pieceEntityCombat(
            matchEntity,
            pieceEntityFootSoldierOfOpponent
        );
        // check health after attack
        uint256 expectedHealth = 2;
        assertEq(
            targetAfterData.health,
            expectedHealth,
            "should target health is two"
        );
    }

    modifier givenPlayerEndedTheTurn() {
        changePrank(matchActivePlayer);
        _endTurn(matchEntity);
        _;
    }

    function test_attack_destroys_target()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenFootSoldiersCanAttack
        givenPlayerAlreadyMadeAnAttack
        givenPlayerEndedTheTurn
        givenActivePlayerHasBeenDetermined
        givenPlayerEndedTheTurn
        givenActivePlayerHasBeenDetermined
        givenPlayerAlreadyMadeAnAttack
        givenPlayerEndedTheTurn
        givenActivePlayerHasBeenDetermined
        givenPlayerEndedTheTurn
        givenActivePlayerHasBeenDetermined
    {
        changePrank(matchActivePlayer);
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        BattleData memory targetBeforeData = pieceEntityCombat(
            matchEntity,
            pieceEntityFootSoldierOfOpponent
        );
        // check health before attack
        assertEq(targetBeforeData.health, 1, "should target health is 1");

        _attack(
            matchEntity,
            pieceEntityFootSoldierOfCaller,
            pieceEntityFootSoldierOfOpponent
        );

        BattleData memory targetAfterData = pieceEntityCombat(
            matchEntity,
            pieceEntityFootSoldierOfOpponent
        );
        // check health after attack
        uint256 expectedHealth = 0;
        assertEq(
            targetAfterData.health,
            expectedHealth,
            "should target health is zero"
        );

        PositionData memory coordinatesOfTarget = Position.get(
            matchEntity,
            pieceEntityFootSoldierOfOpponent
        );

        assertEq(
            coordinatesOfTarget.x,
            0,
            "should have x coordinate equal to zero"
        );
        assertEq(
            coordinatesOfTarget.y,
            0,
            "should have y coordinate equal to zero"
        );

        // Get the coordinates of target
        uint32 x = 1;
        uint32 y = matchActivePlayer == users.alice ? 5 : 4;
        bool isOccupied = isPositionOccupied(matchEntity, x, y);
        assertTrue(!isOccupied, "should not be occupied");
    }

    modifier givenFootSoldiersHaveTwoDamageAndOneHealth() {
        // @note made a direct table change to save time
        // beware that if there are tables that was not able to be changed,
        // it can lead to bugs not able to catch
        changePrankToMudAdmin();
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;

        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        // set health
        Battle.setHealth(matchEntity, pieceEntityFootSoldierOfCaller, 1);
        Battle.setHealth(matchEntity, pieceEntityFootSoldierOfOpponent, 1);

        // set damage
        Battle.setDamage(matchEntity, pieceEntityFootSoldierOfCaller, 2);
        Battle.setDamage(matchEntity, pieceEntityFootSoldierOfOpponent, 2);
        _;
    }

    function test_attack_attacker_greater_damage_destroys_target_with_less_health()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenFootSoldiersCanAttack
        givenFootSoldiersHaveTwoDamageAndOneHealth
    {
        changePrank(matchActivePlayer);
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        BattleData memory targetBeforeData = pieceEntityCombat(
            matchEntity,
            pieceEntityFootSoldierOfOpponent
        );
        // check health before attack
        assertEq(targetBeforeData.health, 1, "should target health is 1");

        BattleData memory attackerData = pieceEntityCombat(
            matchEntity,
            pieceEntityFootSoldierOfCaller
        );
        // check damage before attack
        assertEq(attackerData.damage, 2, "should attacker damage should be 2");

        _attack(
            matchEntity,
            pieceEntityFootSoldierOfCaller,
            pieceEntityFootSoldierOfOpponent
        );

        BattleData memory targetAfterData = pieceEntityCombat(
            matchEntity,
            pieceEntityFootSoldierOfOpponent
        );
        // check health after attack
        uint256 expectedHealth = 0;
        assertEq(
            targetAfterData.health,
            expectedHealth,
            "should target health is zero"
        );

        PositionData memory coordinatesOfTarget = Position.get(
            matchEntity,
            pieceEntityFootSoldierOfOpponent
        );

        assertEq(
            coordinatesOfTarget.x,
            0,
            "should have x coordinate equal to zero"
        );
        assertEq(
            coordinatesOfTarget.y,
            0,
            "should have y coordinate equal to zero"
        );

        // Get the coordinates of target
        uint32 x = 1;
        uint32 y = matchActivePlayer == users.alice ? 5 : 4;
        bool isOccupied = isPositionOccupied(matchEntity, x, y);
        assertTrue(!isOccupied, "should not be occupied");
    }

    modifier givenFootSoldiersCanAttackFortress() {
        // @note made a direct table change to save time
        // beware that if there are tables that was not able to be changed,
        // it can lead to bugs not able to catch
        changePrankToMudAdmin();
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;

        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        Position.set(matchEntity, pieceEntityFootSoldierOfCaller, 2, 4);
        EntityAtPosition.set(matchEntity, 2, 4, pieceEntityFootSoldierOfCaller);

        Position.set(matchEntity, pieceEntityFootSoldierOfOpponent, 2, 5);
        EntityAtPosition.set(
            matchEntity,
            2,
            5,
            pieceEntityFootSoldierOfOpponent
        );

        bytes32 pieceEntityFortressOfCaller = pieceEntitiesOfCaller[1];
        bytes32 pieceEntityFortressOfOpponent = pieceEntitiesOfOpponent[1];

        Position.set(matchEntity, pieceEntityFortressOfCaller, 3, 5);
        EntityAtPosition.set(matchEntity, 3, 5, pieceEntityFortressOfCaller);

        Position.set(matchEntity, pieceEntityFortressOfOpponent, 3, 4);
        EntityAtPosition.set(matchEntity, 3, 4, pieceEntityFortressOfOpponent);
        _;
    }

    modifier givenPlayerAttacksTheFortress() {
        changePrank(matchActivePlayer);

        if (matchActivePlayer == users.alice) {
            console.log("alice");
        } else {
            console.log("eve");
        }
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFortressOfOpponent = pieceEntitiesOfOpponent[1];

        _attack(
            matchEntity,
            pieceEntityFootSoldierOfCaller,
            pieceEntityFortressOfOpponent
        );
        _;
    }

    function test_attack_destroys_fortress()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenFootSoldiersCanAttackFortress
        givenPlayerAttacksTheFortress
        givenPlayerEndedTheTurn
        givenActivePlayerHasBeenDetermined
        givenPlayerEndedTheTurn
        givenActivePlayerHasBeenDetermined
        givenPlayerAttacksTheFortress
        givenPlayerEndedTheTurn
        givenActivePlayerHasBeenDetermined
        givenPlayerEndedTheTurn
        givenActivePlayerHasBeenDetermined
    {
        changePrank(matchActivePlayer);
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFortressOfOpponent = pieceEntitiesOfOpponent[1];
        BattleData memory targetBeforeData = pieceEntityCombat(
            matchEntity,
            pieceEntityFortressOfOpponent
        );
        // check health before attack
        assertEq(targetBeforeData.health, 1, "should have health equal to 1");
        _attack(
            matchEntity,
            pieceEntityFootSoldierOfCaller,
            pieceEntityFortressOfOpponent
        );
        BattleData memory targetAfterData = pieceEntityCombat(
            matchEntity,
            pieceEntityFortressOfOpponent
        );
        // check health after attack
        uint256 expectedHealth = 0;
        assertEq(
            targetAfterData.health,
            expectedHealth,
            "should have health equal to zero"
        );
        PositionData memory coordinatesOfTarget = Position.get(
            matchEntity,
            pieceEntityFortressOfOpponent
        );
        assertEq(
            coordinatesOfTarget.x,
            0,
            "should have x coordinate equal to zero"
        );
        assertEq(
            coordinatesOfTarget.y,
            0,
            "should have y coordinate equal to zero"
        );
        bytes32 matchWinner = MatchWinner.getValue(matchEntity);
        assertEq(
            matchWinner,
            matchPlayerEntityOfCaller,
            "should have been the caller as the winner"
        );
        assertTrue(
            MatchStatus.get(matchEntity).toMatchStatusTypes().isFinished(),
            "should the match be finished"
        );
    }

    modifier givenTurnSkipsOneTurn() {
        uint256 exceededDuration = TURN_DURATION;
        vm.warp(block.timestamp + exceededDuration);
        _;
    }

    function test_attack_and_one_skip()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenFootSoldiersCanAttack
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
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        _attack(
            matchEntity,
            pieceEntityFootSoldierOfCaller,
            pieceEntityFootSoldierOfOpponent
        );
    }

    modifier givenTurnSkipsTwoTurns() {
        uint256 exceededDuration = TURN_DURATION * 2;
        vm.warp(block.timestamp + exceededDuration);
        _;
    }

    function test_attack_and_two_skips()
        public
        givenMatchFound
        givenMatchIsActive
        givenSpawnStatusIsRevealBuying
        givenSpawnStatusIsCommitSpawning
        givenSpawnStatusIsRevealSpawning
        givenMatchIsActionPhase
        givenActivePlayerHasBeenDetermined
        givenFootSoldiersCanAttack
        givenTurnSkipsTwoTurns
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
        address opponentAddress = matchActivePlayer == users.alice
            ? users.eve
            : users.alice;
        bytes32 matchPlayerEntityOfCaller = playerFromAddress(
            matchEntity,
            matchActivePlayer
        );
        bytes32 matchPlayerEntityOfOpponent = playerFromAddress(
            matchEntity,
            opponentAddress
        );
        bytes32[] memory pieceEntitiesOfCaller = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfCaller
        );
        bytes32[] memory pieceEntitiesOfOpponent = Inventory.getPieces(
            matchEntity,
            matchPlayerEntityOfOpponent
        );
        bytes32 pieceEntityFootSoldierOfCaller = pieceEntitiesOfCaller[0];
        bytes32 pieceEntityFootSoldierOfOpponent = pieceEntitiesOfOpponent[0];

        _attack(
            matchEntity,
            pieceEntityFootSoldierOfCaller,
            pieceEntityFootSoldierOfOpponent
        );
    }
}
