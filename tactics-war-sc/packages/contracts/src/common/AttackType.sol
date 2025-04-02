// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

enum AttackType {
    None,
    Cross,
    Square,
    Diagonal
}

function getAttackType(uint256 _attackType) pure returns (AttackType) {
    if (_attackType == 1) {
        return AttackType.Cross;
    } else if (_attackType == 2) {
        return AttackType.Square;
    } else if (_attackType == 3) {
        return AttackType.Diagonal;
    } else {
        revert("Attack type not found");
    }
}
