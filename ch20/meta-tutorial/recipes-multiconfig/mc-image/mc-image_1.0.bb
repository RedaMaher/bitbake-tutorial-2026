SUMMARY = "Consume an explicitly ordered cross-configuration artifact"
CH19_TOOL_ARTIFACT = "${TOPDIR}/tmp-tools/deploy/tutorial/tool.txt"
CH19_MCDEPENDS ?= "mc:image:tools:mc-tool:do_build"

python do_build() {
    import os
    if d.getVar("BB_CURRENT_MC") != "image":
        bb.fatal("CH19 build this target as mc:image:mc-image")
    source = d.getVar("CH19_TOOL_ARTIFACT")
    if not os.path.isfile(source):
        bb.fatal("CH19 missing tools artifact: check mcdepends and CH19_TOOL_ARTIFACT")
    with open(source) as stream:
        content = stream.read()
    if content != "tool built in tools\n":
        bb.fatal("CH19 unexpected tools artifact contents")
    with open(os.path.join(d.getVar("WORKDIR"), "image.txt"), "w") as stream:
        stream.write("image built in %s\n" % d.getVar("CH19_ROLE"))
        stream.write(content)
}
do_build[mcdepends] = "${CH19_MCDEPENDS}"
do_build[dirs] = "${WORKDIR}"
do_build[nostamp] = "1"
EXCLUDE_FROM_WORLD = "1"
