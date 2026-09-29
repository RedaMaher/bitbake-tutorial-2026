SUMMARY = "Assignment timing, overrides and task directory flags"

LATE = "one"
LAZY = "${LATE}"
EARLY := "${LATE}"
LATE = "two"
WEAK ??= "fallback"
WEAK ?= "default"
WORDS = "alpha beta"
WORDS:append = " gamma"
WORDS:prepend = "zero "
WORDS:remove = "beta"
OVERRIDES .= ":demo"
MESSAGE = "base"
MESSAGE:demo = "override"
LABEL = "recipe"
LABEL:task-report = "task"

python () {
    d.setVar("PARSED", "anonymous:" + d.getVar("MESSAGE"))
}

do_report () {
    printf '%s\n' "lazy=${LAZY}" "early=${EARLY}" "weak=${WEAK}" \
        "message=${MESSAGE}" "parsed=${PARSED}" "label=${LABEL}" > result.txt
    printf 'words=' >> result.txt
    echo ${WORDS} >> result.txt
    echo run >> runs.txt
    echo fresh > "${WORKDIR}/scratch/fresh.txt"
}
do_report[nostamp] = "1"
do_report[cleandirs] = "${WORKDIR}/scratch"
do_report[dirs] = "${WORKDIR}/preserved"
addtask report before do_build
