inherit tutorial-patch

B = "${WORKDIR}/build"
D = "${WORKDIR}/dest"
TUTORIAL_CC ?= "cc"
TUTORIAL_CFLAGS ?= "-O2 -Wall -Wextra"

do_configure () {
    command -v "${TUTORIAL_CC}"
    printf 'CC := %s\nCFLAGS := %s\n' "${TUTORIAL_CC}" "${TUTORIAL_CFLAGS}" > config.mk
}
do_configure[cleandirs] = "${B}"
do_configure[dirs] = "${B}"

do_compile () {
    make -f "${S}/Makefile" SRC_DIR="${S}"
}
do_compile[dirs] = "${B}"

do_install () {
    install -d "${D}/usr/bin"
    install -m 0755 "${B}/hello-host" "${D}/usr/bin/hello-host"
}
do_install[cleandirs] = "${D}"

addtask configure after do_patch before do_compile
addtask compile before do_install
addtask install before do_build
