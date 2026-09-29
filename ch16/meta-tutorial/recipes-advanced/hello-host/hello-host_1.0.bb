SUMMARY = "Configure, compile and install a small host program"
SRC_URI = "file://hello.c file://Makefile"
S = "${UNPACKDIR}"

inherit tutorial-build

do_build () {
    "${D}/usr/bin/hello-host"
}
