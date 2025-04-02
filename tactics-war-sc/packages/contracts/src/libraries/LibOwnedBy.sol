// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { OwnedBy } from "../codegen/tables/OwnedBy.sol";

library LibOwnedBy {
    /**
     * @dev Sets the owner of an entity in a match.
     * @notice This function assigns ownership of a specific entity to a player within a match.
     * @param _matchEntity The unique identifier for the match entity.
     * @param _entity The unique identifier for the entity being assigned.
     * @param _playerEntity The address of the player who will own the entity.
     */
    function setOwnedBy(
        bytes32 _matchEntity,
        bytes32 _entity,
        bytes32 _playerEntity
    ) internal {
        OwnedBy.set(_matchEntity, _entity, _playerEntity);
    }
}
