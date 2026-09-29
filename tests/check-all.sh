#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v bitbake >/dev/null
version=$(bitbake --version)
case "$version" in
    *"version 2.18.0") ;;
    *) echo "These checks target BitBake 2.18.0; found: $version" >&2; exit 2 ;;
esac
if [[ $# -eq 0 ]]; then
    set -- 10 11 12 13 14 15 16 17 18 19 20
fi
for chapter in "$@"; do
    case "$chapter" in
        10|11|12|13|14|15|16|17|18|19|20)
            bash "tests/check-ch${chapter}.sh"
            ;;
        *) echo "Unknown chapter: $chapter (expected 10 through 20)" >&2; exit 2 ;;
    esac
done
