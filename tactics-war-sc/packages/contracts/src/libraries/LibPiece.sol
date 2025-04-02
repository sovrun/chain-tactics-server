// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Piece } from "../codegen/tables/Piece.sol";

library LibPiece {
    function setPiece(
        bytes32 _matchEntity,
        bytes32 _pieceEntity,
        uint256 _pieceType
    ) internal {
        Piece.set(_matchEntity, _pieceEntity, _pieceType);
    }
}
