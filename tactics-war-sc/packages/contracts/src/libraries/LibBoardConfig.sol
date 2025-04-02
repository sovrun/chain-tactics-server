// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BoardConfig, BoardConfigData } from "../codegen/tables/BoardConfig.sol";

library LibBoardConfig {
    /**
     * @dev Creates a new board configuration.
     * @notice This function sets up a new board configuration with the specified parameters.
     * @param _boardEntity The unique identifier for the board entity.
     * @param _rows The number of rows in the board.
     * @param _columns The number of columns in the board.
     */
    function setBoard(
        bytes32 _boardEntity,
        uint256 _rows,
        uint256 _columns
    ) internal {
        BoardConfig.set(_boardEntity, _rows, _columns);
    }
}
