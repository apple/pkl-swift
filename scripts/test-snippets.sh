#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

make generate-snippets

diff=$(git diff "$SCRIPT_DIR"/../codegen/snippet-tests/)

if [[ ! -z "$diff" ]]; then
  echo "Error: Snippet tests contains changes!"
  echo "$diff"
  exit 1
fi
