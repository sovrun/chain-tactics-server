// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

library LibArray {
    function filter(
        bytes32[] memory arr,
        bytes32 element
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory filtered = new bytes32[](arr.length);
        uint256 filteredIndex = 0;
        for (uint256 i; i < arr.length; i++) {
            if (arr[i] != element) {
                filtered[filteredIndex] = arr[i];
                filteredIndex++;
            }
        }
        // update the filtered array length
        assembly {
            mstore(filtered, filteredIndex)
        }

        return filtered;
    }
}
