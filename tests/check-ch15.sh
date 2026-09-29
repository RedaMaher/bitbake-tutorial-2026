#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../ch15/build"
bitbake artifact-user
for result in explicit deptask rdeptask; do
    test "$(cat "tmp/work/artifact-user-1.0-r0/$result.txt")" = 'Shared artifact v1'
done
bitbake -g artifact-user
grep -q '"artifact-user.do_explicit" -> "artifact-source.do_publish"' task-depends.dot
grep -q '"artifact-user.do_via_depends" -> "artifact-source.do_publish"' task-depends.dot
grep -q '"artifact-user.do_via_runtime" -> "artifact-source.do_runtime"' task-depends.dot
config=$(mktemp --suffix=.conf)
trap 'rm -f "$config"' EXIT
printf 'ARTIFACT_MESSAGE = "Shared artifact v2"\n' > "$config"
bitbake -R "$config" artifact-user
for result in explicit deptask rdeptask; do
    test "$(cat "tmp/work/artifact-user-1.0-r0/$result.txt")" = 'Shared artifact v2'
done
bitbake artifact-user
test "$(cat tmp/work/artifact-user-1.0-r0/rdeptask.txt)" = 'Shared artifact v1'
echo 'Chapter 15 checks passed'
