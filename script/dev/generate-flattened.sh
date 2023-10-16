#!/bin/bash

# Script to generate ScribeChainlinkLike's flattened contract.
# Saves the contracts in fresh flattened/ directory.
#
# Run via:
# ```bash
# $ script/dev/generate-flattened.sh
# ```

rm -rf flattened/
mkdir flattened

echo "Generating flattened ScribeChainlinkLike's contract"
forge flatten src/ScribeChainlinkLike.sol > flattened/ScribeChainlinkLike.sol
