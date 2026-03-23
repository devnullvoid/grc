#!/usr/bin/env bash

set -euo pipefail

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

require() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "missing dependency: $1" >&2
        exit 1
    }
}

require fish
require cgrc
require grc

FISHER_FUNCTION=${FISHER_FUNCTION:-$HOME/.config/fish/functions/fisher.fish}
test -f "$FISHER_FUNCTION" || {
    echo "missing fisher function: $FISHER_FUNCTION" >&2
    exit 1
}

export XDG_CONFIG_HOME="$TMPDIR/config"
mkdir -p "$XDG_CONFIG_HOME/fish"

run_fish() {
    fish -C "set -g fisher_path $XDG_CONFIG_HOME/fish" -C "source $FISHER_FUNCTION" -c "$1"
}

assert_contains() {
    local haystack=$1
    local needle=$2

    if ! grep -Fq -- "$needle" <<<"$haystack"; then
        echo "assertion failed: expected output to contain: $needle" >&2
        exit 1
    fi
}

echo "==> Installing plugin from local checkout"
run_fish "fisher install $REPO_DIR" >/dev/null

echo "==> Checking cgrc configurations"
config_output=$(run_fish "cgrc --list-configurations")
printf '%s\n' "$config_output"
for config_name in configure env gcc ifconfig lsof mount netstat sysctl uptime vmstat whois; do
    assert_contains "$config_output" "-> $config_name"
done

echo "==> Checking bundled cgrc path"
env_output=$(run_fish "env FOO=bar")
printf '%s\n' "$env_output" | sed -n '1,3p'
assert_contains "$env_output" "FOO"
assert_contains "$env_output" "bar"

echo "==> Checking grc fallback path"
diff_output=$(run_fish "printf 'a\nb\n' > $TMPDIR/a; printf 'a\nc\n' > $TMPDIR/b; diff $TMPDIR/a $TMPDIR/b" || true)
printf '%s\n' "$diff_output"
assert_contains "$diff_output" "2c2"
assert_contains "$diff_output" "< b"
assert_contains "$diff_output" "> c"

echo "==> Checking uninstall cleanup"
run_fish "fisher remove $REPO_DIR" >/dev/null
post_remove_output=$(run_fish "cgrc --list-configurations")
printf '%s\n' "$post_remove_output"
for config_name in configure env gcc ifconfig lsof mount netstat sysctl uptime vmstat whois; do
    if grep -Fq -- "-> $config_name" <<<"$post_remove_output"; then
        echo "assertion failed: expected config to be removed: $config_name" >&2
        exit 1
    fi
done

echo "All checks passed."
