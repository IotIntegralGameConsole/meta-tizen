require ail.inc

PRIORITY = "10"

LIC_FILES_CHKSUM ??= "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI += "git://review.tizen.org/platform/core/appfw/ail;tag=4ff04e8da95abd6fd7c48fefdb32cab2f31a1b33;nobranch=1"

BBCLASSEXTEND += " native "

