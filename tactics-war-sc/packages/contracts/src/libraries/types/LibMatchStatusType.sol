// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { MatchStatusTypes } from "../../common/types.sol";

library LibMatchStatusType {
    function toUint8(MatchStatusTypes status) internal pure returns (uint8) {
        return uint8(status);
    }

    function toMatchStatusTypes(
        uint8 value
    ) internal pure returns (MatchStatusTypes) {
        require(
            value <= uint8(MatchStatusTypes.Cancelled),
            "LibMatchStatusType: Invalid value"
        );
        return MatchStatusTypes(value);
    }

    function isGameInProgress(
        MatchStatusTypes status
    ) internal pure returns (bool) {
        return
            status > MatchStatusTypes.None && status < MatchStatusTypes.Active;
    }

    function isNotActive(MatchStatusTypes status) internal pure returns (bool) {
        return status != MatchStatusTypes.Active;
    }

    function isNotPreparing(
        MatchStatusTypes status
    ) internal pure returns (bool) {
        return status != MatchStatusTypes.Preparing;
    }

    function isActive(MatchStatusTypes status) internal pure returns (bool) {
        return status == MatchStatusTypes.Active;
    }

    function isCancelled(MatchStatusTypes status) internal pure returns (bool) {
        return status == MatchStatusTypes.Cancelled;
    }

    function isFinished(MatchStatusTypes status) internal pure returns (bool) {
        return status == MatchStatusTypes.Finished;
    }

    function isPreparing(MatchStatusTypes status) internal pure returns (bool) {
        return status == MatchStatusTypes.Preparing;
    }

    function isGameOver(MatchStatusTypes status) internal pure returns (bool) {
        return status >= MatchStatusTypes.Finished;
    }
}
