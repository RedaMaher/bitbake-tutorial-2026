SUMMARY = "Intra-recipe ordering and an explicit cross-recipe dependency"
DEPENDS = "task-source"
DIRECT_DEPENDS ?= "task-source:do_prepare"

do_begin () {
    echo begin > "${WORKDIR}/order.txt"
}
do_begin[dirs] = "${WORKDIR}"

do_middle () {
    echo middle >> "${WORKDIR}/order.txt"
}
do_middle[depends] = "${DIRECT_DEPENDS}"

do_finish () {
    echo finish >> "${WORKDIR}/order.txt"
}

addtask begin before do_middle
addtask middle before do_finish
addtask finish before do_build
