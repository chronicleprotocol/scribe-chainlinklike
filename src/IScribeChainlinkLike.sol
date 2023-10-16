// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IScribeChainlinkLike {
    /// @notice Thrown by protected function if caller not tolled.
    /// @param caller The caller's address.
    error NotTolled(address caller);

    /// @notice Returns Chronicle Protocol's IChronicle oracle instance used
    ///         to retrieve the oracle's value.
    function chronicle() external view returns (address);

    /// @notice Returns the Chainlink oracle's instance from which this oracle's
    ///         decimals value is retrieved from.
    function chainlink() external view returns (address);

    /// @notice Returns the number of decimals of the oracle's value.
    /// @dev Provides partial compatibility with Chainlink's
    ///      IAggregatorV3Interface.
    /// @return decimals The oracle value's number of decimals.
    function decimals() external view returns (uint8 decimals);

    /// @notice Returns the oracle's latest value.
    /// @dev Provides partial compatibility with Chainlink's
    ///      IAggregatorV3Interface.
    /// @return roundId 1.
    /// @return answer The oracle's latest value.
    /// @return startedAt 0.
    /// @return updatedAt The timestamp of oracle's latest update.
    /// @return answeredInRound 1.
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

    /// @notice Returns the oracle's latest value.
    /// @dev Provides partial compatibility with Chainlink's
    ///      IAggregatorV3Interface.
    /// @custom:deprecated See https://docs.chain.link/data-feeds/api-reference/#latestanswer.
    /// @return answer The oracle's latest value.
    function latestAnswer() external view returns (int);
}
