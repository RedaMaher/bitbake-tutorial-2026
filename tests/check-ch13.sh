#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../ch13/build"
bitbake hello-host
grep -q 'Hello from standalone BitBake.' tmp/work/hello-host-1.0-r0/sources/hello.c
grep -q 'Hello before patch.' ../meta-tutorial/recipes-advanced/hello-host/files/hello.c
bitbake -g hello-host
grep -q '"hello-host.do_patch" -> "hello-host.do_unpack"' task-depends.dot
bitbake -C unpack hello-host
grep -q 'Hello from standalone BitBake.' tmp/work/hello-host-1.0-r0/sources/hello.c
echo 'Chapter 13 checks passed'
