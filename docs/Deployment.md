# Deployment

This document describes how to deploy a new `ScribeChainlinkLike` instance via _Chronicle Protocol_'s [`Greenhouse`](https://github.com/chronicleprotocol/greenhouse) contract factory.

## Environment Variables

The following environment variables must be set:

- `RPC_URL`: The RPC URL of an EVM node
- `KEYSTORE`: The path to the keystore file containing the encrypted private key
    - Note that password can either be entered on request or set via the `KEYSTORE_PASSWORD` environment variable
- `KEYSTORE_PASSWORD`: The password for the keystore file
- `ETHERSCAN_API_URL`: The Etherscan API URL for the Etherscan's chain instance
    - Note that the API endpoint varies per Etherscan chain instance
    - Note to point to actual API endpoint (e.g. `/api`) and not just host
- `ETHERSCAN_API_KEY`: The Etherscan API key for the Etherscan's chain instance
- `GREENHOUSE`: The `Greenhouse` instance to use for deployment
- `SALT`: The salt to deploy the `ScribeChainlinkLike` instance to
    - Note to use the salt's string representation
    - Note that the salt must not exceed 32 bytes in length
    - Note that the salt should match the name of the contract deployed!
- `CHRONICLE`: The _Chronicle Protocol_'s _Scribe_ oracle instance
- `CHAINLINK`: The respective Chainlink oracle instance

Note that an `.env.example` file is provided in the project root. To set all environment variables at once, create a copy of the file and rename the copy to `.env`, adjust the variable's values', and run `source .env`.

To easily check the environment variables, run:

```bash
$ env | grep -e "RPC_URL" -e "KEYSTORE" -e "KEYSTORE_PASSWORD" -e "ETHERSCAN_API_URL" -e "ETHERSCAN_API_KEY" -e "GREENHOUSE" -e "SALT" -e "CHRONICLE" -e "CHAINLINK"
```

## Code Adjustments

Two code adjustments are necessary to give each deployed contract instance a unique name:

1. Adjust the `ScribeChainlinkLike_COUNTER`'s name in `src/ScribeChainlinkLike.sol` and remove the `@todo` comment
2. Adjust the import of the `ScribeChainlinkLike_COUNTER` in `script/ScribeChainlinkLike.s.sol` and remove the `@todo` comment

## Execution

The deployment process consists of two steps - the actual deployment and the subsequent Etherscan verification.

Deployment:

```bash
$ SALT_BYTES32=$(cast format-bytes32-string $SALT) && \
  forge script \
    --keystore "$KEYSTORE" \
    --password "$KEYSTORE_PASSWORD" \
    --broadcast \
    --rpc-url "$RPC_URL" \
    --sig "$(cast calldata "deploy(address,bytes32,address,address)" "$GREENHOUSE" "$SALT_BYTES32" "$CHRONICLE" "$CHAINLINK")" \
    -vvv \
    script/ScribeChainlinkLike.s.sol:ScribeChainlinkLikeScript
```

The deployment command will log the address of the newly deployed contract address. Store this address in the `$SCRIBE_CHAINLINK_LIKE` environment variable and continue with the verification.

Verification:

```bash
$ forge verify-contract \
    "$SCRIBE_CHAINLINK_LIKE" \
    --verifier-url "$ETHERSCAN_API_URL" \
    --etherscan-api-key "$ETHERSCAN_API_KEY" \
    --watch \
    --constructor-args $(cast abi-encode "constructor(address,address)" "$CHRONICLE" "$CHAINLINK") \
    src/ScribeChainlinkLike.sol:"$SALT"
```
