#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../ch16/build"
scratch=$(mktemp -d)
trap 'rm -f "$scratch/input.txt" "$scratch/test.conf" "$scratch/before.sigdata" "$scratch/after.sigdata" "$scratch/diff.txt"; rmdir "$scratch"' EXIT
printf 'alpha\n' > "$scratch/input.txt"
printf 'SIGNATURE_INPUT_DIR = "%s"\nSIGNATURE_MESSAGE = "first"\n' "$scratch" > "$scratch/test.conf"
bb() { bitbake -R "$scratch/test.conf" "$@"; }
work=tmp/work/signature-demo-1.0-r0
bb signature-demo
test "$(cat "$work/result.txt")" = first:alpha
before=$(wc -l < "$work/measure-runs.txt")
bb signature-demo
test "$(wc -l < "$work/measure-runs.txt")" -eq "$before"
bb -S none signature-demo
latest=$(find tmp/stamps -name 'signature-demo-1.0-r0.do_measure.sigdata.*' -printf '%T@ %p\n' | sort -nr | sed -n '1s/^[^ ]* //p')
test -n "$latest"
cp "$latest" "$scratch/before.sigdata"
printf 'SIGNATURE_MESSAGE = "second"\n' >> "$scratch/test.conf"
bb signature-demo
test "$(cat "$work/result.txt")" = second:alpha
test "$(wc -l < "$work/measure-runs.txt")" -eq "$((before + 1))"
bb -S none signature-demo
latest=$(find tmp/stamps -name 'signature-demo-1.0-r0.do_measure.sigdata.*' -printf '%T@ %p\n' | sort -nr | sed -n '1s/^[^ ]* //p')
cp "$latest" "$scratch/after.sigdata"
bitbake-diffsigs "$scratch/before.sigdata" "$scratch/after.sigdata" > "$scratch/diff.txt"
grep -q SIGNATURE_MESSAGE "$scratch/diff.txt"
printf 'DISPLAY_NOTE = "Different log text"\n' >> "$scratch/test.conf"
bb signature-demo
test "$(wc -l < "$work/measure-runs.txt")" -eq "$((before + 1))"
sleep 1
printf 'beta\n' > "$scratch/input.txt"
bb signature-demo
test "$(cat "$work/result.txt")" = second:beta
test "$(wc -l < "$work/measure-runs.txt")" -eq "$((before + 2))"
bitbake signature-demo
test "$(cat "$work/result.txt")" = first:alpha
echo 'Chapter 16 checks passed'
