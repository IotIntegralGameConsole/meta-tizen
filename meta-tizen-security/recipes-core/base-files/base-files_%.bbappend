# Install default Smack rules, copied from a running Tizen IVI 3.0.
# Not sure where these get maintained in Tizen (file not owned by
# any rpm package).
do_install_append () {
    mkdir -p ${D}/${sysconfdir}/smack/accesses.d/
    cat >${D}/${sysconfdir}/smack/accesses.d/default-access-domains <<EOF
System _ -----l
System System::Log rwxa--
System System::Run rwxat-
System System::Shared rwxat-
System ^ rwxa--
System User rwx---
_ System::Run rwxat-
_ System -wx---
^ System::Log rwxa--
^ System::Run rwxat-
^ System rwxa--
User _ -----l
User User::App:Shared rwxat-
User User::Home rwxat-
User System::Log rwxa--
User System::Run rwxat-
User System::Shared r-x---
User System -wx---
EOF
}

# Do not rely on an rpm with manifest support. Apparently that approach
# will no longer be used in Tizen 3.0. Instead set special Smack attributes
# via postinst. This is much easier to use with bitbake, too:
# - no need to maintain a patched rpm
# - works for directories which are not packaged by default when empty
pkg_postinst_${PN}() {
    #!/bin/sh -e

    # https://review.tizen.org/gerrit/gitweb?p=platform/upstream/filesystem.git;a=blob;f=packaging/filesystem.manifest:
    # <filesystem path="/etc" label="System::Shared" type="transmutable" />
    mkdir -p $D${sysconfdir}
    chsmack -t $D${sysconfdir}
    chsmack -a 'System::Shared' $D${sysconfdir}

    # <filesystem path="/tmp" label="*" />
    mkdir -p $D/tmp
    chsmack -a '*' $D/tmp

    # <filesystem path="/var/log" label="System::Log" type="transmutable" />
    # <filesystem path="/var/tmp" label="*" />
    # These are in a file system mounted by systemd. We patch the systemd service
    # to set these attributes.
}
