SUMMARY = "An offline source fetched through FILESPATH"
SRC_URI = "file://message.txt"
S = "${UNPACKDIR}"

inherit tutorial-fetch

do_build () {
    cat "${S}/message.txt"
}
