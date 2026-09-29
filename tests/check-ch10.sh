#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../ch10/build"
bitbake operators
work=tmp/work/operators-1.0-r0
expected=$(printf '%s\n' 'lazy=two' 'early=one' 'weak=default' \
    'message=override' 'parsed=anonymous:override' 'label=task' \
    'words=zero alpha gamma')
test "$(cat "$work/preserved/result.txt")" = "$expected"
before=$(wc -l < "$work/preserved/runs.txt")
touch "$work/scratch/stale"
bitbake operators
test ! -e "$work/scratch/stale"
test "$(wc -l < "$work/preserved/runs.txt")" -eq "$((before + 1))"
envfile=$(mktemp)
trap 'rm -f "$envfile"' EXIT
bitbake -e operators > "$envfile"
grep -q '^LABEL="recipe"$' "$envfile"
grep -q '^EARLY="one"$' "$envfile"
echo 'Chapter 10 checks passed'
