#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../ch17/build"
config=$(mktemp --suffix=.conf)
log=$(mktemp)
envfile=$(mktemp)
trap 'rm -f "$config" "$log" "$envfile"' EXIT
bitbake virtual/greeting
test "$(cat tmp/work/greeting-simple-1.0-r0/selection.txt)" = 'simple 1.0'
printf 'PREFERRED_VERSION_greeting-simple = "2.0"\n' > "$config"
bitbake -R "$config" virtual/greeting
test "$(cat tmp/work/greeting-simple-2.0-r0/selection.txt)" = 'simple 2.0'
printf 'PREFERRED_PROVIDER_virtual/greeting = "greeting-fancy"\n' > "$config"
bitbake -R "$config" virtual/greeting
test "$(cat tmp/work/greeting-fancy-1.0-r0/selection.txt)" = 'fancy 1.0'
bitbake -R "$config" -e virtual/greeting > "$envfile"
grep -q '^PN="greeting-fancy"$' "$envfile"
printf 'PREFERRED_PROVIDER_virtual/greeting = ""\n' > "$config"
bitbake -R "$config" -g virtual/greeting > "$log" 2>&1
grep -qi 'multiple providers' "$log"
if bitbake virtual/no-such-greeting > "$log" 2>&1; then
    echo 'Missing provider unexpectedly resolved' >&2
    exit 1
fi
grep -q "Nothing PROVIDES 'virtual/no-such-greeting'" "$log"
bitbake -g virtual/greeting
echo 'Chapter 17 checks passed'
