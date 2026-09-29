PROVIDES += "virtual/greeting"

do_build () {
    printf '%s %s\n' "${GREETING_IMPLEMENTATION}" "${PV}" > "${WORKDIR}/selection.txt"
    cat "${WORKDIR}/selection.txt"
}
do_build[dirs] = "${WORKDIR}"
