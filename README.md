# ScribeChainlinkLike • [![Fork Tests](https://github.com/chronicleprotocol/scribe-chainlinklike/actions/workflows/fork-tests.yml/badge.svg)](https://github.com/chronicleprotocol/scribe-chainlinklike/actions/workflows/fork-tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

The `ScribeChainlinkLike` contract enables integrating _Chronicle Protocol_'s oracle into immutable contracts that hardcoded Chainlink's decimals value.

Note that this contract is stateless and does not offer any configuration once deployed. Toll management is delegated to the respective Chronicle oracle.


## Installation

Install module via Foundry:

```bash
$ forge install chronicleprotocol/scribe-chainlinklike
```

## Contributing

The project uses the Foundry toolchain. You can find installation instructions [here](https://getfoundry.sh/).

Setup:

```bash
$ git clone https://github.com/chronicleprotocol/scribe-chainlinklike
$ cd scribe-chainlinklike/
$ forge install
```

Run tests:

Note to set the expected RPC URLs environment variables, see [`.env.example`](./.env.example).

```bash
$ forge test
$ forge test -vvvv # Run with full stack traces
```

Lint:

```bash
$ forge fmt [--check]
```

## Dependencies

- [chronicleprotocol/chronicle-std@v2](https://github.com/chronicleprotocol/chronicle-std/tree/v2)

Deployment via:

- [chronicleprotocol/greenhouse@v1](https://github.com/chronicleprotocol/greenhouse/tree/v1)
