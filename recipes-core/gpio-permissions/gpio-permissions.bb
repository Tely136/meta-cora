SUMMARY = "Install GPIO udev permissions"
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://60-gpiochip.rules"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${sysconfdir}/udev/rules.d

    install -m 0644 ${WORKDIR}/60-gpiochip.rules \
        ${D}${sysconfdir}/udev/rules.d/60-gpiochip.rules
}

FILES:${PN} += "${sysconfdir}/udev/rules.d/60-gpiochip.rules"