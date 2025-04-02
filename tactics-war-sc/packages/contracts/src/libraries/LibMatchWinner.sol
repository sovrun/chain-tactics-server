// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { MatchStatus } from "../codegen/tables/MatchStatus.sol";
import { MatchWinner } from "../codegen/tables/MatchWinner.sol";

import { playerFromAddress } from "./LibUtils.sol";
import { MatchStatusTypes } from "../common/types.sol";

import { LibMatch } from "./LibMatch.sol";

library LibMatchWinner {
    function setWinner(bytes32 _matchEntity, address _winner) internal {
        MatchWinner.set(_matchEntity, playerFromAddress(_matchEntity, _winner));
        LibMatch.finishMatch(_matchEntity);
    }

    function setWinner(bytes32 _matchEntity, bytes32 _winner) internal {
        MatchWinner.set(_matchEntity, _winner);
        LibMatch.finishMatch(_matchEntity);
    }
}
