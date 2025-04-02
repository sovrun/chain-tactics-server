// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BoardConfigData } from "../codegen/tables/BoardConfig.sol";
import { Position, PositionData } from "../codegen/tables/Position.sol";
import { EntityAtPosition } from "../codegen/tables/EntityAtPosition.sol";

import { Errors } from "../common/Errors.sol";
import { entityToPosition } from "../common/Utils.sol";

library LibPosition {
    function isValidCoordinate(
        uint32 _x,
        uint32 _y,
        BoardConfigData memory _boardConfigData
    ) internal pure returns (bool) {
        return (_x >= 1 &&
            _x <= uint32(_boardConfigData.rows) &&
            _y >= 1 &&
            _y <= uint32(_boardConfigData.columns));
    }

    /**
     * @dev Wraps the position coordinates based on the board configuration.
     * @notice This function ensures that the x and y coordinates wrap around based on the board's dimensions.
     * @param _x The x-coordinate to wrap.
     * @param _y The y-coordinate to wrap.
     * @param _boardConfigData The board configuration data.
     * @return (uint32, uint32) The wrapped x and y coordinates.
     */
    function wrapPosition(
        uint32 _x,
        uint32 _y,
        BoardConfigData memory _boardConfigData
    ) internal pure returns (uint32, uint32) {
        _x = (_x +
            ((uint32(_boardConfigData.rows)) % uint32(_boardConfigData.rows)));
        _y = (_y +
            ((uint32(_boardConfigData.columns)) %
                uint32(_boardConfigData.columns)));
        return (_x, _y);
    }

    function setPosition(
        bytes32 _matchEntity,
        bytes32 _entity,
        PositionData memory _coordinate
    ) internal {
        Position.set(_matchEntity, _entity, _coordinate.x, _coordinate.y);
        EntityAtPosition.setValue(
            _matchEntity,
            _coordinate.x,
            _coordinate.y,
            _entity
        );
    }
}
