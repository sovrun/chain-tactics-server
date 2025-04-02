// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

interface IMatchSystem {
    /// @notice Adds a player to the matchmaking queue for a specific game mode and board.
    /// @dev This function will create a new match if no existing match is available.
    /// @param _boardEntity The unique identifier of the board entity.
    /// @param _modeEntity The unique identifier of the game mode entity.
    function joinQueue(bytes32 _boardEntity, bytes32 _modeEntity) external;

    function setPlayerReadyAndStart(bytes32 _matchEntity) external;

    function leave() external;

    function claimVictory(bytes32 _matchEntity) external;
}
