SUMMARY = "Static network configuration for Cora Z7"
LICENSE = "CLOSED"

SRC_URI = "file://20-wired.network"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/20-wired.network \
        ${D}${sysconfdir}/systemd/network/20-wired.network
}

FILES:${PN} += "${sysconfdir}/systemd/network/20-wired.network"