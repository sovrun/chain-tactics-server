// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.24;

// import { console } from "forge-std/console.sol";
import { ActionStatus } from "../codegen/tables/ActionStatus.sol";
import { ActivePlayer } from "../codegen/tables/ActivePlayer.sol";
import { MatchDefaultWinner } from "../codegen/tables/MatchDefaultWinner.sol";

function resetPlayerActions(bytes32 _matchEntity, bytes32 _playerEntity) {
    uint256 movesExecuted = 0;
    uint256 battlesExecuted = 0;
    bytes32 selectedPiece = bytes32(0);

    ActionStatus.set(
        _matchEntity,
        _playerEntity,
        selectedPiece,
        movesExecuted,
        battlesExecuted
    );
}

function recordPlayerActions(
    bytes32 _matchEntity,
    bytes32 _playerEntity,
    uint256 _playerIndex,
    uint256 _totalPlayers
) {
    resetPlayerActions(_matchEntity, _playerEntity);

    // Calculate the new player index
    uint256 newPlayerIndex = (_playerIndex + 1) % _totalPlayers;

    // Set the new player index
    ActivePlayer.set(_matchEntity, newPlayerIndex, block.timestamp);

    /// @dev I did this to make the implem simpler
    // Maybe get back to this in the future
    MatchDefaultWinner.set(_matchEntity, _playerEntity);
}
