#!/bin/bash

# Script to generate ScribeChainlinkLike's ABI.
# Saves the ABI in fresh abis/ directory.
#
# Run via:
# ```bash
# $ script/dev/generate-abis.sh
# ```

rm -rf abis/
mkdir abis

echo "Generating ScribeChainlinkLike's ABI"
forge inspect src/ScribeChainlinkLike.sol:ScribeChainlinkLike abi > abis/ScribeChainlinkLike.json
