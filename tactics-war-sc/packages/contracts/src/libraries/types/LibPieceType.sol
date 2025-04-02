// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { PieceType } from "../../common/types.sol";

library LibPieceType {
    function toUint256(PieceType piece) internal pure returns (uint256) {
        return uint256(piece);
    }

    function toPieceTypes(uint256 value) internal pure returns (PieceType) {
        require(
            value <= uint256(PieceType.IceMage),
            "LibPieceType: Invalid value"
        );
        return PieceType(value);
    }

    function isFortress(PieceType piece) internal pure returns (bool) {
        return piece == PieceType.Fortress;
    }

    function isFootSoldier(PieceType piece) internal pure returns (bool) {
        return piece == PieceType.FootSoldier;
    }

    function isLancer(PieceType piece) internal pure returns (bool) {
        return piece == PieceType.Lancer;
    }
}
