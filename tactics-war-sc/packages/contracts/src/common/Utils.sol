// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { PositionData } from "../codegen/index.sol";

/**
 * @notice Generates a unique entity identifier for a game piece.
 * @param _matchEntity The match identifier.
 * @param _caller The address of the caller.
 * @return entity The unique entity identifier.
 *
 * Example:
 * - Given _matchEntity = 0x1111111111111111111111111111111111111111111111111111111111111111
 * - Given _caller = 0x1234567890123456789012345678901234567890
 * - The function returns a unique entity identifier using keccak256.
 */
function pieceToEntity(
    bytes32 _matchEntity,
    address _caller
) pure returns (bytes32 entity) {
    return keccak256(abi.encode(_matchEntity, _caller));
}

/**
 * @notice Decodes a unique entity identifier to retrieve the match entity and caller address.
 * @param _entity The unique entity identifier.
 * @return matchEntity The match identifier.
 * @return caller The address of the caller.
 *
 * Example:
 * - Given _entity is the result of pieceToEntity function.
 * - The function decodes and returns the original matchEntity and caller.
 */
function entityToPiece(
    bytes32 _entity
) pure returns (bytes32 matchEntity, address caller) {
    bytes memory tempBytes = abi.encodePacked(_entity);
    (matchEntity, caller) = abi.decode(tempBytes, (bytes32, address));
    return (matchEntity, caller);
}

/**
 * @notice Converts grid coordinates to a bytes32 entity.
 * @param _x The x-coordinate.
 * @param _y The y-coordinate.
 * @return entity The bytes32 representation of the coordinates.
 *
 * Example:
 * - Given coordinates _x = 2, _y = 3
 * - The function returns 0x0000000200000000000000000000000000000000000000000000000000000003
 */
function positionToEntity(uint32 _x, uint32 _y) pure returns (bytes32 entity) {
    // Pack the coordinates into a bytes32 value
    return bytes32((uint256(_x) << 128) | uint256(_y));
}

/**
 * @notice Converts a bytes32 entity to grid coordinates.
 * @param _entity The bytes32 entity to be converted.
 * @return x The x-coordinate.
 * @return y The y-coordinate.
 *
 * Example:
 * - Given bytes32 entity = 0x0000000200000000000000000000000000000000000000000000000000000003
 * - The function returns coordinates x = 2, y = 3
 */
function entityToPosition(bytes32 _entity) pure returns (uint32 x, uint32 y) {
    // Unpack the coordinates from the bytes32 value
    x = uint32(uint256(_entity) >> 128);
    y = uint32(uint256(_entity) & 0xFFFFFFFF);
}

/**
 * @notice Calculates the Manhattan distance between two positions on a grid.
 * @param a The starting position.
 * @param b The target position.
 * @return The Manhattan distance between the two positions.
 *
 * @dev The Manhattan distance is the sum of the absolute differences of their Cartesian coordinates.
 * This distance metric is used in grid-based games where movement is restricted to horizontal and vertical steps.
 *
 * Example:
 * - Given positions a = (2, 3) and b = (5, 1)
 * - dx = |5 - 2| = 3
 * - dy = |3 - 1| = 2
 * - Manhattan distance = dx + dy = 3 + 2 = 5
 */
function distanceBetweenTarget(
    PositionData memory a,
    PositionData memory b
) pure returns (uint32) {
    uint32 dx = a.x > b.x ? a.x - b.x : b.x - a.x;
    uint32 dy = a.y > b.y ? a.y - b.y : b.y - a.y;
    return dx + dy;
}

/**
 * @notice Checks if a move between two positions is valid (horizontal or vertical, not diagonal).
 * @param from The starting position.
 * @param to The target position.
 * @return True if the move is valid, false otherwise.
 *
 * Example:
 * - Given from = (2, 3) and to = (2, 4)
 * - dx = |2 - 2| = 0
 * - dy = |4 - 3| = 1
 * - The function returns true because it's a valid vertical move.
 *
 * Example of invalid move:
 * - Given from = (2, 3) and to = (3, 4)
 * - dx = |3 - 2| = 1
 * - dy = |4 - 3| = 1
 * - The function returns false because it's a diagonal move.
 */
function isValidPathStep(
    PositionData memory from,
    PositionData memory to
) pure returns (bool) {
    uint32 dx = from.x > to.x ? from.x - to.x : to.x - from.x;
    uint32 dy = from.y > to.y ? from.y - to.y : to.y - from.y;

    // Valid move is either horizontal or vertical step, not diagonal
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
}
