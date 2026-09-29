#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../ch20/build"
scratch="$PWD/.check-ch20-$$"
mkdir "$scratch"
trap 'rm -rf "$scratch"' EXIT

bitbake select-immediate select-deferred variant-demo variant-demo-tutorial-alt > "$scratch/build.log" 2>&1
test "$(cat tmp/work/select-immediate-1.0-r0/selection.txt)" = early
test "$(cat tmp/work/select-deferred-1.0-r0/selection.txt)" = late
test "$(cat tmp/work/variant-demo-1.0-r0/variant.txt)" = 'variant-demo: original'
test "$(cat tmp/work/variant-demo-tutorial-alt-1.0-r0/variant.txt)" = 'variant-demo-tutorial-alt: alternate'
bitbake -g variant-demo variant-demo-tutorial-alt > "$scratch/graph.log" 2>&1
grep -Fq '"variant-demo.do_build" [label=' task-depends.dot
grep -Fq '"variant-demo-tutorial-alt.do_build" [label=' task-depends.dot
if grep -Fq '"variant-demo.do_build" -> "variant-demo-tutorial-alt.do_build"' task-depends.dot; then
    echo 'Class extension unexpectedly added a dependency' >&2
    exit 1
fi
if bitbake masked-demo > "$scratch/masked.log" 2>&1; then
    echo 'Masked recipe unexpectedly resolved' >&2
    exit 1
fi
grep -q "Nothing PROVIDES 'masked-demo'" "$scratch/masked.log"
printf 'BBMASK = ""\n' > "$scratch/unmask.conf"
bitbake -R "$scratch/unmask.conf" masked-demo > "$scratch/unmasked.log" 2>&1
test "$(cat tmp/work/masked-demo-1.0-r0/selection.txt)" = unmasked

bitbake priority-demo > "$scratch/priority-base.log" 2>&1
test "$(cat tmp/work/priority-demo-2.0-r0/selection.txt)" = 'tutorial 2.0'
bitbake -e priority-demo > "$scratch/priority-base.env"
grep -Fxq 'PV="2.0"' "$scratch/priority-base.env"
bitbake -r "$PWD/conf/ch20-layers.conf" priority-demo > "$scratch/priority-layer.log" 2>&1
test "$(cat tmp/work/priority-demo-1.0-r0/selection.txt)" = 'selection 1.0'
bitbake -r "$PWD/conf/ch20-layers.conf" -e priority-demo > "$scratch/priority-layer.env"
grep -Fxq 'PV="1.0"' "$scratch/priority-layer.env"
bitbake priority-demo > "$scratch/priority-restored.log" 2>&1
test "$(cat tmp/work/priority-demo-2.0-r0/selection.txt)" = 'tutorial 2.0'

bitbake -r "$PWD/conf/ch20-layers.conf" dynamic-demo > "$scratch/with.log" 2>&1
test "$(cat tmp/work/dynamic-demo-1.0-r0/selection.txt)" = with-two
printf 'require conf/ch20-layers.conf\nBBLAYERS:remove = "${TOPDIR}/../meta-two"\n' > "$scratch/without.conf"
bitbake -r "$scratch/without.conf" dynamic-demo > "$scratch/without.log" 2>&1
test "$(cat tmp/work/dynamic-demo-1.0-r0/selection.txt)" = without-two
bitbake -r "$PWD/conf/ch20-layers.conf" dynamic-demo > "$scratch/restored.log" 2>&1
test "$(cat tmp/work/dynamic-demo-1.0-r0/selection.txt)" = with-two
echo 'Chapter 20 checks passed'
