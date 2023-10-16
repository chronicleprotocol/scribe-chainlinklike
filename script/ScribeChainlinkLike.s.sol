// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";

import {IGreenhouse} from "greenhouse/IGreenhouse.sol";

import {ScribeChainlinkLike_COUNTER as ScribeChainlinkLike} from
    "src/ScribeChainlinkLike.sol";
// @todo                    ^^^^^^^ Adjust counter of ScribeChainlinkLike instance.

/**
 * @notice ScribeChainlinkLike Management Script
 */
contract ScribeChainlinkLikeScript is Script {
    /// @dev Deploys a new ScribeChainlinkLike instance via Greenhouse instance
    ///      `greenhouse` and salt `salt`.
    function deploy(
        address greenhouse,
        bytes32 salt,
        address chronicle,
        address chainlink
    ) public {
        // Create creation code with constructor arguments.
        bytes memory creationCode = abi.encodePacked(
            type(ScribeChainlinkLike).creationCode,
            abi.encode(chronicle, chainlink)
        );

        // Ensure salt not yet used.
        address deployed = IGreenhouse(greenhouse).addressOf(salt);
        require(deployed.code.length == 0, "Salt already used");

        // Plant creation code via greenhouse.
        vm.startBroadcast();
        IGreenhouse(greenhouse).plant(salt, creationCode);
        vm.stopBroadcast();

        console.log("Deployed at", deployed);
    }
}
