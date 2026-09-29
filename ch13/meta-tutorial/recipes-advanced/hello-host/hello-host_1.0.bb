SUMMARY = "A tiny source tree patched by our own task"
SRC_URI = "file://hello.c"
S = "${UNPACKDIR}"

inherit tutorial-patch

do_build () {
    cat "${S}/hello.c"
}
