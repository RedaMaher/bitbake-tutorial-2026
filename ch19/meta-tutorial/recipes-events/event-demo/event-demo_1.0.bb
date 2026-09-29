SUMMARY = "Observe events, ordered hooks and intentional task failure"
CH18_FAIL ?= "0"

python do_prepare() {
    bb.note("CH18 prepare: a stamped prerequisite")
}
addtask prepare before do_build

python event_before() {
    import os
    with open(os.path.join(d.getVar("WORKDIR"), "hook-order.txt"), "w") as stream:
        stream.write("pre\n")
    bb.note("CH18 pre hook")
}

python do_build() {
    import os
    with open(os.path.join(d.getVar("WORKDIR"), "hook-order.txt"), "a") as stream:
        stream.write("body\n")
    bb.note("CH18 task body")
    bb.warn("CH18 demonstration warning: the task can still succeed")
    bb.debug(1, "CH18 debug detail")
}

python event_after() {
    import os
    with open(os.path.join(d.getVar("WORKDIR"), "hook-order.txt"), "a") as stream:
        stream.write("post\n")
    bb.note("CH18 post hook")
}

do_build[prefuncs] += "event_before"
do_build[postfuncs] += "event_after"
do_build[dirs] = "${WORKDIR}"
do_build[lockfiles] = "${TOPDIR}/ch18-shared.lock"
do_build[nostamp] = "1"

python do_fail() {
    if d.getVar("CH18_FAIL") == "1":
        bb.fatal("CH18 intentional failure: set CH18_FAIL back to 0")
    bb.plain("CH18 failure exercise recovered")
}
do_fail[nostamp] = "1"
addtask fail
