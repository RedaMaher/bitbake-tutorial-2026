SUMMARY = "Publish a small artifact in the tools configuration"

python do_build() {
    import os
    if d.getVar("BB_CURRENT_MC") != "tools":
        bb.fatal("CH19 build this target as mc:tools:mc-tool")
    output = os.path.join(d.getVar("DEPLOY_DIR"), "tutorial")
    bb.utils.mkdirhier(output)
    with open(os.path.join(output, "tool.txt"), "w") as stream:
        stream.write("tool built in %s\n" % d.getVar("CH19_ROLE"))
}
do_build[nostamp] = "1"
EXCLUDE_FROM_WORLD = "1"
