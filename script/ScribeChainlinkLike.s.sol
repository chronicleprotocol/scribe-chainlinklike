// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";

import {ChronicleScribeAdapter_BASE_QUOTE_COUNTER as ScribeChainlinkLike} from
    "src/ScribeChainlinkLike.sol";
// @todo                       ^^^^ ^^^^^ ^^^^^^^ Adjust name of ScribeChainlinkLike instance.

/**
 * @notice ScribeChainlinkLike Management Script
 */
contract ScribeChainlinkLikeScript is Script {
    /// @dev Deploys a new ScribeChainlinkLike instance.
    function deploy(address chronicle, address chainlink) public {
        vm.startBroadcast();
        address deployed =
            address(new ScribeChainlinkLike(chronicle, chainlink));
        vm.stopBroadcast();

        console.log("Deployed at", deployed);
    }
}
