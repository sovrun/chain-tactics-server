// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { PositionData } from "../../codegen/tables/Position.sol";

interface ICombatSystem {
    /// @dev Moves or attacks a unit within the specified match entity.
    /// @param _matchEntity The identifier of the match entity.
    /// @param _entity The identifier of the unit entity.
    /// @param path The array of positions representing the path to move or attack.
    function moveOrAttack(
        bytes32 _matchEntity,
        bytes32 _entity,
        PositionData[] memory path
    ) external;

    /// @dev Executes a fight between two entities.
    /// @param _matchEntity The identifier of the match entity.
    /// @param _entity The identifier of the entity initiating the fight.
    /// @param _target The identifier of the entity being targeted in the fight.
    function attack(
        bytes32 _matchEntity,
        bytes32 _entity,
        bytes32 _target
    ) external;
}
