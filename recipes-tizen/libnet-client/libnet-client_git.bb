require libnet-client.inc

PRIORITY = "10"

LIC_FILES_CHKSUM ??= "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI += "git://review.tizen.org/platform/core/connectivity/libnet-client;tag=92801f03fd813e8d635035977d35b6577ba19fe1;nobranch=1"

BBCLASSEXTEND += " native "

