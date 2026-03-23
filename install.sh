#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONFIG_SOURCE_DIR="$SCRIPT_DIR/functions/_grc_assets/configs"

if ! command -v cgrc >/dev/null 2>&1; then
    cat >&2 <<'EOF'
cgrc is required but was not found in PATH.

Install cgrc first, then run this script again.
Project: https://github.com/carlonluca/cgrc/tree/master/cgrc-rust
EOF
    exit 1
fi

CONFIG=$(cgrc --location-user)
mkdir -p "$CONFIG"
cp -R "$CONFIG_SOURCE_DIR"/. "$CONFIG"/
