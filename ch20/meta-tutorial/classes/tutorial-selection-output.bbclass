python do_build() {
    import os
    with open(os.path.join(d.getVar("WORKDIR"), "selection.txt"), "w") as stream:
        stream.write(d.getVar("CH20_SELECTED") + "\n")
}
do_build[dirs] = "${WORKDIR}"
do_build[nostamp] = "1"
