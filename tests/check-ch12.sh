#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../ch12/build"
config=$(mktemp --suffix=.conf)
log=$(mktemp)
trap 'rm -f "$config" "$log"' EXIT
printf 'BB_NO_NETWORK = "1"\n' > "$config"
bitbake -R "$config" local-source
cmp ../meta-tutorial/recipes-advanced/local-source/files/message.txt \
    tmp/work/local-source-1.0-r0/sources/message.txt
bitbake -g local-source
grep -q '"local-source.do_unpack" -> "local-source.do_fetch"' task-depends.dot
if [[ "${1:-}" == "--network" ]]; then
    bitbake remote-source
    test -f tmp/work/remote-source-1.3.1-r0/sources/zlib-1.3.1/zlib.h
    bitbake -R "$config" -f -c fetch remote-source
    printf 'ARCHIVE_SHA256 = "%064d"\n' 0 >> "$config"
    if bitbake -R "$config" -f -c fetch remote-source > "$log" 2>&1; then
        echo 'Incorrect archive checksum unexpectedly accepted' >&2
        exit 1
    fi
    grep -qi 'checksum mismatch' "$log"
    # The fetcher quarantines a bad cached download; restore the valid cache.
    bitbake -f -c fetch remote-source
elif [[ $# -ne 0 ]]; then
    echo 'Usage: check-ch12.sh [--network]' >&2
    exit 2
fi
echo 'Chapter 12 checks passed'
