UNPACKDIR = "${WORKDIR}/sources"

python do_fetch () {
    import bb.fetch2
    fetcher = bb.fetch2.Fetch((d.getVar("SRC_URI") or "").split(), d)
    fetcher.download()
}
do_fetch[dirs] = "${DL_DIR}"
do_fetch[network] = "1"
do_fetch[file-checksums] = "${@bb.fetch2.get_checksum_file_list(d)}"

python do_unpack () {
    import bb.fetch2
    fetcher = bb.fetch2.Fetch((d.getVar("SRC_URI") or "").split(), d)
    fetcher.unpack(d.getVar("UNPACKDIR"))
}
do_unpack[cleandirs] = "${UNPACKDIR}"

addtask fetch before do_unpack
addtask unpack before do_build
