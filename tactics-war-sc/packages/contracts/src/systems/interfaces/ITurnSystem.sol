// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

interface ITurnSystem {
    /// @param _matchEntity The identifier for the match in which the turn is being ended.
    function endTurn(bytes32 _matchEntity) external;

    /// @param _matchEntity The identifier for the match in which the player is surrendering.
    function surrender(bytes32 _matchEntity) external;
}
