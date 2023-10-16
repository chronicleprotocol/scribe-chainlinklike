// @todo Check: IToll(self.scribe()).tolled(self) == true
//       Check: self.chainlink().decimals() == self.decimals()

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Vm} from "forge-std/Vm.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {StdStyle} from "forge-std/StdStyle.sol";

import {IToll} from "chronicle-std/toll/Toll.sol";
import {Chaincheck} from "@script/chronicle-std/Chaincheck.sol";

import {IScribeChainlinkLike} from "src/IScribeChainlinkLike.sol";

interface IDecimals {
    function decimals() external view returns (uint8);
}

/**
 * @notice IScribeChainlinkLike's `chaincheck` Integration Test
 *
 * @dev Config Definition:
 *
 *      ```json
 *      {
 *          "IScribeChainlinkLike": {
 *              "chronicle": <Ethereum address>,
 *              "chainlink": <Ethereum address>,
 *              "decimals": uint
 *          }
 *      }
 *      ```
 */
contract IScribeChainlinkLikeChaincheck is Chaincheck {
    using stdJson for string;

    Vm internal constant vm =
        Vm(address(uint160(uint(keccak256("hevm cheat code")))));

    IScribeChainlinkLike self;
    string config;

    string[] _logs;

    function setUp(address self_, string memory config_)
        external
        override(Chaincheck)
        returns (Chaincheck)
    {
        self = IScribeChainlinkLike(self_);
        config = config_;

        return Chaincheck(address(this));
    }

    function run()
        external
        override(Chaincheck)
        returns (bool, string[] memory)
    {
        check_immutables();
        check_invariant_SelfTolledOnChronicle();
        check_invariant_SelfDecimalsEqualsChainlinkDecimals();

        // Fail run if non-zero number of logs.
        return (_logs.length == 0, _logs);
    }

    function check_immutables() internal {
        address chronicle =
            config.readAddress(".IScribeChainlinkLike.chronicle");
        if (self.chronicle() != chronicle) {
            _logs.push(
                string.concat(
                    StdStyle.red("Immutables mismatch: Chronicle: "),
                    "expected=",
                    vm.toString(chronicle),
                    "actual=",
                    vm.toString(self.chronicle())
                )
            );
        }

        address chainlink =
            config.readAddress(".IScribeChainlinkLike.chainlink");
        if (self.chainlink() != chainlink) {
            _logs.push(
                string.concat(
                    StdStyle.red("Immutables mismatch: Chainlink: "),
                    "expected=",
                    vm.toString(chainlink),
                    "actual=",
                    vm.toString(self.chainlink())
                )
            );
        }

        uint decimals = config.readUint(".IScribeChainlinkLike.decimals");
        if (self.decimals() != decimals) {
            _logs.push(
                string.concat(
                    StdStyle.red("Immutables mismatch: Decimals: "),
                    "expected=",
                    vm.toString(decimals),
                    "actual=",
                    vm.toString(self.decimals())
                )
            );
        }
    }

    function check_invariant_SelfTolledOnChronicle() internal {
        if (!IToll(self.chronicle()).tolled(address(self))) {
            _logs.push(
                string.concat(
                    StdStyle.red(
                        "Invariant broken: Self not tolled on chronicle oracle"
                    )
                )
            );
        }
    }

    function check_invariant_SelfDecimalsEqualsChainlinkDecimals() internal {
        if (IDecimals(self.chainlink()).decimals() != self.decimals()) {
            _logs.push(
                string.concat(
                    StdStyle.red(
                        "Invariant broken: Self decimals does not equal Chainlink's decimals"
                    )
                )
            );
        }
    }
}
