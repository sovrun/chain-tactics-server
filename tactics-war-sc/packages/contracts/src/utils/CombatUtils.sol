// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Battle, BattleData } from "../codegen/tables/Battle.sol";
import { AttackType, getAttackType } from "../common/AttackType.sol";

import { pieceEntityCombat, isOwnedByAddress, getEntityAtPosition, getEntityPosition, isFortress } from "../libraries/LibUtils.sol";

/// @dev check if the target is within the blindspot of the attacker
function isWithinBlindSpot(
    AttackType attackType,
    uint blindSpot,
    uint32 dx,
    uint32 dy
) pure returns (bool) {
    if (attackType == AttackType.Cross) {
        // Blindspot for Cross attack: first 'blindSpot' blocks in the same row or column
        return (dx <= blindSpot && dy == 0) || (dy <= blindSpot && dx == 0);
    } else if (attackType == AttackType.Square) {
        // Blindspot for Square attack: first 'blindSpot' blocks in both directions
        return dx <= blindSpot && dy <= blindSpot;
    } else if (attackType == AttackType.Diagonal) {
        // Blindspot for Diagonal attack: first 'blindSpot' blocks diagonally
        return dx <= blindSpot && dy == dx;
    }
    return false; // No blindspot for other cases
}

/// @dev Checks if the attack position is valid.
/// @param attackType The type of attack.
/// @param blindSpot The blind spot value.
/// @param dx The x-coordinate difference.
/// @param dy The y-coordinate difference.
/// @return A boolean indicating whether the attack position is valid or not.
function isValidAttackPosition(
    AttackType attackType,
    uint blindSpot,
    uint32 dx,
    uint32 dy
) pure returns (bool) {
    if (attackType == AttackType.Cross) {
        // Blindspot for Cross attack: first 'blindSpot' blocks in the same row or column
        // Cross attack valid if target is in the same row or column
        // Cross attack: valid if target is in the same row or column and outside the blindspot
        return
            (dx == 0 || dy == 0) &&
            !(dx <= blindSpot && dy == 0) &&
            !(dy <= blindSpot && dx == 0);
    } else if (attackType == AttackType.Square) {
        // Blindspot for Square attack: first 'blindSpot' blocks in both directions
        // Square attack valid in any direction within range
        // return (dx <= blindSpot && dy <= blindSpot);
        return !(dx <= blindSpot && dy <= blindSpot);
    } else if (attackType == AttackType.Diagonal) {
        // Blindspot for Diagonal attack: first 'blindSpot' blocks diagonally
        // Diagonal attack valid if target is on the same diagonal
        return (dx == dy) && !(dx <= blindSpot && dy == dx);
    }
    // No blindspot or invalid position for other cases
    return false;
}

function isTargetValid(
    bytes32 matchEntity,
    address attacker,
    bytes32 entity,
    uint32 targetX,
    uint32 targetY
) view returns (bool) {
    // If target is owned by attacker or target is empty, return false
    bytes32 target = getEntityAtPosition(matchEntity, targetX, targetY);
    bool isOwned = isOwnedByAddress(matchEntity, target, attacker);
    // TODO future: add more check/validation if entity is attackable
    if (target == 0 || isOwned) {
        return false;
    }

    // Get attacker (piece) position coordinate
    (uint32 x, uint32 y) = getEntityPosition(matchEntity, entity);
    return canAttack(matchEntity, entity, x, y, targetX, targetY);
}

function isFortressDestroyed(
    bytes32 matchEntity,
    bytes32 entity
) view returns (bool) {
    if (isFortress(matchEntity, entity)) {
        return Battle.getHealth(matchEntity, entity) == 0;
    }

    return false;
}

function canAttack(
    bytes32 matchEntity,
    bytes32 pieceEntity,
    uint32 startX,
    uint32 startY,
    uint32 targetX,
    uint32 targetY
) view returns (bool) {
    BattleData memory data = pieceEntityCombat(matchEntity, pieceEntity);
    uint32 dx = targetX > startX ? targetX - startX : startX - targetX;
    uint32 dy = targetY > startY ? targetY - startY : startY - targetY;

    AttackType attackType = getAttackType(data.attackType);

    // Check if target is within attack range
    if (dx > data.range || dy > data.range) {
        return false; // Target is out of range, cannot attack
    }

    // Validate target position based on attack type
    return isValidAttackPosition(attackType, data.blindspot, dx, dy);
}
