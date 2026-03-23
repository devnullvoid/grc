#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONFIG_SOURCE_DIR="$SCRIPT_DIR/functions/_grc_assets/configs"

CONFIG=$(cgrc --location-user)
mkdir -p "$CONFIG"
cp -R "$CONFIG_SOURCE_DIR"/. "$CONFIG"/
