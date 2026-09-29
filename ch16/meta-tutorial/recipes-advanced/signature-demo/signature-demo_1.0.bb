SUMMARY = "Measure task reuse, metadata dependencies and source checksums"
SIGNATURE_INPUT_DIR ?= "${THISDIR}/files"
SIGNATURE_MESSAGE ?= "first"
SIGNATURE_KEY = "SIGNATURE_MESSAGE"
DISPLAY_NOTE ?= "Informational log only"
FILESPATH:prepend = "${SIGNATURE_INPUT_DIR}:"
SRC_URI = "file://input.txt"
S = "${UNPACKDIR}"

inherit tutorial-fetch

python do_measure () {
    from pathlib import Path
    message = d.getVar(d.getVar("SIGNATURE_KEY"))
    if not message:
        bb.fatal("SIGNATURE_KEY must select a nonempty message")
    source = Path(d.getVar("S")) / "input.txt"
    work = Path(d.getVar("WORKDIR"))
    (work / "result.txt").write_text(message + ":" + source.read_text().strip() + "\n")
    with (work / "measure-runs.txt").open("a") as stream:
        stream.write("run\n")
    bb.note(d.getVar("DISPLAY_NOTE"))
}
do_measure[dirs] = "${WORKDIR}"
do_measure[vardeps] += "${SIGNATURE_KEY}"
do_measure[vardepsexclude] = "DISPLAY_NOTE"
addtask measure after do_unpack before do_build
