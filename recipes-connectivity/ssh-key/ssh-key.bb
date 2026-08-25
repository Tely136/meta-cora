SUMMARY = "Install SSH public key for amd-edf"
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://id_ed25519.pub"

S = "${WORKDIR}"

do_install() {
    install -d -m 0700 ${D}/home/amd-edf/.ssh

    install -m 0600 ${WORKDIR}/id_ed25519.pub \
        ${D}/home/amd-edf/.ssh/authorized_keys
}

FILES:${PN} += "/home/amd-edf/.ssh"