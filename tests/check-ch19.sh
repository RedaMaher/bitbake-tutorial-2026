#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../ch19/build"
scratch="$PWD/.check-ch19-$$"
mkdir "$scratch"
trap 'rm -rf "$scratch"' EXIT

# Only this chapter's producer artifact is removed: prove it is rebuilt.
rm -f tmp-tools/deploy/tutorial/tool.txt
bitbake mc:image:mc-image > "$scratch/build.log" 2>&1
test "$(cat tmp-tools/deploy/tutorial/tool.txt)" = 'tool built in tools'
printf 'image built in image\ntool built in tools\n' > "$scratch/expected"
cmp "$scratch/expected" tmp-image/work/mc-image-1.0-r0/image.txt
bitbake -e mc:tools:mc-tool > "$scratch/tools.env"
bitbake -e mc:image:mc-image > "$scratch/image.env"
grep -Fxq "TMPDIR=\"$PWD/tmp-tools\"" "$scratch/tools.env"
grep -Fxq "TMPDIR=\"$PWD/tmp-image\"" "$scratch/image.env"
grep -Fxq 'BB_CURRENT_MC="tools"' "$scratch/tools.env"
grep -Fxq 'BB_CURRENT_MC="image"' "$scratch/image.env"
bitbake -g mc:image:mc-image > "$scratch/graph.log" 2>&1
grep -Fq '"mc:image:mc-image.do_build" -> "mc:tools:mc-tool.do_build"' task-depends.dot

printf 'CH19_MCDEPENDS = "mc:image:tools:ch19-missing-tool:do_build"\n' > "$scratch/missing.conf"
if bitbake -R "$scratch/missing.conf" mc:image:mc-image > "$scratch/missing.log" 2>&1; then
    echo 'Missing multiconfig provider unexpectedly resolved' >&2
    exit 1
fi
grep -q "Nothing PROVIDES.*ch19-missing-tool" "$scratch/missing.log"
bitbake mc:image:mc-image > "$scratch/recovery.log" 2>&1
cmp "$scratch/expected" tmp-image/work/mc-image-1.0-r0/image.txt
printf 'BB_NO_NETWORK = "1"\n' > "$scratch/offline.conf"
bitbake -R "$scratch/offline.conf" world > "$scratch/world.log" 2>&1
echo 'Chapter 19 checks passed'
