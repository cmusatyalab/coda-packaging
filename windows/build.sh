#!/bin/bash
#
# A script for building VMNetX and its dependencies for Windows
# Based on build.sh from openslide-winbuild
#
# Copyright (c) 2011-2013 Carnegie Mellon University
# All rights reserved.
#
# This script is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License, version 2, as published
# by the Free Software Foundation.
#
# This script is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this script.  If not, see <http://www.gnu.org/licenses/>.
#

set -eE

packages="configguess zlib png jpeg iconv gettext ffi glib gdkpixbuf pixman cairo pango atk gtk celt openssl orc gstreamer gstbase gstgood spicegtk"

# Tool configuration for Cygwin
cygtools="wget zip pkg-config make mingw64-i686-gcc-g++ mingw64-x86_64-gcc-g++ binutils nasm gettext-devel libglib2.0-devel gtk-update-icon-cache libogg libogg-devel autoconf automake libtool flex bison intltool"

# Package display names.  Missing packages are not included in VERSIONS.txt.
zlib_name="zlib"
png_name="libpng"
jpeg_name="libjpeg-turbo"
iconv_name="win-iconv"
gettext_name="gettext"
ffi_name="libffi"
glib_name="glib"
gdkpixbuf_name="gdk-pixbuf"
pixman_name="pixman"
cairo_name="cairo"
pango_name="pango"
atk_name="atk"
gtk_name="gtk+"
celt_name="celt"
openssl_name="OpenSSL"
orc_name="orc"
gstreamer_name="gstreamer"
gstbase_name="gst-plugins-base"
gstgood_name="gst-plugins-good"
spicegtk_name="spice-gtk"

# Package versions
configguess_ver="28d244f1"
zlib_ver="1.2.8"
png_ver="1.6.5"
jpeg_ver="1.3.0"
iconv_ver="0.0.6"
gettext_ver="0.18.3.1"
ffi_ver="3.0.13"
glib_basever="2.36"
glib_ver="${glib_basever}.4"
gdkpixbuf_basever="2.28"
gdkpixbuf_ver="${gdkpixbuf_basever}.2"
pixman_ver="0.30.2"
cairo_ver="1.12.16"
pango_basever="1.35"
pango_ver="${pango_basever}.3"
atk_basever="2.9"
atk_ver="${atk_basever}.4"
gtk_basever="2.24"
gtk_ver="${gtk_basever}.21"
celt_ver="0.5.1.3"  # spice-gtk requires 0.5.1.x specifically
openssl_ver="1.0.1e"
orc_ver="0.4.18"
gstreamer_ver="0.10.36"  # spice-gtk requires 0.10.x
gstbase_ver="0.10.36"
gstgood_ver="0.10.31"
spicegtk_ver="0.20"

# Tarball URLs
configguess_url="http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=${configguess_ver}"
zlib_url="http://prdownloads.sourceforge.net/libpng/zlib-${zlib_ver}.tar.xz"
png_url="http://prdownloads.sourceforge.net/libpng/libpng-${png_ver}.tar.xz"
jpeg_url="http://prdownloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${jpeg_ver}.tar.gz"
iconv_url="https://win-iconv.googlecode.com/files/win-iconv-${iconv_ver}.tar.bz2"
gettext_url="http://ftp.gnu.org/pub/gnu/gettext/gettext-${gettext_ver}.tar.gz"
ffi_url="ftp://sourceware.org/pub/libffi/libffi-${ffi_ver}.tar.gz"
glib_url="http://ftp.gnome.org/pub/gnome/sources/glib/${glib_basever}/glib-${glib_ver}.tar.xz"
gdkpixbuf_url="http://ftp.gnome.org/pub/gnome/sources/gdk-pixbuf/${gdkpixbuf_basever}/gdk-pixbuf-${gdkpixbuf_ver}.tar.xz"
pixman_url="http://cairographics.org/releases/pixman-${pixman_ver}.tar.gz"
cairo_url="http://cairographics.org/releases/cairo-${cairo_ver}.tar.xz"
pango_url="http://ftp.gnome.org/pub/gnome/sources/pango/${pango_basever}/pango-${pango_ver}.tar.xz"
atk_url="http://ftp.gnome.org/pub/gnome/sources/atk/${atk_basever}/atk-${atk_ver}.tar.xz"
gtk_url="http://ftp.gnome.org/pub/gnome/sources/gtk+/${gtk_basever}/gtk+-${gtk_ver}.tar.xz"
celt_url="http://downloads.xiph.org/releases/celt/celt-${celt_ver}.tar.gz"
openssl_url="http://www.openssl.org/source/openssl-${openssl_ver}.tar.gz"
orc_url="http://code.entropywave.com/download/orc/orc-${orc_ver}.tar.gz"
gstreamer_url="http://gstreamer.freedesktop.org/src/gstreamer/gstreamer-${gstreamer_ver}.tar.xz"
gstbase_url="http://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-${gstbase_ver}.tar.xz"
gstgood_url="http://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-${gstgood_ver}.tar.xz"
spicegtk_url="http://spice-space.org/download/gtk/spice-gtk-${spicegtk_ver}.tar.bz2"

# Unpacked source trees
zlib_build="zlib-${zlib_ver}"
png_build="libpng-${png_ver}"
jpeg_build="libjpeg-turbo-${jpeg_ver}"
iconv_build="win-iconv-${iconv_ver}"
gettext_build="gettext-${gettext_ver}/gettext-runtime"
ffi_build="libffi-${ffi_ver}"
glib_build="glib-${glib_ver}"
gdkpixbuf_build="gdk-pixbuf-${gdkpixbuf_ver}"
pixman_build="pixman-${pixman_ver}"
cairo_build="cairo-${cairo_ver}"
pango_build="pango-${pango_ver}"
atk_build="atk-${atk_ver}"
gtk_build="gtk+-${gtk_ver}"
celt_build="celt-${celt_ver}"
openssl_build="openssl-${openssl_ver}"
orc_build="orc-${orc_ver}"
gstreamer_build="gstreamer-${gstreamer_ver}"
gstbase_build="gst-plugins-base-${gstbase_ver}"
gstgood_build="gst-plugins-good-${gstgood_ver}"
spicegtk_build="spice-gtk-${spicegtk_ver}"

# Locations of license files within the source tree
zlib_licenses="README"
png_licenses="png.h"  # !!!
jpeg_licenses="README README-turbo.txt"
iconv_licenses="readme.txt"
gettext_licenses="COPYING intl/COPYING.LIB"
ffi_licenses="LICENSE"
glib_licenses="COPYING"
gdkpixbuf_licenses="COPYING"
pixman_licenses="COPYING"
cairo_licenses="COPYING COPYING-LGPL-2.1 COPYING-MPL-1.1"
pango_licenses="COPYING"
atk_licenses="COPYING"
gtk_licenses="COPYING"
celt_licenses="COPYING"
openssl_licenses="LICENSE"
orc_licenses="COPYING"
gstreamer_licenses="COPYING"
gstbase_licenses="COPYING.LIB"
gstgood_licenses="COPYING"
spicegtk_licenses="COPYING"

# Build dependencies
zlib_dependencies=""
png_dependencies="zlib"
jpeg_dependencies=""
iconv_dependencies=""
gettext_dependencies="iconv"
ffi_dependencies=""
glib_dependencies="zlib iconv gettext ffi"
gdkpixbuf_dependencies="png jpeg glib"
pixman_dependencies=""
cairo_dependencies="zlib png pixman"
pango_dependencies="glib cairo"
atk_dependencies="glib"
gtk_dependencies="glib gdkpixbuf cairo pango atk"
celt_dependencies=""
openssl_dependencies=""
orc_dependencies=""
gstreamer_dependencies="glib"
gstbase_dependencies="glib gstreamer orc"
gstgood_dependencies="zlib png jpeg glib gdkpixbuf cairo gstreamer gstbase orc"
spicegtk_dependencies="zlib jpeg pixman gtk celt openssl gstreamer gstbase"

# Build artifacts
zlib_artifacts="zlib1.dll"
png_artifacts="libpng16-16.dll"
jpeg_artifacts="libjpeg-62.dll"
iconv_artifacts="iconv.dll"
gettext_artifacts="libintl-8.dll"
ffi_artifacts="libffi-6.dll"
glib_artifacts="libglib-2.0-0.dll libgthread-2.0-0.dll libgobject-2.0-0.dll libgio-2.0-0.dll libgmodule-2.0-0.dll"
gdkpixbuf_artifacts="libgdk_pixbuf-2.0-0.dll"
pixman_artifacts="libpixman-1-0.dll"
cairo_artifacts="libcairo-2.dll"
pango_artifacts="libpango-1.0-0.dll libpangocairo-1.0-0.dll libpangowin32-1.0-0.dll"
atk_artifacts="libatk-1.0-0.dll"
gtk_artifacts="libgtk-win32-2.0-0.dll libgdk-win32-2.0-0.dll"
celt_artifacts="libcelt051-0.dll"
openssl_artifacts="libeay32.dll ssleay32.dll"
orc_artifacts="liborc-0.4-0.dll liborc-test-0.4-0.dll"
gstreamer_artifacts="libgstreamer-0.10-0.dll libgstbase-0.10-0.dll lib/gstreamer-0.10/libgstcoreelements.dll lib/gstreamer-0.10/libgstcoreindexers.dll"
gstbase_artifacts="libgstinterfaces-0.10-0.dll libgstapp-0.10-0.dll libgstaudio-0.10-0.dll libgstpbutils-0.10-0.dll lib/gstreamer-0.10/libgstapp.dll lib/gstreamer-0.10/libgstaudioconvert.dll lib/gstreamer-0.10/libgstaudioresample.dll"
gstgood_artifacts="lib/gstreamer-0.10/libgstautodetect.dll lib/gstreamer-0.10/libgstdirectsoundsink.dll"
spicegtk_artifacts="libspice-client-gtk-2.0-4.dll libspice-client-glib-2.0-8.dll spicy.exe"


expand() {
    # Print the contents of the named variable
    # $1  = the name of the variable to expand
    echo "${!1}"
}

tarpath() {
    # Print the tarball path for the specified package
    # $1  = the name of the program
    if [ "$1" = "configguess" ] ; then
        # Can't be derived from URL
        echo "tar/config.guess"
    else
        echo "tar/$(basename $(expand ${1}_url))"
    fi
}

setup_cygwin() {
    # Install necessary tools for Cygwin builds.
    # $1  = path to Cygwin setup.exe

    # Install cygwin packages
    # Avoid UAC setup.exe magic
    cp "$1" cygwin.exe
    ./cygwin.exe -q -P "${cygtools// /,}" >/dev/null
    rm cygwin.exe
}

fetch() {
    # Fetch the specified package
    # $1  = package shortname
    local url
    url="$(expand ${1}_url)"
    mkdir -p tar
    if [ ! -e "$(tarpath $1)" ] ; then
        echo "Fetching ${1}..."
        if [ "$1" = "configguess" ] ; then
            # config.guess is special; we have to rename the saved file
            wget -q -O tar/config.guess "$url"
        else
            wget -P tar -q --no-check-certificate "$url"
        fi
    fi
}

unpack() {
    # Remove the package build directory and re-unpack it
    # $1  = package shortname
    local path
    fetch "${1}"
    mkdir -p "${build}"
    path="${build}/$(expand ${1}_build)"
    if [ -e "override/${1}" ] ; then
        echo "Unpacking ${1} from override directory..."
        rm -rf "${path}"
        cp -r "override/${1}" "${path}"
    else
        echo "Unpacking ${1}..."
        rm -rf "${path}"
        tar xf "$(tarpath $1)" -C "${build}"
    fi
}

is_built() {
    # Return true if the specified package is already built
    # $1  = package shortname
    local file
    for file in $(expand ${1}_artifacts)
    do
        if [ ! -e "${root}/bin/${file}" ] ; then
            return 1
        fi
    done
    return 0
}

do_configure() {
    # Run configure with the appropriate parameters.
    # Additional parameters can be specified as arguments.
    #
    # Fedora's ${build_host}-pkg-config clobbers search paths; avoid it
    #
    # Use only our pkg-config library directory, even on cross builds
    # https://bugzilla.redhat.com/show_bug.cgi?id=688171
    #
    # -static-libgcc is in ${ldflags} but libtool filters it out, so we
    # also pass it in CC
    ./configure \
            --host=${build_host} \
            --build=${build_system} \
            --prefix="$root" \
            --disable-static \
            --disable-dependency-tracking \
            PKG_CONFIG=pkg-config \
            PKG_CONFIG_LIBDIR="${root}/lib/pkgconfig" \
            PKG_CONFIG_PATH= \
            CC="${build_host}-gcc -static-libgcc" \
            CPPFLAGS="${cppflags} -I${root}/include" \
            CFLAGS="${cflags}" \
            CXXFLAGS="${cxxflags}" \
            LDFLAGS="${ldflags} -L${root}/lib" \
            "$@"
}

build_one() {
    # Build the specified package and its dependencies if not already built
    # $1  = package shortname
    local builddir artifact

    if is_built "$1" ; then
        return
    fi

    build $(expand ${1}_dependencies)

    unpack "$1"

    echo "Building ${1}..."
    builddir="${build}/$(expand ${1}_build)"
    pushd "$builddir" >/dev/null
    case "$1" in
    zlib)
        make -f win32/Makefile.gcc $parallel \
                PREFIX="${build_host}-" \
                CFLAGS="${cppflags} ${cflags}" \
                LDFLAGS="${ldflags}" \
                all
        make -f win32/Makefile.gcc \
                SHARED_MODE=1 \
                PREFIX="${build_host}-" \
                BINARY_PATH="${root}/bin" \
                INCLUDE_PATH="${root}/include" \
                LIBRARY_PATH="${root}/lib" install
        ;;
    png)
        do_configure
        make $parallel
        make install
        ;;
    jpeg)
        do_configure
        make $parallel
        make install
        ;;
    iconv)
        make \
                CC="${build_host}-gcc" \
                AR="${build_host}-ar" \
                RANLIB="${build_host}-ranlib" \
                DLLTOOL="${build_host}-dlltool" \
                CFLAGS="${cppflags} ${cflags}" \
                SPECS_FLAGS="${ldflags} -static-libgcc"
        make install \
                prefix="${root}"
        ;;
    gettext)
        # Missing tests for C++ compiler, which is only needed on Windows
        do_configure \
                CXX=${build_host}-g++ \
                --disable-java \
                --disable-native-java \
                --disable-csharp \
                --disable-libasprintf \
                --enable-threads=win32
        make $parallel
        make install
        ;;
    ffi)
        do_configure
        make $parallel
        make install
        ;;
    glib)
        # gtk-doc.make has a bogus timestamp, causing an attempt to
        # regenerate docs/reference/glib/Makefile.in
        touch -r configure gtk-doc.make
        do_configure \
                --disable-modular-tests \
                --with-threads=win32
        make $parallel
        make install
        ;;
    gdkpixbuf)
        do_configure \
                --disable-modules \
                --with-included-loaders
        make $parallel
        make install
        ;;
    pixman)
        do_configure
        make $parallel
        make install
        ;;
    cairo)
        do_configure \
                --enable-ft=no \
                --enable-xlib=no
        make $parallel
        make install
        ;;
    pango)
        do_configure \
                --with-included-modules
        make $parallel
        make install
        ;;
    atk)
        do_configure
        make $parallel
        make install
        ;;
    gtk)
        # http://pkgs.fedoraproject.org/cgit/mingw-gtk3.git/commit/?id=82ccf489f4763e375805d848351ac3f8fda8e88b
        sed -i 's/#define INITGUID//' gdk/win32/gdkdnd-win32.c
        # Use gdk-pixbuf-csource we just built; the one from Cygwin can't
        # read PNG
        PATH="${root}/bin:${PATH}" \
                do_configure
        make $parallel
        make install
        ;;
    celt)
        # libtool needs -no-undefined to build shared libraries on Windows
        sed -i "s/-version-info/-no-undefined -version-info/" \
                libcelt/Makefile.am
        # Don't compile test cases, since they don't build
        sed -i 's/noinst_PROGRAMS/EXTRA_PROGRAMS/' tests/Makefile.am
        autoreconf -i
        do_configure
        make $parallel
        make install
        ;;
    openssl)
        local os
        if [ "${build_bits}" = 64 ] ; then
            os=mingw64
        else
            os=mingw
        fi
        ./Configure \
                "${os}" \
                --prefix="$root" \
                --cross-compile-prefix="${build_host}-" \
                shared \
                no-zlib \
                no-hw \
                ${cppflags} \
                ${cflags} \
                ${ldflags}
        make
        make install_sw
        ;;
    orc)
        do_configure
        make $parallel
        make install
        ;;
    gstreamer)
        # Disable registry cache file
        sed -i \
                -e 's/disable_registry_cache = FALSE/disable_registry_cache = TRUE/' \
                -e 's/!write_changes/FALSE/' \
                gst/gstregistry.c
        # gstreamer confuses POSIX timers with the availability of
        # clock_gettime()
        do_configure \
                --disable-loadsave \
                gst_cv_posix_timers=no
        make $parallel
        make install
        mkdir -p "${root}/bin/lib/gstreamer-0.10"
        local artifact
        for artifact in ${gstreamer_artifacts}
        do
            if [ "${artifact#lib/}" != "${artifact}" ] ; then
                cp -a "${root}/${artifact}" "${root}/bin/${artifact}"
            fi
        done
        ;;
    gstbase)
        do_configure \
                --disable-vorbis \
                --disable-examples
        make $parallel
        make install
        mkdir -p "${root}/bin/lib/gstreamer-0.10"
        local artifact
        for artifact in ${gstbase_artifacts}
        do
            if [ "${artifact#lib/}" != "${artifact}" ] ; then
                cp -a "${root}/${artifact}" "${root}/bin/${artifact}"
            fi
        done
        ;;
    gstgood)
        do_configure \
                --disable-examples
        make $parallel
        make install
        mkdir -p "${root}/bin/lib/gstreamer-0.10"
        local artifact
        for artifact in ${gstgood_artifacts}
        do
            if [ "${artifact#lib/}" != "${artifact}" ] ; then
                cp -a "${root}/${artifact}" "${root}/bin/${artifact}"
            fi
        done
        ;;
    spicegtk)
        # Work around boolean typedef conflict
        sed -i 's/#include <jpeglib.h>/typedef int spice_jpeg_boolean;\n#define boolean spice_jpeg_boolean\n#include <jpeglib.h>/' gtk/decode-jpeg.c
        do_configure \
                --with-sasl=no \
                --with-gtk=2.0 \
                --with-audio=gstreamer \
                --with-python=no \
                --enable-smartcard=no
        make $parallel
        make install
        ;;
    esac
    popd >/dev/null
}

build() {
    # Build the specified list of packages and their dependencies if not
    # already built
    # $*  = package shortnames
    local package
    for package in $*
    do
        build_one "$package"
    done
}

sdist() {
    # Build source distribution
    local package path xzpath zipdir
    zipdir="vmnetx-winbuild-$(date +%Y%m%d)"
    rm -rf "${zipdir}"
    mkdir -p "${zipdir}/tar"
    for package in $packages
    do
        fetch "$package"
        cp "$(tarpath ${package})" "${zipdir}/tar/"
    done
    cp build.sh README.md lgpl-2.1.txt "${zipdir}/"
    rm -f "${zipdir}.zip"
    zip -r "${zipdir}.zip" "${zipdir}"
    rm -r "${zipdir}"
}

bdist() {
    # Build binary distribution
    local package name licensedir zipdir artifact_parent
    for package in $packages
    do
        build_one "$package"
    done
    zipdir="vmnetx-win${build_bits}-$(date +%Y%m%d)"
    rm -rf "${zipdir}"
    # Don't use "bin", since it's special-cased by
    # g_win32_get_package_installation_directory_of_module()
    mkdir -p "${zipdir}/app"
    for package in $packages
    do
        for artifact in $(expand ${package}_artifacts)
        do
            artifact_parent=$(dirname "${artifact}")
            if [ "${artifact_parent}" != "." ] ; then
                mkdir -p "${zipdir}/app/${artifact_parent}"
            fi
            cp "${root}/bin/${artifact}" "${zipdir}/app/${artifact}"
        done
        licensedir="${zipdir}/licenses/$(expand ${package}_name)"
        mkdir -p "${licensedir}"
        for artifact in $(expand ${package}_licenses)
        do
            cp "${build}/$(expand ${package}_build)/${artifact}" \
                    "${licensedir}"
        done
        name="$(expand ${package}_name)"
        if [ -n "$name" ] ; then
            printf "%-30s %s\n" "$name" "$(expand ${package}_ver)" >> \
                    "${zipdir}/VERSIONS.txt"
        fi
    done
    rm -f "${zipdir}.zip"
    zip -r "${zipdir}.zip" "${zipdir}"
    rm -r "${zipdir}"
}

clean() {
    # Clean built files
    local package artifact
    if [ $# -gt 0 ] ; then
        for package in "$@"
        do
            echo "Cleaning ${package}..."
            for artifact in $(expand ${package}_artifacts)
            do
                rm -f "${root}/bin/${artifact}"
            done
        done
    else
        echo "Cleaning..."
        rm -rf 32 64 vmnetx-win*-*.zip
    fi
}

probe() {
    # Probe the build environment and set up variables
    build="${build_bits}/build"
    root="$(pwd)/${build_bits}/root"
    mkdir -p "${root}"

    fetch configguess
    build_system=$(sh tar/config.guess)

    if [ "$build_bits" = "64" ] ; then
        build_host=x86_64-w64-mingw32
    else
        build_host=i686-w64-mingw32
    fi
    if ! type ${build_host}-gcc >/dev/null 2>&1 ; then
        echo "Couldn't find suitable compiler."
        exit 1
    fi

    cppflags="-D_FORTIFY_SOURCE=2"
    cflags="-O2 -g -mms-bitfields -fexceptions"
    cxxflags="${cflags}"
    ldflags="-static-libgcc -Wl,--enable-auto-image-base -Wl,--dynamicbase -Wl,--nxcompat"
}

fail_handler() {
    # Report failed command
    echo "Failed: $BASH_COMMAND (line $BASH_LINENO)"
    exit 1
}


# Set up error handling
trap fail_handler ERR

# Cygwin setup bypasses normal startup
if [ "$1" = "setup" ] ; then
    setup_cygwin "$2"
    exit 0
fi

# Parse command-line options
parallel=""
build_bits=32
while getopts "j:m:" opt
do
    case "$opt" in
    j)
        parallel="-j${OPTARG}"
        ;;
    m)
        case ${OPTARG} in
        32|64)
            build_bits=${OPTARG}
            ;;
        *)
            echo "-m32 or -m64 only."
            exit 1
            ;;
        esac
        ;;
    esac
done
shift $(( $OPTIND - 1 ))

# Probe build environment
probe

# Process command-line arguments
case "$1" in
sdist)
    sdist
    ;;
bdist)
    bdist
    ;;
clean)
    shift
    clean "$@"
    ;;
*)
    cat <<EOF
Usage: $0 setup /path/to/cygwin/setup.exe
       $0 sdist
       $0 [-j<n>] [-m{32|64}] bdist
       $0 [-m{32|64}] clean [package...]

Packages:
$packages
EOF
    exit 1
    ;;
esac
exit 0
