SUMMARY = "An independent task for keep-going and locking exercises"

python event_peer_write() {
    import os
    with open(os.path.join(d.getVar("WORKDIR"), "peer.txt"), "w") as stream:
        stream.write("peer completed\n")
    bb.plain("CH18 peer completed")
}

python do_build() {
    bb.build.exec_func("event_peer_write", d)
}
do_build[dirs] = "${WORKDIR}"
do_build[lockfiles] = "${TOPDIR}/ch18-shared.lock"
do_build[nostamp] = "1"

python do_fail() {
    bb.build.exec_func("event_peer_write", d)
}
do_fail[dirs] = "${WORKDIR}"
do_fail[lockfiles] = "${TOPDIR}/ch18-shared.lock"
do_fail[nostamp] = "1"
addtask fail
