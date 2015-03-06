FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# Enable Smack support.
DEPEND += "smack"
SRC_URI += "file://pam-smack-so.patch"

# Tizen has to patch several pam files in different packages (ssh, shadow).
# In OE, we have common-session which gets included by those, so we
# only need to add pam_smack.so once.
do_install_append () {
    for i in common-session-noninteractive common-session; do
        f=${D}/${sysconfdir}/pam.d/$i
        [ -f $f ] && echo >>$f "session required pam_smack.so"
    done
}

# Needed for the modified common-session.
RDEPENDS_${PN}-runtime_append = " pam-plugin-smack"
