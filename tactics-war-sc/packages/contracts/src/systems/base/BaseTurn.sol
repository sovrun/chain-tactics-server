// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { isCurrentPlayerTurn } from "../../utils/TurnUtils.sol";

import { LibTurn } from "../../libraries/LibTurn.sol";

import { Errors } from "../../common/Errors.sol";

contract BaseTurn {
    modifier onlyCurrentPlayer(bytes32 matchEntity, address player) {
        if (!isCurrentPlayerTurn(matchEntity, player)) {
            revert Errors.NotPlayerTurn(player);
        }
        LibTurn.resetPlayerActionIfNewTurn(matchEntity, player);
        _;
    }
}
