// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Movement } from "../codegen/tables/Movement.sol";

import { Errors } from "../common/Errors.sol";

library LibMovement {
    /**
     * @notice Sets the movement points for a given entity in a match
     * @param _matchEntity The unique identifier for the match
     * @param _entity The unique identifier for the entity (piece)
     * @param _value The movement points to be set for the entity
     */
    function setMovement(
        bytes32 _matchEntity,
        bytes32 _entity,
        uint256 _value
    ) internal {
        Movement.set(_matchEntity, _entity, _value);
    }

    /**
     * @notice Retrieves the movement points of a given entity in a match
     * @param _matchEntity The unique identifier for the match
     * @param _entity The unique identifier for the entity (piece)
     * @return movement The movement points of the entity
     */
    function getMovement(
        bytes32 _matchEntity,
        bytes32 _entity
    ) internal view returns (uint256 movement) {
        return movement = Movement.getValue(_matchEntity, _entity);
    }
}
