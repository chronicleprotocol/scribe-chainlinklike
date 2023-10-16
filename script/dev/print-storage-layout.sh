#!/bin/bash

# Script to print the storage layout of ScribeChainlinkLike.
#
# Run via:
# ```bash
# $ script/dev/print-storage-layout.sh
# ```

echo "ScribeChainlinkLike Storage Layout"
forge inspect src/ScribeChainlinkLike.sol:ScribeChainlinkLike storage --pretty
