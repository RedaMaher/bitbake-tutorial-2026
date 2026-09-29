SUMMARY = "Consume outputs using three different dependency mechanisms"
DEPENDS = "artifact-source"
PACKAGES = "${PN}"
RDEPENDS:${PN} = "artifact-source"

do_explicit () {
    cp "${TUTORIAL_ARTIFACTS}/artifact-source/payload.txt" "${WORKDIR}/explicit.txt"
}
do_explicit[depends] = "artifact-source:do_publish"
do_explicit[dirs] = "${WORKDIR}"

do_via_depends () {
    cp "${TUTORIAL_ARTIFACTS}/artifact-source/payload.txt" "${WORKDIR}/deptask.txt"
}
do_via_depends[deptask] = "do_publish"
do_via_depends[dirs] = "${WORKDIR}"

do_via_runtime () {
    cp "${TUTORIAL_ARTIFACTS}/artifact-source/runtime.txt" "${WORKDIR}/rdeptask.txt"
}
do_via_runtime[rdeptask] = "do_runtime"
do_via_runtime[dirs] = "${WORKDIR}"

addtask explicit before do_build
addtask via_depends before do_build
addtask via_runtime before do_build

do_build () {
    cat "${WORKDIR}/explicit.txt" "${WORKDIR}/deptask.txt" "${WORKDIR}/rdeptask.txt"
}
