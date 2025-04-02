// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Battle, BattleData } from "../codegen/tables/Battle.sol";

library LibBattle {
    /**
     * @dev Sets the battle details for an entity in a match.
     * @notice This function configures the battle attributes for a specific entity within a match.
     * @param _matchEntity The unique identifier for the match entity.
     * @param _entity The unique identifier for the entity being configured.
     * @param _health The health value of the entity.
     * @param _damage The damage value that the entity can inflict.
     * @param _attackType The type of attack the entity can perform.
     * @param _range The attack range of the entity.
     * @param _blindspot The blindspot range of the entity.
     */
    function setBattle(
        bytes32 _matchEntity,
        bytes32 _entity,
        uint256 _health,
        uint256 _damage,
        uint256 _attackType,
        uint256 _range,
        uint256 _blindspot
    ) internal {
        Battle.set(
            _matchEntity,
            _entity,
            _health,
            _damage,
            _attackType,
            _range,
            _blindspot
        );
    }
}
