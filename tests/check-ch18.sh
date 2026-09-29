#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../ch18/build"
scratch="$PWD/.check-ch18-$$"
mkdir "$scratch"
trap 'rm -rf "$scratch"' EXIT

bitbake -v event-demo event-peer > "$scratch/build.log" 2>&1
work=tmp/work/event-demo-1.0-r0
printf 'pre\nbody\npost\n' > "$scratch/expected"
cmp "$scratch/expected" "$work/hook-order.txt"
test "$(cat tmp/work/event-peer-1.0-r0/peer.txt)" = 'peer completed'
grep -q 'CH18 EVENT BuildStarted' "$scratch/build.log"
grep -q 'CH18 EVENT BuildCompleted' "$scratch/build.log"
grep -q 'CH18 EVENT TaskStarted pn=event-demo task=do_build' "$scratch/build.log"
grep -q 'CH18 EVENT TaskSucceeded pn=event-demo task=do_build' "$scratch/build.log"
grep -q 'CH18 demonstration warning' "$work/temp/log.do_build"
grep -q 'CH18 debug detail' "$work/temp/log.do_build"
test -e "$work/temp/run.do_build"

# A unique value invalidates the parse cache without deleting shared caches.
printf 'CH18_PARSE_CHECK = "%s"\n' "$scratch" > "$scratch/parse.conf"
bitbake -R "$scratch/parse.conf" -p > "$scratch/parse.log" 2>&1
grep -q 'CH18 EVENT RecipeParsed pn=event-demo' "$scratch/parse.log"
bitbake -g event-demo > "$scratch/graph.log" 2>&1
grep -Fq '"event-demo.do_build" -> "event-demo.do_prepare"' task-depends.dot
if grep -q '"event-demo.event_before"' task-depends.dot; then
    echo 'A hook unexpectedly became a scheduled task' >&2
    exit 1
fi

printf 'CH18_FAIL = "1"\n' > "$scratch/failure.conf"
if bitbake -k -R "$scratch/failure.conf" -c fail event-demo event-peer > "$scratch/fail.log" 2>&1; then
    echo 'Intentional failure unexpectedly succeeded' >&2
    exit 1
fi
grep -q 'CH18 intentional failure: set CH18_FAIL back to 0' "$scratch/fail.log"
grep -q 'CH18 EVENT TaskFailed pn=event-demo task=do_fail' "$scratch/fail.log"
grep -q 'CH18 peer completed' "$scratch/fail.log"
grep -q 'CH18 intentional failure' "$work/temp/log.do_fail"
bitbake -c fail event-demo > "$scratch/recovery.log" 2>&1
grep -q 'CH18 failure exercise recovered' "$scratch/recovery.log"
echo 'Chapter 18 checks passed'
