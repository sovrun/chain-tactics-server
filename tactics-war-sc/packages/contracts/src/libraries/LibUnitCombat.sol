// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Battle, BattleData } from "../codegen/tables/Battle.sol";
import { EntityAtPosition } from "../codegen/tables/EntityAtPosition.sol";
import { Position } from "../codegen/tables/Position.sol";
import { MatchPlayer } from "../codegen/tables/MatchPlayer.sol";
import { LastAttackCommited } from "../codegen/tables/LastAttackCommited.sol";

import { pieceEntityCombat, isOwnedByAddress, getEntityAtPosition, getEntityPosition, isFortress } from "./LibUtils.sol";

import { AttackType, getAttackType } from "../common/AttackType.sol";
import { isWithinBlindSpot, isValidAttackPosition } from "../utils/CombatUtils.sol";

import { PieceLibrary } from "./PieceLibrary.sol";

import { console } from "forge-std/Test.sol";

import { playerFromAddress } from "../libraries/LibUtils.sol";

library LibUnitCombat {
    using PieceLibrary for uint256;

    function attack(
        bytes32 matchEntity,
        bytes32 entity,
        bytes32 targetEntity,
        address player
    ) internal {
        BattleData memory attacker = pieceEntityCombat(matchEntity, entity);
        BattleData memory target = pieceEntityCombat(matchEntity, targetEntity);
        bytes32 playerEntity = playerFromAddress(matchEntity, player);

        (uint32 targetX, uint32 targetY) = getEntityPosition(
            matchEntity,
            targetEntity
        );

        uint256 newTargetHealth = target.health > attacker.damage
            ? target.health - attacker.damage
            : 0;

        if (newTargetHealth == 0) {
            EntityAtPosition.deleteRecord(matchEntity, targetX, targetY);
            Position.deleteRecord(matchEntity, targetEntity);
        }

        Battle.setHealth(matchEntity, targetEntity, newTargetHealth);
        LastAttackCommited.set(
            matchEntity,
            targetEntity,
            entity,
            playerEntity,
            player,
            newTargetHealth,
            block.timestamp
        );
    }
}
