// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/Test.sol";

library PieceLibrary {
    enum PieceType {
        Unknown,
        Fortress,
        FootSoldier,
        Lancer,
        Priest,
        Archer,
        FireMage,
        IceMage
    }

    struct Piece {
        uint256 cost;
        uint256 health;
        uint256 damage;
        uint256 attackType;
        uint256 range;
        uint256 blindspot;
        uint256 movement;
    }

    function getPiece(
        PieceType pieceType
    ) internal pure returns (Piece memory) {
        if (pieceType == PieceType.Fortress) {
            return fortress();
        } else if (pieceType == PieceType.FootSoldier) {
            return footSoldier();
        } else if (pieceType == PieceType.Lancer) {
            return lancer();
        } else if (pieceType == PieceType.Priest) {
            return priest();
        } else if (pieceType == PieceType.Archer) {
            return archer();
        } else if (pieceType == PieceType.FireMage) {
            return fireMage();
        } else if (pieceType == PieceType.IceMage) {
            return iceMage();
        } else {
            revert("Piece type not found");
        }
    }

    function getPieceType(uint256 pieceType) internal pure returns (PieceType) {
        if (pieceType == 1) {
            return PieceType.Fortress;
        } else if (pieceType == 2) {
            return PieceType.FootSoldier;
        } else if (pieceType == 3) {
            return PieceType.Lancer;
        } else if (pieceType == 4) {
            return PieceType.Priest;
        } else if (pieceType == 5) {
            return PieceType.Archer;
        } else if (pieceType == 6) {
            return PieceType.FireMage;
        } else if (pieceType == 7) {
            return PieceType.IceMage;
        } else {
            revert("Piece type not found");
        }
    }

    function footSoldier() internal pure returns (Piece memory) {
        return
            Piece({
                cost: 1,
                health: 3,
                damage: 1,
                attackType: 1,
                range: 1,
                blindspot: 0,
                movement: 2
            });
    }

    function lancer() internal pure returns (Piece memory) {
        return
            Piece({
                cost: 1,
                health: 2,
                damage: 1,
                attackType: 1,
                range: 3,
                blindspot: 1,
                movement: 2
            });
    }

    function priest() internal pure returns (Piece memory) {
        return
            Piece({
                cost: 1,
                health: 1,
                damage: 2,
                attackType: 2,
                range: 1,
                blindspot: 0,
                movement: 2
            });
    }

    function archer() internal pure returns (Piece memory) {
        return
            Piece({
                cost: 2,
                health: 1,
                damage: 1,
                attackType: 2,
                range: 4,
                blindspot: 2,
                movement: 1
            });
    }

    function fireMage() internal pure returns (Piece memory) {
        return
            Piece({
                cost: 2,
                health: 2,
                damage: 2,
                attackType: 2,
                range: 2,
                blindspot: 0,
                movement: 2
            });
    }

    function iceMage() internal pure returns (Piece memory) {
        return
            Piece({
                cost: 2,
                health: 3,
                damage: 1,
                attackType: 3,
                range: 3,
                blindspot: 0,
                movement: 2
            });
    }

    function fortress() internal pure returns (Piece memory) {
        return
            Piece({
                cost: 0,
                health: 3,
                damage: 1,
                attackType: 1,
                range: 2,
                blindspot: 0,
                movement: 1
            });
    }
}
