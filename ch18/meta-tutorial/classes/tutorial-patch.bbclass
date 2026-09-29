inherit tutorial-fetch

PATCH_FILE ?= "${UNPACKDIR}/greeting.patch"

do_patch () {
    patch --batch --forward -p1 < "${PATCH_FILE}"
}
do_patch[dirs] = "${S}"
addtask patch after do_unpack before do_build
