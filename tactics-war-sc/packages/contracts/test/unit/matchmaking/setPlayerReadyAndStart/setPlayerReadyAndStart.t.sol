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
import { MatchPreparationTime } from "src/codegen/tables/MatchPreparationTime.sol";
import { MatchPlayers } from "src/codegen/tables/MatchPlayers.sol";
import { MatchPlayer } from "src/codegen/tables/MatchPlayer.sol";
import { Player } from "src/codegen/tables/Player.sol";
import { MatchPlayerStatus } from "src/codegen/tables/MatchPlayerStatus.sol";
import { MatchPool } from "src/codegen/tables/MatchPool.sol";

import { PlayerStatus, PlayerStatusData } from "src/codegen/tables/PlayerStatus.sol";
import { Inventory } from "src/codegen/tables/Inventory.sol";
import { PlayerQueue } from "src/codegen/tables/PlayerQueue.sol";
import { PlayersInMatch } from "src/codegen/tables/PlayersInMatch.sol";

import { MatchSystem } from "src/systems/MatchSystem.sol";
import { Errors } from "src/common/Errors.sol";

import { MatchStatus } from "src/codegen/tables/MatchStatus.sol";
import { Player } from "src/codegen/tables/Player.sol";

import { GOLD_BALANCE, BUY_PREP_TIME } from "src/common/constants.sol";

import { LibEntity } from "src/libraries/LibEntity.sol";
import { LibPlayerStatusType } from "src/libraries/types/LibPlayerStatusType.sol";
import { LibMatchPlayerStatusType } from "src/libraries/types/LibMatchPlayerStatusType.sol";
import { LibMatchStatusType } from "src/libraries/types/LibMatchStatusType.sol";

import { playerFromAddress } from "src/libraries/LibUtils.sol";

contract SetPlayerReadyAndStart_Unit_Concrete_Test is BaseMatchSystem_Test {
    using LibEntity for address payable;
    using LibEntity for bytes32;

    using LibPlayerStatusType for PlayerStatusTypes;
    using LibPlayerStatusType for uint8;

    using LibMatchPlayerStatusType for MatchPlayerStatusTypes;
    using LibMatchPlayerStatusType for uint8;

    using LibMatchStatusType for MatchStatusTypes;
    using LibMatchStatusType for uint8;

    function setUp() public override {
        super.setUp();
    }

    function test_RevertGiven_MatchNotOnPreparingState() public {
        changePrank(users.alice);
        vm.expectRevert(Errors.MatchNotPreparing.selector);
        _setPlayerReadyAndStart(bytes32(0));
    }

    function test_RevertWhen_PlayerNotInMatch() public {
        // Lets generate random matchEntity and set match status to Preparing
        bytes32 matchEntity = keccak256(abi.encode("RANDOM_MATCH"));
        changePrankToMudAdmin();
        MatchStatus.setValue(matchEntity, MatchStatusTypes.Preparing.toUint8());

        changePrank(users.alice);
        vm.expectRevert(Errors.PlayerNotInMatch.selector);
        _setPlayerReadyAndStart(matchEntity);
    }

    function test_RevertGiven_PlayerAlreadySetToReadyState() public {
        // Lets generate random matchEntity and set match status to Preparing
        bytes32 matchEntity = keccak256(abi.encode("RANDOM_MATCH"));
        changePrankToMudAdmin();
        MatchStatus.setValue(matchEntity, MatchStatusTypes.Preparing.toUint8());
        // Add Alice to the match
        bytes32 aliceMatchPlayerEntity = playerFromAddress(
            matchEntity,
            users.alice
        );
        MatchPlayer.setValue(matchEntity, users.alice, aliceMatchPlayerEntity);
        Player.set(matchEntity, aliceMatchPlayerEntity, true);

        // Set Alice {MatchPlayerStatus} to {Ready}
        MatchPlayerStatus.setValue(
            matchEntity,
            aliceMatchPlayerEntity,
            MatchPlayerStatusTypes.Ready.toUint8()
        );

        changePrank(users.alice);
        vm.expectRevert(Errors.PlayerAlreadyReady.selector);
        _setPlayerReadyAndStart(matchEntity);
    }

    function test_SetPlayerReadyAndStart() public {
        bytes32 boardEntity = keccak256(abi.encode("BoardEntity"));
        bytes32 modeEntity = keccak256(abi.encode("ModeEntity"));
        changePrank(users.alice);
        _joinQueue(boardEntity, modeEntity);
        changePrank(users.eve);
        _joinQueue(boardEntity, modeEntity);

        bytes32 queueEntity = boardEntity.toQueueEntity(modeEntity);
        bytes32 matchEntity = keccak256(
            abi.encodePacked(
                block.timestamp,
                queueEntity,
                users.alice.toPlayerEntity(),
                users.eve.toPlayerEntity()
            )
        );

        bytes32 aliceMatchEntity = MatchPlayer.get(matchEntity, users.alice);
        bytes32 eveMatchEntity = MatchPlayer.get(matchEntity, users.eve);

        changePrank(users.alice);
        _setPlayerReadyAndStart(matchEntity);
        // Assert alice {MatchPlayerStatus} is set to {Ready}
        assertEq(
            MatchPlayerStatus
                .getValue(matchEntity, aliceMatchEntity)
                .toMatchPlayerStatusTypes()
                .isPlayerReady(),
            true
        );

        changePrank(users.eve);
        _setPlayerReadyAndStart(matchEntity);
        // Assert eve {MatchPlayerStatus} is set to {Ready}
        assertEq(
            MatchPlayerStatus
                .getValue(matchEntity, eveMatchEntity)
                .toMatchPlayerStatusTypes()
                .isPlayerReady(),
            true
        );

        // Assert both players have gold balance set after all players set to ready state
        assertEq(
            GOLD_BALANCE,
            Inventory.getBalance(matchEntity, aliceMatchEntity)
        );
        assertEq(
            GOLD_BALANCE,
            Inventory.getBalance(matchEntity, eveMatchEntity)
        );

        // Assert match status is set to {Active}
        assertEq(
            MatchStatus.getValue(matchEntity).toMatchStatusTypes().isActive(),
            true
        );

        // Assert match preparation time is set
        assertEq(
            MatchPreparationTime.getValue(matchEntity),
            block.timestamp + BUY_PREP_TIME
        );
    }
}
