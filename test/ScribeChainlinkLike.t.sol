// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {console2 as console} from "forge-std/console2.sol";

import {IAuth} from "chronicle-std/auth/IAuth.sol";
import {IToll} from "chronicle-std/toll/IToll.sol";

import {ScribeChainlinkLike, IScribe} from "src/ScribeChainlinkLike.sol";

contract ScribeChainlinkLikeTest is Test {
    function _checkTollProtections(ScribeChainlinkLike scribeCLL) internal {
        // Reverts if not tolled:

        // - latestRoundData
        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(IToll.NotTolled.selector, address(0xbeef))
        );
        scribeCLL.latestRoundData();

        // - latestAnswer
        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(IToll.NotTolled.selector, address(0xbeef))
        );
        scribeCLL.latestAnswer();
    }

    // -- Fork Tests --

    struct ForkTest {
        string chain;
        string watStr;
        address chronicle;
        address chainlink;
        uint decimalsChainlink;
    }

    ForkTest[] forkTests;

    function _setUpForkTests() internal {
        // Ethereum ETH/USD
        forkTests.push(
            ForkTest({
                chain: "eth",
                watStr: "ETH/USD",
                // See https://github.com/chronicleprotocol/chronicles/blob/main/deployments/prod/eth/Chronicle_ETH_USD_3.json.
                chronicle: address(0x46ef0071b1E2fF6B42d36e5A177EA43Ae5917f4E),
                // See https://data.chain.link/ethereum/mainnet/crypto-usd/eth-usd.
                chainlink: address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419),
                // See https://etherscan.io/address/0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419#readContract.
                decimalsChainlink: uint8(8)
            })
        );
        // Ethereum BTC/USD
        forkTests.push(
            ForkTest({
                chain: "eth",
                watStr: "BTC/USD",
                // See https://github.com/chronicleprotocol/chronicles/blob/main/deployments/prod/eth/Chronicle_BTC_USD_3.json.
                chronicle: address(0x24C392CDbF32Cf911B258981a66d5541d85269ce),
                // See https://data.chain.link/ethereum/mainnet/crypto-usd/btc-usd.
                chainlink: address(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c),
                // See https://etherscan.io/address/0xf4030086522a5beea4988f8ca5b36dbc97bee88c#readContract.
                decimalsChainlink: uint8(8)
            })
        );
        // Ethereum MKR/USD
        forkTests.push(
            ForkTest({
                chain: "eth",
                watStr: "MKR/USD",
                // See https://github.com/chronicleprotocol/chronicles/blob/main/deployments/prod/eth/Chronicle_MKR_USD_3.json.
                chronicle: address(0xa69e234a1f55072201127209a18230E89d9E71aC),
                // See https://data.chain.link/ethereum/mainnet/crypto-usd/mkr-usd.
                chainlink: address(0xec1D1B3b0443256cc3860e24a46F108e699484Aa),
                // See https://etherscan.io/address/0xec1d1b3b0443256cc3860e24a46f108e699484aa#readContract.
                decimalsChainlink: uint8(8)
            })
        );

        // @todo Add test case for every deployed instance.
    }

    function testForks() public {
        _setUpForkTests();

        for (uint i; i < forkTests.length; i++) {
            ForkTest memory t = forkTests[i];

            vm.createSelectFork(t.chain);

            // Deploy ScribeChainlinkLike.
            ScribeChainlinkLike scribeCLL;
            scribeCLL = new ScribeChainlinkLike(t.chronicle, t.chainlink);
            assertEq(scribeCLL.decimals(), t.decimalsChainlink);

            _checkTollProtections(scribeCLL);

            // Let scribeCLL and address(this) be tolled on chronicle oracle.
            address[] memory authed = IAuth(t.chronicle).authed();
            require(authed.length != 0);
            vm.startPrank(authed[0]);
            IToll(t.chronicle).kiss(address(scribeCLL));
            IToll(t.chronicle).kiss(address(this));
            vm.stopPrank();

            // Read oracles.
            uint valChronicle = IScribe(t.chronicle).read();
            int answerChainlink = IScribe(t.chainlink).latestAnswer();
            int answerScribeCLL = scribeCLL.latestAnswer();

            // Expect chronicle's val scaled to 8 decimals to equal scribeCLL's
            // answer.
            assertEq(
                int(valChronicle / 10 ** (18 - t.decimalsChainlink)),
                answerScribeCLL
            );

            // Print answers.
            string memory out = string.concat(t.chain, " ", t.watStr, " {\n");
            out = string.concat(
                out, "    chronicle: ", vm.toString(valChronicle), "\n"
            );
            out = string.concat(
                out, "    chainlink: ", vm.toString(answerChainlink), "\n"
            );
            out = string.concat(
                out, "    scribeCLL: ", vm.toString(answerScribeCLL), "\n"
            );
            out = string.concat(out, "  }");
            console.log(out);
        }
    }
}
