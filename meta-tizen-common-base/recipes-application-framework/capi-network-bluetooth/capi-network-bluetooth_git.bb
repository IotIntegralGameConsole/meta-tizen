require capi-network-bluetooth.inc

PRIORITY = "10"

LIC_FILES_CHKSUM ??= "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI += "git://review.tizen.org/platform/core/api/bluetooth;tag=7085576ea3e8948a0738ecce7e4f323be55a5bb8;nobranch=1"

BBCLASSEXTEND += " native "

