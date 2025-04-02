// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Errors } from "../../common/Errors.sol";
import { MatchStatusTypes } from "../../common/types.sol";

import { PlayerStatus, PlayerStatusData } from "../../codegen/tables/PlayerStatus.sol";
import { Player } from "../../codegen/tables/Player.sol";
import { PlayerQueue } from "../../codegen/tables/PlayerQueue.sol";
import { MatchStatus } from "../../codegen/tables/MatchStatus.sol";

import { LibPlayerStatusType } from "../../libraries/types/LibPlayerStatusType.sol";
import { LibMatchStatusType } from "../../libraries/types/LibMatchStatusType.sol";
import { LibEntity } from "../../libraries/LibEntity.sol";
import { playerFromAddress } from "../../libraries/LibUtils.sol";

abstract contract BaseMatch {
    using LibEntity for address;

    using LibMatchStatusType for MatchStatusTypes;
    using LibMatchStatusType for uint8;

    modifier onlyActiveMatch(bytes32 matchEntity) {
        _requireActiveMatch(matchEntity);
        _;
    }

    modifier onlyMatchPreparingState(bytes32 matchEntity) {
        _requireMatchPreparingState(matchEntity);
        _;
    }

    modifier onlyMatchPlayer(bytes32 matchEntity, address player) {
        _requireMatchPlayer(matchEntity, player);
        _;
    }

    function _requireActiveMatch(bytes32 matchEntity) internal view {
        if (MatchStatus.get(matchEntity).toMatchStatusTypes().isNotActive()) {
            revert Errors.MatchNotActive();
        }
    }

    function _requireMatchPreparingState(bytes32 matchEntity) internal view {
        if (
            MatchStatus.get(matchEntity).toMatchStatusTypes().isNotPreparing()
        ) {
            revert Errors.MatchNotPreparing();
        }
    }

    function _requireMatchPlayer(
        bytes32 matchEntity,
        address player
    ) internal view {
        bytes32 matchPlayerEntity = playerFromAddress(matchEntity, player);
        if (!Player.get(matchEntity, matchPlayerEntity)) {
            revert Errors.PlayerNotInMatch();
        }
    }
}
