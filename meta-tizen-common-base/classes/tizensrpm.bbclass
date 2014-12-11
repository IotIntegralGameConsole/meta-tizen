# This class enables the conversion of recipes into .src.rpm.
#
# To use it, add meta-translator to bblayer.conf and
#    INHERIT += "tizensrpm.bbclass"
# to a local.conf. Do not use it when building Tizen with Yocto,
# because it affects binaries (for example, when clearing compile
# flags).
#
# The .src.rpm will be in tmp/deploy/sources/<arch>/<recipe> and
# (for convenience) the .spec files in tmp/deploy/rpm/specs.

# Activate .bb -> .src.rpm translator.
inherit archiver
inherit translator
ARCHIVER_MODE[src] = "original"
ARCHIVER_MODE[srpm] = "1"

# Additional converter code for Tizen.
inherit srpm-replacelnr
inherit srpm-manifest

# By default, use file-list-generator.py to generate file lists as
# part of rpmbuild. This avoids the need to maintain exact file lists
# in the Tizen adaption layers. Can be changed on a per-recipe basis
# in .bbappend.
SRPM_DYNAMIC_FILE_LISTS = "1"

# Simplify compile flags in .spec.
TARGET_CPPFLAGS = ""
TARGET_CFLAGS = ""
TARGET_CXXFLAGS = ""
TARGET_LDFLAGS = ""
# Undo meta/conf/distro/include/tclibc-glibc.inc:
CXXFLAGS_remove = "-fvisibility-inlines-hidden"
# Undo meta/conf/distro/include/as-needed.inc:
LDFLAGS_remove = "-Wl,--as-needed"

# Tizen maintains system users statically in
# https://review.tizen.org/gerrit/#/admin/projects/platform/upstream/setup
# How to add/remove users during rpm install is under debate,
# see https://www.mail-archive.com/dev%40lists.tizen.org/msg05033.html
#
# What currently works is to depend on the [user/group]/[add/del] commands
# and invoke them like the base useradd.bbclass does.
#
# When compiling a .spec file, no additional build tools are needed, so
# clear USERADDDEPENDS.
USERADDDEPENDS_srpm = ""

# Running package tests (https://wiki.yoctoproject.org/wiki/Ptest) is
# not supported.
SRC_URI_remove = "file://run-ptest"

# Don't split out -staticdev (not used in Tizen) and -dbg (handled
# automatically by Tizen). This catches most cases, but not all.
PACKAGES_remove = "${PN}-staticdev ${PN}-dbg lib${PN}-staticdev lib${PN}-dbg"

# Remove some more.
PACKAGES_remove = "\
liblzma-staticdev \
liblzma-dbg \
libiw-dbg \
ifrename-dbg \
libwrap-staticdev \
libsysfs-staticdev \
python-distutils-staticdev \
libpci-dbg \
openssl-engines-dbg \
libltdl-dbg \
libltdl-staticdev \
harfbuzz-icu-dbg \
glibc-localedatas \
dbus-glib-tests-dbg \
libbz2-staticdev \
"

# All Tizen packages from the same project are supposed to have the
# same group. The actual group needs to be set on a per-recipe basis
# via SECTION.
SRPM_SAME_GROUP = "1"

# Rename packages generated by the .spec files to match the way
# how Tizen traditionally was packaged. Relevant for existing
# packages refering to packages by name and replacing older
# packages.
#
# Only packages already listed in PACKAGES get renamed. When
# there is a need to create additional packages, that has to
# be done by extending PACKAGES in a .bbappend file (see
# expat_%.bbappend).
#
# This renaming must be done globally because it affects both
# the recipe providing the packages and dependencies on them
# in other packages. The renaming is done as the last step of
# the conversion, so all other .bb meta data and conversion tweaks
# (like SRPM_REWRITE_DEPENDS and SRPM_REWRITE_RUNTIME_DEPS) must
# use the original naming, like -dev for development packages.
#
# Each assignment is of the format <regex>=<replacement>, as used
# by Python's re.sub(). The entire regex must match the dependency.
# All of the replacements get applied in order.

# Recipe-specific renames. Done here because they make also affect
# dependency specifications in recipes using the renamed packages.
SRPM_RENAME += "\
((?:lib)?)sqlite3(.*)=\1sqlite\2 \
alsa-lib-dev=libasound-dev \
atk=libatk \
bjam=boost-jam \
boost=libboost \
cairo=libcairo \
db-bin(.*)=db4-utils\1 db($|[\s-].*)=db4\1 \
dbus=libdbus \
expat-dev=libexpat-dev \
freetype=libfreetype \
gcc=libgcc \
gconf(.*)=gconf-dbus\1 \
gdb=libgdb \
gdbm=libgdbm \
glib-2.0=glib2 \
gmp=libgmp \
gnutls-xx(.*)=libgnutlsxx\1 gnutls(.*)=libgnutls\1 \
harfbuzz=libharfbuzz \
icu=libicu \
json-glib=libjson-glib \
kmod-dev=libkmod-dev \
libcheck(.*)=check\1 \
libcms=liblcms2 lcms-dev=libcms2-dev lcms=lcms2 \
libjpeg-turbo=libjpeg libjpeg-turbo-dev=libjpeg-dev \
libnl=libnl3 libnl-(.*)=libnl3-\1 \
libpam(.*)=pam\1 \
libpcre-dev=pcre-dev pcregrep=pcre \
libsndfile1(.*)=libsndfile\1 \
libsqlite-dev=sqlite-dev \
libusb1(.*)=libusb\1 \
libx11(.*)=libX11\1 \
libxft(.*)=libXft\1 \
libxml-parser-perl(.*)=perl-XML-Parser\1 \
llvm3.3(.*)=llvm\1 \
mpfr=libmpfr \
mtdev=libmtdev \
ncurses=libncurses \
nettle-dev=libnettle-dev \
opencv=libopencv \
openssl=libopenssl \
p11-kit=libp11-kit \
pango=libpango \
pkgconfig=pkg-config pkgconfig-(.*)=pkg-config-\1 \
popt=libpopt \
pth=libpth \
python-pygobject(.*)=python-pygobject\1 \
readline=libreadline \
speex=libspeex \
wayland=libwayland \
zip=libzip \
"

# Finally, rename -dev to -devel.
SRPM_RENAME += "(.*)-dev=\1-devel"


# Rewrite runtime dependencies. Same format as SRPM_RENAME.
# The dependency that the regex is applied to may include
# version specifications (e.g. "foobar (>= 1.0)").

# Always present, not explicitly provided by anything.
SRPM_REWRITE_RUNTIME_DEPS += "base-files="

# Added by useradd.bbclass, does not exist in Tizen.
SRPM_REWRITE_RUNTIME_DEPS += "shadow="

# base-passwd provides useradd; let's assume that whatever provides
# that also provides the rest of base-passwd. Can be improved once
# Tizen has a "usertools" feature.
SRPM_REWRITE_RUNTIME_DEPS += "base-passwd=/usr/sbin/useradd"

# Python modules provided by Python are not tracked separately in Tizen.
SRPM_REWRITE_RUNTIME_DEPS += "\
python-core=python \
python-textutils=python \
"

# The perl-modules meta package is not supported because it
# relies on RRECOMMENDS, which do not get translated. Instead
# we depend on the packages split out by the perl recipe and
# perl itself, which is where we package the other core modules in Tizen.
#
# Dependencies on individual modules must also get replaced,
# except for those which really are separate.
SRPM_REWRITE_RUNTIME_DEPS += "\
perl-modules=perl,perl-module-cpan,perl-module-cpanplus,perl-module-unicore \
perl-module-.*?(?!(cpan|cpanplus|unicore|.*-config|.*-config-heavy|config|config-heavy))=perl \
"

# Perl naming of additional modules differs.
SRPM_REWRITE_DEPENDS_append += "\
perl-xml-parser=perl-XML-Parser \
perl-html-parser=perl-HTML-Parser \
"

# There's no separate -dev.
SRPM_REWRITE_DEPENDS_append += "\
perl=perl \
"

# Rewrite build dependencies. In contrast to runtime dependencies,
# these are simple string mappings. The replacement may consist
# of zero or more comma-separated package names.

# Assumed to exist or not matter.
SRPM_REWRITE_DEPENDS += "\
   base-files= \
   initscripts= \
   update-rc.d-native= \
   virtual/update-alternatives= \
   systemd-systemctl-native= \
   gobject-introspection-stub= \
"

# Packages named differently in Tizen.
SRPM_REWRITE_DEPENDS_append += " \
bjam-native=boost-jam \
texinfo-native=makeinfo \
"

# Some recipes inherit gnome.bbclass although they do not
# need all the dependencies that this sets (for example, json-glib
# unnecessaril depends on gtk-update-icon-cache-native and hicolor-icon-theme).
# Filter out the things we don't have and need in Tizen.
SRPM_REWRITE_DEPENDS_append = " \
gtk-update-icon-cache-native= \
"

# Explicit build dependencies for virtual dependencies or
# dependencies with different providers.
SRPM_REWRITE_DEPENDS_append = " \
db=db4-dev \
jpeg=libjpeg-dev \
virtual/db=db4-dev \
virtual/egl=pkgconfig(egl) \
virtual/libgl=pkgconfig(gl) \
virtual/libgles2=pkgconfig(glesv2) \
virtual/libiconv=glibc-dev \
virtual/libintl=gettext-dev \
virtual/libx11=libx11-dev \
virtual/mesa=mesa-dev \
"

# The functionality from util-linux is provided by multiple
# different projects in Tizen. We don't know what from
# util-linux is needed, so require everything.
SRPM_REWRITE_DEPENDS_append = " util-linux=libblkid-dev,libmount-dev,pkgconfig(uuid)"

# Avoid hard dependency on specific packages via the corresponding
# pkgconfig(<.pc name>) or perl(<package>).
#
# Best done only where the package name has
# an unambiguous mapping, otherwise better depend on the -devel
# package via the hard-coded rewrite default rules.
#
# This started as the inverse mapping in .spec2yoctorc
# from the spec2yocto converter.
SRPM_REWRITE_DEPENDS_append = " \
CommonAPI-DBus=pkgconfig(CommonAPI-DBus) \
CommonAPI=pkgconfig(CommonAPI) \
ail=pkgconfig(ail) \
alarm-manager=pkgconfig(alarm-service) \
alsa-lib=pkgconfig(alsa) \
alsa-scenario=pkgconfig(libascenario) \
app-svc=pkgconfig(appsvc) \
audio-session-manager=pkgconfig(audio-session-mgr) \
aul=pkgconfig(aul) \
badge=pkgconfig(badge) \
bluetooth-frwk=pkgconfig(bluetooth-api) \
bluez4=pkgconfig(bluez) \
bundle=pkgconfig(bundle) \
bundle=pkgconfig(bundle) \
bzip2=pkgconfig(bzip2) \
calendar-service=pkgconfig(calendar-service2) \
capi-appfw-app-manager=pkgconfig(capi-appfw-app-manager) \
capi-appfw-application=pkgconfig(capi-appfw-application) \
capi-appfw-package-manager=pkgconfig(capi-appfw-package-manager) \
capi-base-common=pkgconfig(capi-base-common) \
capi-content-media-content=pkgconfig(capi-content-media-content) \
capi-location-manager=pkgconfig(capi-location-manager) \
capi-media-image-util=pkgconfig(capi-media-image-util) \
capi-media-sound-manager=pkgconfig(capi-media-sound-manager) \
capi-media-wav-player=pkgconfig(capi-media-wav-player) \
capi-network-bluetooth=pkgconfig(capi-network-bluetooth) \
capi-network-connection=pkgconfig(capi-network-connection) \
capi-network-nfc=pkgconfig(capi-network-nfc) \
capi-network-tethering=pkgconfig(capi-network-tethering) \
capi-network-wifi=pkgconfig(capi-network-wifi) \
capi-system-device=pkgconfig(capi-system-device) \
capi-system-info=pkgconfig(capi-system-info) \
capi-system-power=pkgconfig(capi-system-power) \
capi-system-runtime-info=pkgconfig(capi-system-runtime-info) \
capi-system-sensor=pkgconfig(capi-system-sensor) \
capi-system-system-settings=pkgconfig(capi-system-system-settings) \
capi-web-favorites=pkgconfig(capi-web-favorites) \
capi-web-url-download=pkgconfig(capi-web-url-download) \
contacts-service=pkgconfig(contacts-service2) \
curl=pkgconfig(libcurl) \
dbus-glib=pkgconfig(dbus-glib-1) \
dbus=pkgconfig(dbus-1) \
dlog=pkgconfig(dlog) \
dlt-daemon=pkgconfig(automotive-dlt) \
download-provider=pkgconfig(download-provider-interface) \
drm-client=pkgconfig(drm-client) \
dukgenerator=pkgconfig(dukgenerator) \
ecryptfs-utils=pkgconfig(libecryptfs) \
edbus=pkgconfig(edbus) \
edje=pkgconfig(edje) \
eet=pkgconfig(eet) \
efreet=pkgconfig(efreet) \
eina=pkgconfig(eina) \
eldbus=pkgconfig(eldbus) \
elementary=pkgconfig(elementary) \
emotion=pkgconfig(emotion) \
ethumb=pkgconfig(ethumb) \
evas=pkgconfig(evas) \
evolution-data-server=pkgconfig(libebook-contacts-1.2) \
expat=pkgconfig(expat) \
fontconfig=pkgconfig(fontconfig) \
freetype=pkgconfig(freetype2) \
fribidi=pkgconfig(fribidi) \
gconf=pkgconfig(gconf-2.0) \
gcr=pkgconfig(gcr-base-3) \
gnutls=pkgconfig(gnutls) \
gsignond=pkgconfig(gsignond) \
gssdp=pkgconfig(gssdp-1.0) \
gstreamer1.0-plugins-base=pkgconfig(gstreamer-plugins-base-1.0) \
gstreamer1.0=pkgconfig(gstreamer-1.0) \
gupnp-av=pkgconfig(gupnp-av-1.0) \
gupnp-dlna=pkgconfig(gupnp-dlna-2.0) \
gupnp=pkgconfig(gupnp-1.0) \
harfbuzz=pkgconfig(harfbuzz) \
heynoti=pkgconfig(heynoti) \
ibus=pkgconfig(ibus-1.0) \
icu=pkgconfig(icu-i18n) \
iniparser=pkgconfig(iniparser) \
json-c=pkgconfig(json) \
json-glib=pkgconfig(json-glib-1.0) \
kmod=pkgconfig(libkmod) \
lcms=pkgconfig(lcms2) \
libaccounts-svc=pkgconfig(accounts-svc) \
libbullet=pkgconfig(bullet) \
libcap=pkgconfig(libcap) \
libcheck=pkgconfig(check) \
libcom-core=pkgconfig(com-core) \
libcryptsvc=pkgconfig(cryptsvc) \
libdevice-node=pkgconfig(device-node) \
libdevice-node=pkgconfig(device-node) \
libdevice-node=pkgconfig(devman_plugin) \
libdrm=pkgconfig(libdrm) \
libexif=pkgconfig(libexif) \
libffi=pkgconfig(libffi) \
libgee=pkgconfig(gee-0.8) \
libgsasl=pkgconfig(libgsasl) \
libgsignon-glib=pkgconfig(libgsignon-glib) \
libhangul=pkgconfig(libhangul) \
libical=pkgconfig(libical) \
libiri=pkgconfig(libiri) \
libmedia-service=pkgconfig(libmedia-service) \
libmedia-thumbnail=pkgconfig(media-thumbnail) \
libmm-common=pkgconfig(mm-common) \
libmm-fileinfo=pkgconfig(mm-fileinfo) \
libmm-log=pkgconfig(mm-log) \
libmm-player=pkgconfig(mm-player) \
libmm-session=pkgconfig(mm-session) \
libmm-sound=pkgconfig(mm-sound) \
libmm-ta=pkgconfig(mm-ta) \
libnet-client=pkgconfig(network) \
libpciaccess=pkgconfig(pciaccess) \
libpcre=pkgconfig(libpcre) \
libpng=pkgconfig(libpng) \
libprivilege-control=pkgconfig(libprivilege-control) \
libpthread-stubs=pkgconfig(pthread-stubs) \
librua=pkgconfig(rua) \
libsecret=pkgconfig(libsecret-unstable) \
libsf-common=pkgconfig(sf_common) \
libslp-db-util=pkgconfig(db-util) \
libslp-location=pkgconfig(location) \
libslp-memo=pkgconfig(memo) \
libsndfile1=pkgconfig(sndfile) \
libsoup-2.4=pkgconfig(libsoup-2.4) \
libsvi=pkgconfig(feedback),pkgconfig(svi) \
libtapi3=pkgconfig(tapi-3.0) \
libtapi=pkgconfig(tapi) \
libtasn1=pkgconfig(libtasn1) \
libtbm=pkgconfig(libtbm) \
libusb=pkgconfig(libusb-1.0) \
libwbxml2=pkgconfig(libwbxml2) \
libwebsockets=pkgconfig(libwebsockets) \
libwifi-direct=pkgconfig(wifi-direct) \
libxkbcommon=pkgconfig(xkbcommon) \
libxml2=pkgconfig(libxml-2.0) \
libxslt=pkgconfig(libxslt) \
lua=pkgconfig(lua) \
media-server=pkgconfig(libmedia-utils) \
message-port=pkgconfig(message-port) \
msg-service=pkgconfig(msg-service) \
mtdev=pkgconfig(mtdev) \
neardal=pkgconfig(neardal) \
notification=pkgconfig(notification) \
nss=pkgconfig(nss) \
ofono=pkgconfig(ofono) \
opencv=pkgconfig(opencv) \
p11-kit=pkgconfig(p11-kit-1) \
pciutils=pkgconfig(libpci) \
pims-ipc=pkgconfig(pims-ipc) \
pixman=pkgconfig(pixman-1) \
pkgconfig=pkgconfig(pkg-config) \
poppler=pkgconfig(poppler-glib) \
popt=pkgconfig(popt) \
privacy-manager-server=pkgconfig(privacy-manager-client) \
python=pkgconfig(python-2.7) \
sbc=pkgconfig(sbc) \
secure-storage=pkgconfig(secure-storage) \
security-server=pkgconfig(security-server) \
sensor=pkgconfig(sensor) \
smack=pkgconfig(libsmack) \
speex=pkgconfig(speexdsp) \
sqlite3=pkgconfig(sqlite3) \
status=pkgconfig(status) \
sync-agent=pkgconfig(sync-agent) \
syspopup=pkgconfig(syspopup-caller) \
tdb=pkgconfig(tdb) \
tiff=pkgconfig(libtiff-4) \
tizen-platform-config=pkgconfig(libtzplatform-config) \
tizen-platform-wrapper=pkgconfig(tizen-platform-wrapper) \
udev=pkgconfig(udev) \
usbutils=pkgconfig(usbutils) \
vconf-internal-keys=pkgconfig(vconf-internal-keys) \
weston=pkgconfig(weston) \
xdgmime=pkgconfig(xdgmime) \
xmlsec1=pkgconfig(xmlsec1) \
zeromq=pkgconfig(libzmq) \
"

# elfutils dev files are split up in Tizen such that there is no single
# -dev file pulling in everything. Need to depend on all.
SRPM_REWRITE_DEPENDS_append = "elfutils=libasm-dev,libdw-dev,libebl-dev,libelf-dev"

# Activate license translation to SPDX. The code is part of the package-srpm.bbclass.
# .bb meta data sometimes declares licenses which are not known to the Tizen rpmlint.
# One common case, Public Domain, is handled below by declaring that Tizen relicenses
# the code under a very permissive license. Other cases need to be handled in
# .bbappend files, either by mapping the license (preferred, because it re-uses the
# upstream license tracking) or redeclaring the license (more work).
SRPM_LICENSE_HOOK = "license_to_tizen"

# Relicense "Public Domain" under a permissive, simplistic license.
# See http://wiki.spdx.org/view/Legal_Team/Decisions/Dealing_with_Public_Domain_within_SPDX_Files
SPDXLICENSEMAP[PD] = "ISC"

# BSD seems to be used for several different BSD flavors (BSD-2-Clause, BSD-3-Clause).
# Needs to be checked and set per recipe.
# SPDXLICENSEMAP[BSD] = "BSD-2-Clause"

# Tizen has not used an epoch for these packages while Yocto has. We could
# introduce one now without side effects, which would be cleaner than
# overriding them here? TODO: decide.
PE_pn-glib-2.0 = ""
PE_pn-libnl = ""
PE_pn-libusb-compat = ""
PE_pn-mobile-broadband-provider-info = ""
PE_pn-pixman = ""
PE_pn-unzip = ""
