SUMMARY = "A standalone custom class extension, not an OE native recipe"
BBCLASSEXTEND = "tutorial-alt"
CH20_VARIANT = "original"

python do_build() {
    import os
    with open(os.path.join(d.getVar("WORKDIR"), "variant.txt"), "w") as stream:
        stream.write("%s: %s\n" % (d.getVar("PN"), d.getVar("CH20_VARIANT")))
}
do_build[dirs] = "${WORKDIR}"
do_build[nostamp] = "1"
