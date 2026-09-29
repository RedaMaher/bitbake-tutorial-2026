#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../ch14/build"
bitbake hello-host
work=tmp/work/hello-host-1.0-r0
test "$("$work/dest/usr/bin/hello-host")" = 'Hello from standalone BitBake.'
test -f "$work/build/config.mk"
test -x "$work/build/hello-host"
test ! -e "$work/sources/hello-host"
test "$(stat -c %a "$work/dest/usr/bin/hello-host")" = 755
bitbake -g hello-host
for edge in 'configure patch' 'compile configure' 'install compile' 'build install'; do
    read -r task dep <<< "$edge"
    grep -q "\"hello-host.do_$task\" -> \"hello-host.do_$dep\"" task-depends.dot
done
echo 'Chapter 14 checks passed'
