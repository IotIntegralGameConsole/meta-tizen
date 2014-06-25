DESCRIPTION = "Media thumbnail service Library"
HOMEPAGE = "http://nohomepage.org"
SECTION = "Multimedia/Libraries"
LICENSE = "Apache-2.0"

SRC_URI = ""

S = "${WORKDIR}/git"

inherit autotools-brokensep

BBCLASSEXTEND = ""
PROVIDES = ""

#PROVIDES by libmedia-thumbnail


#PROVIDES by media-thumbnail-server


#PROVIDES by libmedia-thumbnail-dev


#PROVIDES by libmedia-thumbnail-test


RDEPENDS = ""
#RDEPENDS of libmedia-thumbnail (${PN})
RDEPENDS_${PN} += "media-server"

#RDEPENDS of media-thumbnail-server (media-thumbnail-server)
RDEPENDS_media-thumbnail-server += "libmedia-thumbnail"

#RDEPENDS of libmedia-thumbnail-dev (${PN}-dev)
RDEPENDS_${PN}-dev += "libmedia-thumbnail"

#RDEPENDS of libmedia-thumbnail-test (${PN}-test)
RDEPENDS_${PN}-test += "libmedia-thumbnail"


DEPENDS = ""
#DEPENDS of libmedia-thumbnail
DEPENDS += "libmm-fileinfo"
DEPENDS_append_class-native = " cmake-native"
DEPENDS_append_class-target = " cmake-native"
DEPENDS += "drm-client"
DEPENDS += "evas"
DEPENDS += "tizen-platform-config"
DEPENDS += "aul"
DEPENDS += "dlog"
DEPENDS += "libexif"
DEPENDS += "libmm-utility"
DEPENDS += "media-server"
DEPENDS += "heynoti"
DEPENDS += "ecore"
DEPENDS += "vconf"

do_prep() {
 cd ${S}
 chmod -Rf a+rX,u+w,g-w,o-w ${S}
 #setup -q
 cp ${S}/packaging/libmedia-thumbnail.manifest ${S}/packaging/libmedia-thumbnail-devel.manifest ${S}/packaging/media-thumbnail-server.manifest .
 
 
 
}
do_patch_append() {
    bb.build.exec_func('do_prep', d)
}

do_configure() {
}

do_compile() {
 cd ${S}
 LANG=C
 export LANG
 unset DISPLAY
 CFLAGS="-O2 -g -m64 -fmessage-length=0 -D_FORTIFY_SOURCE=2 -fstack-protector -funwind-tables -fasynchronous-unwind-tables" ; export CFLAGS ;
 CXXFLAGS="${CXXFLAGS:--O2 -g -m64 -fmessage-length=0 -D_FORTIFY_SOURCE=2 -fstack-protector -funwind-tables -fasynchronous-unwind-tables}" ; export CXXFLAGS ;
 FFLAGS="${FFLAGS:--O2 -g -m64 -fmessage-length=0 -D_FORTIFY_SOURCE=2 -fstack-protector -funwind-tables -fasynchronous-unwind-tables -I%_fmoddir}" ; export FFLAGS ;
 LD_AS_NEEDED=1; export LD_AS_NEEDED ;
 
 
   CFLAGS="${CFLAGS:--O2 -g -m64 -fmessage-length=0 -D_FORTIFY_SOURCE=2 -fstack-protector -funwind-tables -fasynchronous-unwind-tables}" ; export CFLAGS ; 
   CXXFLAGS="${CXXFLAGS:--O2 -g -m64 -fmessage-length=0 -D_FORTIFY_SOURCE=2 -fstack-protector -funwind-tables -fasynchronous-unwind-tables}" ; export CXXFLAGS ; 
   FFLAGS="${FFLAGS:--O2 -g -m64 -fmessage-length=0 -D_FORTIFY_SOURCE=2 -fstack-protector -funwind-tables -fasynchronous-unwind-tables}" ; export FFLAGS ; 
   cmake \
         -DCMAKE_VERBOSE_MAKEFILE=ON \
         -DCMAKE_INSTALL_PREFIX:PATH=${prefix} \
         -DCMAKE_INSTALL_LIBDIR:PATH=${prefix}/lib \
         -DINCLUDE_INSTALL_DIR:PATH=${prefix}/include \
         -DLIB_INSTALL_DIR:PATH=${prefix}/lib \
         -DSYSCONF_INSTALL_DIR:PATH=${sysconfdir} \
         -DSHARE_INSTALL_PREFIX:PATH=${prefix}/share \
         -DCMAKE_SKIP_RPATH:BOOL=ON \
         -DBUILD_SHARED_LIBS:BOOL=ON .
 make -j16
 
 
 
}

do_install() {
 echo export RPM_BUILD_ROOT=${D}
 cd ${S}
 LANG=C
 export LANG
 unset DISPLAY
 rm -rf ${D}
 mkdir -p ${D}
 
 
   oe_runmake \
         DESTDIR=${D} \
         INSTALL_ROOT=${D} \
         BINDIR=${prefix}/bin \
   install  
   rm -f ${D}${infodir}/dir 
   find ${D} -regex ".*\.la$" | xargs rm -f -- 
   find ${D} -regex ".*\.a$" | xargs rm -f --
 
 
 
}

pkg_postinst_${PN}() {
    #!/bin/sh -e

    ldconfig
}

pkg_postrm_${PN}() {
    #!/bin/sh -e

    ldconfig
}

PACKAGES = "${PN}-dbg ${PN}-doc ${PN}-locale"
PACKAGES += " libmedia-thumbnail "
PACKAGES += " media-thumbnail-server "
PACKAGES += " libmedia-thumbnail-dev "
PACKAGES += " libmedia-thumbnail-test "

libmedia-thumbnail_files = ""
libmedia-thumbnail_files += "libmedia-thumbnail.manifest"
libmedia-thumbnail_files += "${prefix}/lib/libmedia-thumbnail.so"
libmedia-thumbnail_files += "${prefix}/lib/libmedia-thumbnail.so.*"
libmedia-thumbnail_files += "${prefix}/lib/libmedia-hash.so"
libmedia-thumbnail_files += "${prefix}/lib/libmedia-hash.so.1"
libmedia-thumbnail_files += "${prefix}/lib/libmedia-hash.so.1.0.0"

media-thumbnail-server_files = ""
media-thumbnail-server_files += "media-thumbnail-server.manifest"
media-thumbnail-server_files += "${prefix}/bin/media-thumbnail-server"

libmedia-thumbnail-dev_files = ""
libmedia-thumbnail-dev_files += "libmedia-thumbnail-devel.manifest"
libmedia-thumbnail-dev_files += "${prefix}/lib/pkgconfig/media-thumbnail.pc"
libmedia-thumbnail-dev_files += "${prefix}/include/media-thumbnail/*.h"

libmedia-thumbnail-test_files = ""
libmedia-thumbnail-test_files += "${prefix}/bin/test-thumb"

FILES_${PN} = "${libmedia-thumbnail_files}"
FILES_media-thumbnail-server = "${media-thumbnail-server_files}"
FILES_${PN}-dev = "${libmedia-thumbnail-dev_files}"
FILES_${PN}-test = "${libmedia-thumbnail-test_files}"

PKG_libmedia-thumbnail= "libmedia-thumbnail"
PKG_media-thumbnail-server= "media-thumbnail-server"
PKG_libmedia-thumbnail-dev= "libmedia-thumbnail-dev"
PKG_libmedia-thumbnail-test= "libmedia-thumbnail-test"

require libmedia-thumbnail-extraconf.inc
