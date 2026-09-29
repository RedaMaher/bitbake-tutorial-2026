SUMMARY = "An explicitly requested prerequisite"

do_prepare () {
    echo source-ready > "${WORKDIR}/ready.txt"
}
do_prepare[dirs] = "${WORKDIR}"
addtask prepare before do_build
