// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IToll} from "chronicle-std/toll/Toll.sol";

import {IScribeChainlinkLike} from "./IScribeChainlinkLike.sol";

interface IDecimals {
    function decimals() external view returns (uint8);
}

interface IScribe {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int answer,
            uint startedAt,
            uint updatedAt,
            uint80 answeredInRound
        );

    function latestAnswer() external view returns (int);

    function read() external view returns (uint);
}

/**
 * @title ScribeChainlinkLike
 *
 * @notice For everyone that took shortcuts during their Chainlink integration
 *
 * @dev This is a helper contract for immutable contracts that took shortcuts
 *      during their Chainlink integration and hardcoded Chainlink's decimals
 *      value.
 *
 *      It allows using Chronicle Protocol oracles with same decimals as the
 *      respective Chainlink oracle.
 *
 *      Note that this contract is minimal on purpose and does neither provide
 *      nice-to-have's like `wat()(bytes32)` nor the full IChronicle interface.
 *
 *      Please take more caution integrating external projects!
 *
 * @dev Note that this contract is stateless and does not offer any configuration
 *      once deployed. Toll management is delegated to the respective Chronicle
 *      oracle.
 */
contract ScribeChainlinkLike is IScribeChainlinkLike {
    /// @inheritdoc IScribeChainlinkLike
    address public immutable chronicle;

    /// @inheritdoc IScribeChainlinkLike
    address public immutable chainlink;

    /// @inheritdoc IScribeChainlinkLike
    uint8 public immutable decimals;

    constructor(address chronicle_, address chainlink_) {
        chronicle = chronicle_;
        chainlink = chainlink_;

        decimals = IDecimals(chainlink).decimals();
        require(decimals != 0);
    }

    modifier toll() {
        if (!IToll(chronicle).tolled(msg.sender)) {
            revert NotTolled(msg.sender);
        }
        _;
    }

    // -- Chainlink Compatibility Functions --

    /// @inheritdoc IScribeChainlinkLike
    function latestRoundData()
        external
        view
        toll
        returns (uint80, int, uint, uint, uint80)
    {
        // assert(IToll(chronicle).tolled(address(this)));

        (
            uint80 roundId,
            int answer,
            uint startedAt,
            uint updatedAt,
            uint80 answeredInRound
        ) = IScribe(chronicle).latestRoundData();

        return (
            roundId,
            _convert(answer, decimals),
            startedAt,
            updatedAt,
            answeredInRound
        );
    }

    /// @inheritdoc IScribeChainlinkLike
    function latestAnswer() external view toll returns (int) {
        // assert(IToll(chronicle).tolled(address(this)));

        // TODO: Use latestAnswer() once every deployed Scribe is >= v1.2.0.
        //       Note that cast is safe as val's max value is type(uint128).max.
        uint val = IScribe(chronicle).read();
        int answer = int(val);

        return _convert(answer, decimals);
    }

    // -- Internal Helpers --

    function _convert(int val, uint decimals_) internal pure returns (int) {
        // assert(decimals_ != 0);

        if (decimals_ < 18) return val / int((10 ** (18 - decimals_)));
        if (decimals_ > 18) return val * int((10 ** (decimals_ - 18)));

        return val;
    }
}

/**
 * @dev Contract overwrite to deploy contract instances with specific naming.
 *
 *      For more info, see docs/Deployment.md.
 */
contract ScribeChainlinkLike_COUNTER is ScribeChainlinkLike {
    // @todo                 ^^^^^^^ Adjust counter of ScribeChainlinkLike instance.
    constructor(address chronicle, address chainlink)
        ScribeChainlinkLike(chronicle, chainlink)
    {}
}
