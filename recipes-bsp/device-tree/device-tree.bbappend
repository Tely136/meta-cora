FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

EXTRA_DT_INCLUDE_FILES:append = " cora-z7-07s-user.dtsi"

# Only the current MCS hardware has the reader node referenced by this include.
# Keep this outside generated conf/dts files so parse-sdt can be rerun safely.
EXTRA_DT_INCLUDE_FILES:append:cora-mcs-generated = " cora-mcs-reader-uio.dtsi"
