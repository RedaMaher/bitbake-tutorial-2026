SUMMARY = "Opt-in, checksum-pinned zlib source archive; no zlib build"
EXCLUDE_FROM_WORLD = "1"
ARCHIVE_SHA256 ?= "9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23"
SRC_URI = "https://zlib.net/fossils/zlib-${PV}.tar.gz"
SRC_URI[sha256sum] = "${ARCHIVE_SHA256}"
S = "${UNPACKDIR}/zlib-${PV}"

inherit tutorial-fetch
do_fetch[vardeps] += "ARCHIVE_SHA256"

do_build () {
    test -f "${S}/zlib.h"
    echo "Verified and unpacked zlib ${PV}; no compilation requested."
}
