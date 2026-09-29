SUMMARY = "Publish files for build-time and runtime dependency exercises"
PACKAGES = "${PN}"
ARTIFACT_MESSAGE ?= "Shared artifact v1"

do_publish () {
    printf '%s\n' "${ARTIFACT_MESSAGE}" > "${TUTORIAL_ARTIFACTS}/${PN}/payload.txt"
}
do_publish[dirs] = "${TUTORIAL_ARTIFACTS}/${PN}"

do_runtime () {
    cp "${TUTORIAL_ARTIFACTS}/${PN}/payload.txt" "${TUTORIAL_ARTIFACTS}/${PN}/runtime.txt"
}

addtask publish before do_runtime
addtask runtime before do_build
