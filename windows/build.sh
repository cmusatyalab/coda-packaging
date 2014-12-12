#!/bin/bash
#
# A script for building VMNetX and its dependencies for Windows
# Based on build.sh from openslide-winbuild
#
# Copyright (c) 2011-2014 Carnegie Mellon University
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

packages="configguess zlib png jpeg iconv gettext ffi glib gdkpixbuf pixman cairo pango atk icontheme gtk pycairo pygobject pygtk celt openssl xml xslt sqlite soup orc gstreamer gstbase gstgood spicegtk msgpack lxml six dateutil requests comtypes vmnetx"

# Cygwin non-default packages
cygtools="wget zip unzip pkg-config make mingw64-i686-gcc-g++ mingw64-x86_64-gcc-g++ binutils nasm gettext-devel libglib2.0-devel gtk-update-icon-cache libogg-devel autoconf automake libtool flex bison intltool util-linux"
# Other tools
wintools="python setuptools pywin32 pyinstaller wix"
# Python installer
python_ver="2.7.8"
python_url="http://www.python.org/ftp/python/${python_ver}/python-${python_ver}.msi"
python_upurl="http://www.python.org/ftp/python/"
python_upregex=">(2\.7\.[0-9]+)/<"
# setuptools
setuptools_url="https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py"
# pywin32 (installed from binary, because a source build requires MSVC)
pywin32_ver=219
pywin32_url="http://prdownloads.sourceforge.net/pywin32/pywin32-${pywin32_ver}.win32-py2.7.exe"
pywin32_upurl="http://sourceforge.net/projects/pywin32/files/pywin32/"
pywin32_upregex="Build ?([0-9]+)"
# pyinstaller
pyinstaller_ver="2.1"
pyinstaller_upurl="http://www.pyinstaller.org/"
pyinstaller_upregex="latest stable release of PyInstaller is ([0-9.]+)"
# WiX
wix_ver="3.8"
wix_url="http://wix.codeplex.com/releases/view/115492"
wix_upurl="http://wix.codeplex.com/"
wix_upregex="WiX Toolset v([0-9.]+)"

# Package display names
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
icontheme_name="adwaita-icon-theme"
gtk_name="gtk+"
pycairo_name="py2cairo"
pygobject_name="PyGObject"
pygtk_name="PyGTK"
celt_name="celt"
openssl_name="OpenSSL"
xml_name="libxml2"
xslt_name="libxslt"
sqlite_name="SQLite"
soup_name="libsoup"
orc_name="orc"
gstreamer_name="gstreamer"
gstbase_name="gst-plugins-base"
gstgood_name="gst-plugins-good"
spicegtk_name="spice-gtk"
msgpack_name="msgpack-python"
lxml_name="lxml"
six_name="six"
dateutil_name="python-dateutil"
requests_name="requests"
comtypes_name="comtypes"
vmnetx_name="VMNetX"

# Package versions
configguess_ver="28d244f1"
zlib_ver="1.2.8"
png_ver="1.6.12"
jpeg_ver="1.3.1"
iconv_ver="0.0.6"
gettext_ver="0.19.3"
ffi_ver="3.1"
glib_basever="2.42"
glib_ver="${glib_basever}.0"
gdkpixbuf_basever="2.31"
gdkpixbuf_ver="${gdkpixbuf_basever}.1"
pixman_ver="0.32.6"
cairo_ver="1.14.0"
pango_basever="1.36"
pango_ver="${pango_basever}.8"
atk_basever="2.14"
atk_ver="${atk_basever}.0"
icontheme_basever="3.14"
icontheme_ver="${icontheme_basever}.0"
gtk_basever="2.24"
gtk_ver="${gtk_basever}.25"
pycairo_ver="1.10.0"
pygobject_basever="2.28"
pygobject_ver="${pygobject_basever}.6"
pygtk_basever="2.24"
pygtk_ver="${pygtk_basever}.0"
celt_ver="0.5.1.3"  # spice-gtk requires 0.5.1.x specifically
openssl_ver="1.0.1j"
xml_ver="2.9.2"
xslt_ver="1.1.28"
sqlite_year="2014"
sqlite_ver="3.8.7"
sqlite_vernum="3080700"
soup_basever="2.48"
soup_ver="${soup_basever}.0"
orc_ver="0.4.18"
gstreamer_ver="0.10.36"  # spice-gtk requires 0.10.x
gstbase_ver="0.10.36"
gstgood_ver="0.10.31"
spicegtk_ver="0.25"
msgpack_ver="0.4.2"
lxml_ver="3.4.0"
six_ver="1.8.0"
dateutil_ver="2.2"
requests_ver="2.4.3"
comtypes_ver="1.1.1"
vmnetx_ver="0.5.0"

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
icontheme_url="http://ftp.gnome.org/pub/gnome/sources/adwaita-icon-theme/${icontheme_basever}/adwaita-icon-theme-${icontheme_ver}.tar.xz"
gtk_url="http://ftp.gnome.org/pub/gnome/sources/gtk+/${gtk_basever}/gtk+-${gtk_ver}.tar.xz"
pycairo_url="http://cairographics.org/releases/py2cairo-${pycairo_ver}.tar.bz2"
pygobject_url="http://ftp.gnome.org/pub/GNOME/sources/pygobject/${pygobject_basever}/pygobject-${pygobject_ver}.tar.xz"
pygtk_url="http://ftp.gnome.org/pub/GNOME/sources/pygtk/${pygtk_basever}/pygtk-${pygtk_ver}.tar.bz2"
celt_url="http://downloads.xiph.org/releases/celt/celt-${celt_ver}.tar.gz"
openssl_url="http://www.openssl.org/source/openssl-${openssl_ver}.tar.gz"
xml_url="ftp://xmlsoft.org/libxml2/libxml2-${xml_ver}.tar.gz"
xslt_url="ftp://xmlsoft.org/libxslt/libxslt-${xslt_ver}.tar.gz"
sqlite_url="http://www.sqlite.org/${sqlite_year}/sqlite-autoconf-${sqlite_vernum}.tar.gz"
soup_url="http://ftp.gnome.org/pub/gnome/sources/libsoup/${soup_basever}/libsoup-${soup_ver}.tar.xz"
orc_url="http://code.entropywave.com/download/orc/orc-${orc_ver}.tar.gz"
gstreamer_url="http://gstreamer.freedesktop.org/src/gstreamer/gstreamer-${gstreamer_ver}.tar.xz"
gstbase_url="http://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-${gstbase_ver}.tar.xz"
gstgood_url="http://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-${gstgood_ver}.tar.xz"
spicegtk_url="http://www.spice-space.org/download/gtk/spice-gtk-${spicegtk_ver}.tar.bz2"
msgpack_url="https://pypi.python.org/packages/source/m/msgpack-python/msgpack-python-${msgpack_ver}.tar.gz"
lxml_url="https://pypi.python.org/packages/source/l/lxml/lxml-${lxml_ver}.tar.gz"
six_url="https://pypi.python.org/packages/source/s/six/six-${six_ver}.tar.gz"
dateutil_url="https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-${dateutil_ver}.tar.gz"
requests_url="https://pypi.python.org/packages/source/r/requests/requests-${requests_ver}.tar.gz"
comtypes_url="https://pypi.python.org/packages/source/c/comtypes/comtypes-${comtypes_ver}.zip"
vmnetx_url="https://olivearchive.org/vmnetx/source/vmnetx-${vmnetx_ver}.tar.xz"
vmnetx_update_check_url="https://olivearchive.org/vmnetx/windows/latest.json"

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
icontheme_build="adwaita-icon-theme-${icontheme_ver}"
gtk_build="gtk+-${gtk_ver}"
pycairo_build="py2cairo-${pycairo_ver}"
pygobject_build="pygobject-${pygobject_ver}"
pygtk_build="pygtk-${pygtk_ver}"
celt_build="celt-${celt_ver}"
openssl_build="openssl-${openssl_ver}"
xml_build="libxml2-${xml_ver}"
xslt_build="libxslt-${xslt_ver}"
orc_build="orc-${orc_ver}"
sqlite_build="sqlite-autoconf-${sqlite_vernum}"
soup_build="libsoup-${soup_ver}"
gstreamer_build="gstreamer-${gstreamer_ver}"
gstbase_build="gst-plugins-base-${gstbase_ver}"
gstgood_build="gst-plugins-good-${gstgood_ver}"
spicegtk_build="spice-gtk-${spicegtk_ver}"
msgpack_build="msgpack-python-${msgpack_ver}"
lxml_build="lxml-${lxml_ver}"
six_build="six-${six_ver}"
dateutil_build="python-dateutil-${dateutil_ver}"
requests_build="requests-${requests_ver}"
comtypes_build="comtypes-${comtypes_ver}"
vmnetx_build="vmnetx-${vmnetx_ver}"

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
icontheme_licenses="COPYING COPYING_CCBYSA3 COPYING_LGPL"
gtk_licenses="COPYING"
pycairo_licenses="COPYING COPYING-LGPL-2.1 COPYING-MPL-1.1"
pygobject_licenses="COPYING"
pygtk_licenses="COPYING"
celt_licenses="COPYING"
openssl_licenses="LICENSE"
xml_licenses="COPYING"
xslt_licenses="COPYING"
sqlite_licenses="PUBLIC-DOMAIN.txt"
soup_licenses="COPYING"
orc_licenses="COPYING"
gstreamer_licenses="COPYING"
gstbase_licenses="COPYING.LIB"
gstgood_licenses="COPYING"
spicegtk_licenses="COPYING"
msgpack_licenses="COPYING"
lxml_licenses="LICENSES.txt doc/licenses/BSD.txt doc/licenses/elementtree.txt doc/licenses/GPL.txt"
six_licenses="LICENSE"
dateutil_licenses="LICENSE"
requests_licenses="LICENSE NOTICE"
comtypes_licenses="setup.py"  # LICENSE.txt is not distributed
vmnetx_licenses="COPYING desktop/README.icon"

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
icontheme_dependencies=""
gtk_dependencies="glib gdkpixbuf cairo pango atk icontheme"
pycairo_dependencies="cairo"
pygobject_dependencies="glib"
pygtk_dependencies="pango atk gtk pycairo pygobject"
celt_dependencies=""
openssl_dependencies=""
xml_dependencies="zlib iconv"
xslt_dependencies="xml"
sqlite_dependencies=""
soup_dependencies="glib xml sqlite"
orc_dependencies=""
gstreamer_dependencies="glib xml"
gstbase_dependencies="glib gstreamer orc"
gstgood_dependencies="zlib png jpeg glib gdkpixbuf cairo gstreamer gstbase orc"
spicegtk_dependencies="zlib jpeg pixman gtk pygtk celt openssl soup gstreamer gstbase"
msgpack_dependencies=""
lxml_dependencies="xml xslt"
six_dependencies=""
dateutil_dependencies="six"
requests_dependencies=""
comtypes_dependencies=""
vmnetx_dependencies="pygobject pygtk spicegtk msgpack lxml dateutil requests comtypes"

# Installed file that proves the package has been built
zlib_stamp="app/zlib1.dll"
png_stamp="app/libpng16-16.dll"
jpeg_stamp="app/libjpeg-62.dll"
iconv_stamp="app/iconv.dll"
gettext_stamp="app/libintl-8.dll"
ffi_stamp="app/libffi-6.dll"
glib_stamp="app/libglib-2.0-0.dll"
gdkpixbuf_stamp="app/libgdk_pixbuf-2.0-0.dll"
pixman_stamp="app/libpixman-1-0.dll"
cairo_stamp="app/libcairo-2.dll"
pango_stamp="app/libpango-1.0-0.dll"
atk_stamp="app/libatk-1.0-0.dll"
icontheme_stamp="share/icons/Adwaita/index.theme"
gtk_stamp="app/libgtk-win32-2.0-0.dll"
pycairo_stamp="lib/python/cairo/_cairo.pyd"
pygobject_stamp="lib/python/gobject/_gobject.pyd"
pygtk_stamp="lib/python/gtk-2.0/gtk/_gtk.pyd"
celt_stamp="app/libcelt051-0.dll"
openssl_stamp="app/ssleay32.dll"
xml_stamp="app/libxml2-2.dll"
xslt_stamp="app/libxslt-1.dll"
sqlite_stamp="app/libsqlite3-0.dll"
soup_stamp="app/libsoup-2.4-1.dll"
orc_stamp="app/liborc-0.4-0.dll"
gstreamer_stamp="app/libgstreamer-0.10-0.dll"
gstbase_stamp="app/libgstapp-0.10-0.dll"
gstgood_stamp="lib/gstreamer-0.10/libgstautodetect.dll"
spicegtk_stamp="lib/python/SpiceClientGtk.pyd"
msgpack_stamp="lib/python/msgpack/_packer.pyd"
lxml_stamp="lib/python/lxml/etree.pyd"
six_stamp="lib/python/six.py"
dateutil_stamp="lib/python/dateutil/tz.py"
requests_stamp="lib/python/requests/sessions.py"
comtypes_stamp="lib/python/comtypes/client/__init__.py"
vmnetx_stamp="app/vmnetx"

# Update-checking URLs
zlib_upurl="http://zlib.net/"
png_upurl="http://www.libpng.org/pub/png/libpng-manual.txt"
jpeg_upurl="http://sourceforge.net/projects/libjpeg-turbo/files/"
iconv_upurl="http://win-iconv.googlecode.com/svn/tags/"
gettext_upurl="http://ftp.gnu.org/pub/gnu/gettext/"
ffi_upurl="ftp://sourceware.org/pub/libffi/"
glib_upurl="https://git.gnome.org/browse/glib/refs/"
gdkpixbuf_upurl="https://git.gnome.org/browse/gdk-pixbuf/refs/"
pixman_upurl="http://cairographics.org/releases/"
cairo_upurl="http://cairographics.org/releases/"
pango_upurl="https://git.gnome.org/browse/pango/refs/"
# ATK still uses old-style tag names
atk_upurl="https://git.gnome.org/browse/atk/tree/NEWS"
icontheme_upurl="https://git.gnome.org/browse/adwaita-icon-theme/refs/"
# Require 2.x
gtk_upurl="http://ftp.gnome.org/pub/gnome/sources/gtk+/${gtk_basever}/"
pycairo_upurl="http://cairographics.org/releases/"
# Require 2.x
pygobject_upurl="http://ftp.gnome.org/pub/gnome/sources/pygobject/${pygobject_basever}/"
# Require 2.x
pygtk_upurl="http://ftp.gnome.org/pub/gnome/sources/pygtk/${pygtk_basever}/"
celt_upurl="http://downloads.xiph.org/releases/celt/"
openssl_upurl="http://www.openssl.org/source/"
xml_upurl="ftp://xmlsoft.org/libxml2/"
xslt_upurl="ftp://xmlsoft.org/libxml2/"
sqlite_upurl="http://sqlite.org/download.html"
soup_upurl="https://git.gnome.org/browse/libsoup/refs/"
orc_upurl="http://code.entropywave.com/download/orc/"
gstreamer_upurl="http://gstreamer.freedesktop.org/src/gstreamer/"
gstbase_upurl="http://gstreamer.freedesktop.org/src/gst-plugins-base/"
gstgood_upurl="http://gstreamer.freedesktop.org/src/gst-plugins-good/"
spicegtk_upurl="http://www.spice-space.org/download/gtk/"
msgpack_upurl="https://pypi.python.org/packages/source/m/msgpack-python/"
lxml_upurl="https://pypi.python.org/packages/source/l/lxml/"
six_upurl="https://pypi.python.org/packages/source/s/six/"
dateutil_upurl="https://pypi.python.org/packages/source/p/python-dateutil/"
requests_upurl="https://pypi.python.org/packages/source/r/requests/"
comtypes_upurl="https://pypi.python.org/packages/source/c/comtypes/"
vmnetx_upurl="https://olivearchive.org/vmnetx/source/"

# Update-checking regexes
zlib_upregex="source code, version ([0-9.]+)"
png_upregex="libpng version ([0-9.]+) -"
jpeg_upregex="files/([0-9.]+)/"
iconv_upregex=">([0-9.]+)/<"
gettext_upregex="gettext-([0-9.]+)\.tar"
ffi_upregex="libffi-([0-9.]+)\.tar"
glib_upregex="snapshot/glib-([0-9]+\.[0-9]*[02468]\.[0-9]+)\.tar"
# Exclude 2.90.x
gdkpixbuf_upregex="snapshot/gdk-pixbuf-2\.90.*|.*snapshot/gdk-pixbuf-([0-9.]+)\.tar"
pixman_upregex="pixman-([0-9.]+)\.tar"
cairo_upregex="cairo-([0-9.]+)\.tar"
pango_upregex="snapshot/pango-([0-9]+\.[0-9]*[02468]\.[0-9]+)\.tar"
atk_upregex="Changes in version ([0-9.]+):"
icontheme_upregex="snapshot/adwaita-icon-theme-([0-9]+\.[0-9]*[02468]\.[0-9]+)\.tar"
gtk_upregex="gtk\+-([0-9.]+)\.tar"
pycairo_upregex="pycairo-([0-9.]+)\.tar"
pygobject_upregex="pygobject-([0-9.]+)\.tar"
pygtk_upregex="pygtk-([0-9.]+)\.tar"
# Require 0.5.1.x
celt_upregex="celt-(0\.5\.1\.[0-9]+)\.tar"
openssl_upregex="openssl-([0-9.]+[a-z]?)\.tar"
xml_upregex="libxml2-([0-9.]+)\.tar"
xslt_upregex="libxslt-([0-9.]+)\.tar"
sqlite_upregex="SQLite ([0-9.]+)"
soup_upregex="snapshot/libsoup-([0-9]+\.[0-9]*[02468]\.[0-9]+)\.tar"
orc_upregex="orc-([0-9.]+)\.tar"
# Require 0.10.x
gstreamer_upregex="gstreamer-(0\.10\.[0-9]+)\.tar"
# Require 0.10.x
gstbase_upregex="gst-plugins-base-(0\.10\.[0-9]+)\.tar"
# Require 0.10.x
gstgood_upregex="gst-plugins-good-(0\.10\.[0-9]+)\.tar"
spicegtk_upregex="spice-gtk-([0-9.]+)\.tar"
msgpack_upregex="msgpack-python-([0-9.]+)\.tar"
lxml_upregex="lxml-([0-9.]+)\.tar"
six_upregex="six-([0-9.]+)\.tar"
dateutil_upregex="python-dateutil-([0-9.]+)\.tar"
requests_upregex="requests-([0-9.]+)\.tar"
comtypes_upregex="comtypes-([0-9.]+)\.zip"
vmnetx_upregex="vmnetx-([0-9.]+)\.tar"

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

wintool_current() {
    # Return true if the specified tool is installed and the correct version,
    # false otherwise.
    # $1  = package from $wintools

    case "$1" in
    python)
        local python curver
        python=$(cygpath "c:\Python27\pythonw.exe")
        if [ ! -e "${python}" ] ; then
            return 1
        fi
        curver=$(${python} -c \
                "import platform; print platform.python_version()" | \
                tr -d '\r')
        [ "${curver}" = "${python_ver}" ]
        return
        ;;
    setuptools)
        # We don't check the setuptools version, since setuptools isn't
        # embedded into the release package
        [ -e $(cygpath "c:\Python27\Scripts\easy_install.exe") ]
        return
        ;;
    pywin32)
        local verfile
        verfile=$(cygpath "c:\Python27\Lib\site-packages\pywin32.version.txt")
        if [ ! -e "${verfile}" ] ; then
            return 1
        fi
        [ "$(cat ${verfile} | tr -d '\r')" = "${pywin32_ver}" ]
        return
        ;;
    pyinstaller)
        [ -e $(cygpath "c:\Python27\Lib\site-packages\PyInstaller-${pyinstaller_ver}-py2.7.egg") ]
        return
        ;;
    wix)
        local wixdir
        wixdir=$(cygpath "c:\Program Files\WiX Toolset v${wix_ver}\bin")
        [ -e "${wixdir}/candle.exe" ]
        return
        ;;
    *)
        echo "Unrecognized tool $1"
        return 1
        ;;
    esac
}

setup_environment() {
    # Install necessary tools into environment.
    # $1  = path to Cygwin setup.exe

    # Install cygwin packages
    "$1" -q -P "${cygtools// /,}" >/dev/null

    # Wait for cygwin setup to install wget
    while [ ! -x /usr/bin/wget ] ; do
    	sleep 1
    done

    # Install native Python
    if ! wintool_current python; then
        fetch python
        msiexec /passive /i $(cygpath -w "$(tarpath python)")
    fi
    local python
    python="cygstart -w c:\Python27\python.exe"

    # Install setuptools
    if ! wintool_current setuptools; then
        fetch setuptools
        ${python} $(cygpath -w "$(tarpath setuptools)")
    fi
    local easyinstall
    easyinstall="cygstart -w c:\Python27\Scripts\easy_install.exe"

    # Install pywin32.  Sadly, the bdist_wininst installer doesn't support
    # noninteractive installation.
    if ! wintool_current pywin32; then
        fetch pywin32
        chmod +x "$(tarpath pywin32)"
        cygstart -w "$(tarpath pywin32)"
    fi

    # Install PyInstaller
    if ! wintool_current pyinstaller; then
        ${easyinstall} "PyInstaller==${pyinstaller_ver}"
    fi

    # Prompt to install WiX.  We can't install it ourselves because CodePlex
    # doesn't permit direct downloads.
    if ! wintool_current wix; then
        cygstart "${wix_url}"
    fi
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
    local path tarpath
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
        tarpath="$(tarpath $1)"
        if [ "${tarpath%.zip}" != "${tarpath}" ] ; then
            unzip -q -d "${build}" "${tarpath}"
        else
            tar xf "${tarpath}" -C "${build}"
        fi
    fi
}

is_built() {
    # Return true if the specified package is already built
    # $1  = package shortname
    if [ -e "${root}/$(expand ${1}_stamp)" ] ; then
        return 0
    fi
    return 1
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
    #
    # Don't call bindir "bin", since that name is special-cased by
    # g_win32_get_package_installation_directory_of_module()
    ./configure \
            --host=${build_host} \
            --build=${build_system} \
            --prefix="$root" \
            --bindir="${root}/app" \
            --disable-static \
            --disable-dependency-tracking \
            PKG_CONFIG=pkg-config \
            PKG_CONFIG_LIBDIR="${root}/lib/pkgconfig" \
            PKG_CONFIG_PATH= \
            CC="${build_host}-gcc -static-libgcc" \
            CPPFLAGS="${cppflags} -I${root}/include -I${pythondir}/include" \
            CFLAGS="${cflags}" \
            CXXFLAGS="${cxxflags}" \
            LDFLAGS="${ldflags} -L${root}/lib -L${pythondir}/libs" \
            PYTHON="${python}" \
            am_cv_python_pythondir="${root}/lib/python" \
            am_cv_python_pyexecdir="${root}/lib/python" \
            "$@"
}

setup_py() {
    # Run setup.py build and install with the appropriate parameters.
    # Additional parameters can be specified as arguments.
    local setuptools_args

    # --compiler=mingw32 won't allow us to override the compiler executable
    # for cross-compiling, so place a Windows symlink in ${root}/compilers
    # and put ${root}/compilers into the PATH.
    mkdir -p "${root}/compilers"
    if [ ! -e "${root}/compilers/gcc.exe" ] ; then
        cygstart --action=runas cmd /c mklink \
                $(cygpath -w "${root}/compilers/gcc.exe") \
                $(cygpath -w "/usr/bin/${build_host}-gcc.exe") >/dev/null
    fi
    if [ ! -e "${root}/compilers/g++.exe" ] ; then
        cygstart --action=runas cmd /c mklink \
                $(cygpath -w "${root}/compilers/g++.exe") \
                $(cygpath -w "/usr/bin/${build_host}-g++.exe") >/dev/null
    fi
    PATH="$(cygpath -w ${root}/compilers):${PATH}" \
            PYTHONPATH="$(cygpath -w ${root}/lib/python)" \
            "${python}" setup.py build \
            --compiler=mingw32 \
            "$@"
    # If the package uses setuptools, disable egg installation
    if grep -q setuptools setup.py ; then
        setuptools_args="--single-version-externally-managed --record=nul"
    fi
    PYTHONPATH="$(cygpath -w ${root}/lib/python)" \
            "${python}" setup.py install \
            --prefix="$(cygpath -w ${root})" \
            --install-lib="$(cygpath -w ${root}/lib/python)" \
            --install-scripts="$(cygpath -w ${root}/app)" \
            ${setuptools_args} \
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
                BINARY_PATH="${root}/app" \
                INCLUDE_PATH="${root}/include" \
                LIBRARY_PATH="${root}/lib" install
        ;;
    png)
        do_configure
        make $parallel
        make install
        ;;
    jpeg)
        # Windows defines boolean as unsigned char, but libjpeg thinks it
        # is int.  This can cause problems depending on what headers are
        # included in what order.
        sed -i 's/typedef int boolean/typedef unsigned char boolean/' jmorecfg.h
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
                prefix="${root}" \
                BINARY_PATH="${root}/app"
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
    icontheme)
        do_configure
        make $parallel
        make install
        # Regenerate icon cache without image data to save space
        gtk-update-icon-cache -qif "${root}/share/icons/Adwaita"
        ;;
    gtk)
        # http://pkgs.fedoraproject.org/cgit/mingw-gtk3.git/commit/?id=82ccf489f4763e375805d848351ac3f8fda8e88b
        sed -i 's/#define INITGUID//' gdk/win32/gdkdnd-win32.c
        # Ensure we consistently use the system gtk-update-icon-cache
        rm -f "${root}/app/gtk-update-icon-cache.exe"
        # Cross builds try to pass --include-image-data to the system
        # gtk-update-icon-cache, which may not understand it
        if ! gtk-update-icon-cache -h | grep -q include-image-data; then
            sed -i 's/--include-image-data//' gtk/Makefile.in
        fi
        # Use gdk-pixbuf-csource we just built; the one from Cygwin can't
        # read PNG
        PATH="${root}/app:${PATH}" \
                do_configure
        make $parallel
        make install
        # Use Adwaita icon theme instead of hicolor
        echo 'gtk-icon-theme-name = "Adwaita"' > ${root}/etc/gtk-2.0/gtkrc
        ;;
    pycairo)
        # We need explicit libpython linkage on Windows
        sed -i 's/-module/-module -no-undefined -lpython27/' src/Makefile.am
        # Work around broken Autotools config
        touch ChangeLog
        # Work around missing install-sh
        autoreconf -fi
        do_configure
        make $parallel
        make install
        rename .dll .pyd ${root}/lib/python/cairo/_cairo.dll
        ;;
    pygobject)
        # We need explicit libpython linkage on Windows
        sed -i 's/-no-undefined/& -lpython27/' {glib,gio,gobject}/Makefile.am
        # glib convenience library must also be a DLL
        echo 'AM_LDFLAGS = $(common_ldflags)' >> glib/Makefile.am
        # Ensure convenience library doesn't have "python.exe" in its name
        sed -i 's/PYTHON_BASENAME=.*/PYTHON_BASENAME=python/' configure.ac
        # We pass Cygwin paths to the installed pygobject-codegen-2.0 script,
        # so have it run Cygwin Python
        sed -i 's/@PYTHON@/python/' codegen/pygobject-codegen-2.0.in
        autoreconf -fi
        do_configure \
                --disable-introspection
        make $parallel
        make install
        rename .dll .pyd \
                "${root}/lib/python/glib/_glib.dll" \
                "${root}/lib/python/gobject/_gobject.dll" \
                "${root}/lib/python/gtk-2.0/gio/_gio.dll"
        cp -a "${root}/lib/libpyglib-2.0-python.dll" "${root}/app/"
        ;;
    pygtk)
        # We give codegen Cygwin paths, so run it with Cygwin Python
        sed -i 's:$(PYTHON) $(CODEGENDIR):python $(CODEGENDIR):' \
                {.,gtk}/Makefile.am
        # We need explicit libpython linkage on Windows
        sed -i 's/-no-undefined/& -lpython27/' {.,gtk}/Makefile.am
        autoreconf -I m4 -fi
        do_configure
        make $parallel
        make install
        rename .dll .pyd \
                "${root}/lib/python/gtk-2.0/atk.dll" \
                "${root}/lib/python/gtk-2.0/pango.dll" \
                "${root}/lib/python/gtk-2.0/pangocairo.dll" \
                "${root}/lib/python/gtk-2.0/gtk/_gtk.dll"
        ;;
    celt)
        # libtool needs -no-undefined to build shared libraries on Windows
        sed -i "s/-version-info/-no-undefined -version-info/" \
                libcelt/Makefile.am
        # Don't compile test cases, since they don't build
        sed -i 's/noinst_PROGRAMS/EXTRA_PROGRAMS/' tests/Makefile.am
        autoreconf -fi
        do_configure \
                --without-ogg
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
    xml)
        do_configure \
                --with-zlib="$root" \
                --without-python
        make $parallel
        make install
        ;;
    xslt)
        # MinGW mkdir() takes only one argument
        sed -i 's/mkdir(directory, 0755)/mkdir(directory)/' libxslt/security.c
        # Ensure configure can find xml2-config
        PATH="${root}/app:${PATH}" \
                do_configure \
                --without-python \
                --without-plugins
        make $parallel
        make install
        ;;
    sqlite)
        do_configure
        make $parallel
        make install
        # Extract public-domain dedication from the top of sqlite3.h
        awk '/\*{8}/ {exit} /^\*{2}/ {print}' sqlite3.h > PUBLIC-DOMAIN.txt
        ;;
    soup)
        # 2.48.0 has a nonexistent symbol in its export list
        sed -i '/^soup_server_get_gsocket$/d' libsoup/libsoup-2.4.sym
        do_configure
        make $parallel
        make install
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
                -e 's/!write_changes/TRUE/' \
                gst/gstregistry.c
        # 0.10.36 doesn't work with Bison 3; upstream commit 60516f4798
        sed -i \
                -e '/^#define YYLEX_PARAM scanner$/d' \
                -e 's/%pure-parser/%lex-param { void *scanner }\n%pure-parser/' \
                gst/parse/grammar.y
        # gstreamer confuses POSIX timers with the availability of
        # clock_gettime()
        do_configure \
                gst_cv_posix_timers=no
        make $parallel
        make install
        ;;
    gstbase)
        do_configure \
                --disable-ogg \
                --disable-vorbis \
                --disable-examples
        make $parallel
        make install
        ;;
    gstgood)
        do_configure \
                --disable-examples
        make $parallel
        make install
        ;;
    spicegtk)
        # We give codegen Cygwin paths, so run it with Cygwin Python
        sed -i 's:$(PYTHON) $(CODEGENDIR):python $(CODEGENDIR):' \
                gtk/Makefile.in
        # We need explicit libpython linkage on Windows
        sed -i 's/SpiceClientGtk_la_LDFLAGS =/& -no-undefined -lpython27/' \
                gtk/Makefile.in
        do_configure \
                --with-sasl=no \
                --with-gtk=2.0 \
                --with-audio=gstreamer \
                --with-python=yes \
                --enable-smartcard=no
        # Ensure make can find pygobject-codegen-2.0, and that CODEGENDIR
        # is set correctly (spice-gtk runs pkg-config at make time)
        PATH="${root}/app:${PATH}" \
                PKG_CONFIG_LIBDIR="${root}/lib/pkgconfig" \
                PKG_CONFIG_PATH= \
                make $parallel
        make install
        rename .dll .pyd \
                "${root}/lib/python/SpiceClientGtk.dll"
        ;;
    msgpack)
        setup_py
        ;;
    lxml)
        # Wrap xslt-config script so it can be run from native Python
        local batch
        mkdir -p "${root}/compilers"
        batch="${root}/compilers/xslt-config.bat"
        echo "@set PATH=$(cygpath -w ${root}/app);$(cygpath -w /usr/bin);%PATH%" > "${batch}"
        echo "@sh ${root}/app/xslt-config %*" >> "${batch}"
        # lxml assumes zlib is called zlib.dll on Windows
        sed -i "s/zlib/z/" setupinfo.py
        setup_py \
                --with-xslt-config="$(cygpath -w ${root}/compilers/xslt-config)"
        ;;
    six)
        setup_py
        ;;
    dateutil)
        setup_py
        ;;
    requests)
        # Packages in PyInstaller bundles don't have separate package
        # directories, so we need to look elsewhere for CA certificates
        cat > requests/certs.py <<EOF
import os, sys
def where():
    if getattr(sys, 'frozen', False):
        return os.path.join(sys._MEIPASS, 'share', 'requests', 'cacert.pem')
    else:
        return os.path.join(os.path.dirname(__file__), 'cacert.pem')
EOF
        setup_py
        ;;
    comtypes)
        # XXX update comtypes_licenses after next release
        setup_py
        ;;
    vmnetx)
        do_configure \
                --enable-update-checking="${vmnetx_update_check_url}"
        make $parallel
        make install
        # Set up hicolor icon theme
        cat > ${root}/share/icons/hicolor/index.theme <<EOF
[Icon Theme]
Name=hicolor
Comment=Default icon theme
Directories=256x256/apps
Hidden=true

[256x256/apps]
Size=256
Type=Scalable
MinSize=1
MaxSize=512
EOF
        ;;
    esac

    # Work around packages that don't pass -bindir to libtool link mode
    if stat -t ${root}/bin/*.dll >/dev/null 2>&1 ; then
        mkdir -p "${root}/app"
        mv ${root}/bin/*.dll "${root}/app/"
    fi

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
    zipdir="vmnetx-windows-src-${vmnetx_ver}"
    rm -rf "${zipdir}"
    mkdir -p "${zipdir}/tar"
    for package in $packages
    do
        fetch "$package"
        cp "$(tarpath ${package})" "${zipdir}/tar/"
    done
    cp build.sh generate-components.py MS-RL.txt README.icon README.md \
            ui.wxi vmnetx.ico vmnetx.spec.in vmnetx.verinfo.in vmnetx.wxs \
            "${zipdir}/"
    rm -f "${zipdir}.zip"
    zip -r "${zipdir}.zip" "${zipdir}"
    rm -r "${zipdir}"
}

bdist() {
    # Build binary distribution
    local tool package name licensedir zipdir artifact_parent

    # Check versions of embeddable Windows-native tools
    for tool in $wintools
    do
        if ! wintool_current "${tool}" ; then
            echo "$tool is missing or out of date.  Rerun setup subcommand."
            exit 1
        fi
    done

    # Build
    for package in $packages
    do
        build_one "$package"
    done

    # Copy licenses
    for package in $packages
    do
        licensedir="${root}/licenses/$(expand ${package}_name)"
        rm -rf "${licensedir}"
        mkdir -p "${licensedir}"
        for artifact in $(expand ${package}_licenses)
        do
            cp "${build}/$(expand ${package}_build)/${artifact}" \
                    "${licensedir}"
        done
    done

    # Create PyInstaller bundle
    local winroot
    winroot="$(cygpath -w ${root} | sed -e 's/\\/\\\\/g')"
    sed -e "s;!!ROOT!!;${winroot};g" vmnetx.spec.in > vmnetx.spec
    sed -e "s/!!VERSION!!/${vmnetx_ver}/g" \
            -e "s/!!VERSION_MAJOR!!/$(echo ${vmnetx_ver} | cut -f1 -d.)/g" \
            -e "s/!!VERSION_MINOR!!/$(echo ${vmnetx_ver} | cut -f2 -d.)/g" \
            -e "s/!!VERSION_REVISION!!/$(echo ${vmnetx_ver} | cut -f3 -d.)/g" \
            vmnetx.verinfo.in > vmnetx.verinfo
    # DLLs must be in PATH for PyInstaller to find them
    PATH="$(cygpath -w ${root}/app):${PATH}" \
            $(cygpath "c:\Python27\Scripts\pyi-build.exe") \
            --distpath="$(cygpath -w ${root}/bundle)" \
            --workpath="$(cygpath -w ${build}/pyinstaller)" \
            --clean \
            --noconfirm \
            vmnetx.spec
    local bundledir
    bundledir="${root}/bundle/vmnetx"

    # Drop system libraries from PyInstaller bundle
    rm -f ${bundledir}/{ole32,oleaut32,shell32,user32,ws2_32}{,.dll}

    # Strip libraries.  Stripping seems to break MSVC-compiled libraries,
    # so limit ourselves to those built with MinGW.
    local file
    find "${root}/bundle" -name '*.dll' -o -name '*.pyd' | while read file; do
        if ${build_host}-objdump -h "${file}" | grep -qF .CRT ; then
            echo "Stripping ${file#${bundledir}/}"
            ${build_host}-strip "${file}"
        else
            echo "Not stripping ${file#${bundledir}/}"
        fi
    done

    # Generate file components for WiX
    ${python} generate-components.py "$(cygpath -w ${bundledir})" > components.wxi

    # Build installer
    local wixdir
    wixdir=$(cygpath "c:\Program Files\WiX Toolset v${wix_ver}\bin")
    "${wixdir}/candle" \
            "-dVersion=${vmnetx_ver}" \
            vmnetx.wxs
    # Suppress warning 1076, caused by AllowSameVersionUpgrades
    "${wixdir}/light" \
            -ext WixUIExtension -cultures:en-us \
            -sw1076 \
            -out "vmnetx-${vmnetx_ver}.msi" \
            vmnetx.wixobj
}

clean() {
    # Clean built files
    local package artifact
    if [ $# -gt 0 ] ; then
        for package in "$@"
        do
            echo "Cleaning ${package}..."
            rm -f "${root}/$(expand ${package}_stamp)"
        done
    else
        echo "Cleaning..."
        rm -rf 32 64 vmnetx-winbuild-*.zip *.msi *.wixobj *.wixpdb \
                components.wxi vmnetx.spec vmnetx.verinfo
    fi
}

updates() {
    # Report new releases of software packages
    local package url curver newver
    for package in $wintools $packages
    do
        url="$(expand ${package}_upurl)"
        if [ -z "$url" ] ; then
            continue
        fi
        curver="$(expand ${package}_ver)"
        newver=$(wget -q --no-check-certificate -O- "$url" | \
                sed -nr "s%.*$(expand ${package}_upregex).*%\\1%p" | \
                sort -uV | \
                tail -n 1)
        if [ "${curver}" != "${newver}" ] ; then
            printf "%-15s %10s  => %10s\n" "${package}" "${curver}" "${newver}"
        fi
    done
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

    pythondir="$(cygpath 'c:\Python27')"
    python="${pythondir}/python.exe"
    if [ ! -e "${python}" ] ; then
        echo "Native Python not installed"
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

# Environment setup bypasses normal startup
if [ "$1" = "setup" ] ; then
    setup_environment "$2"
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
updates)
    updates
    ;;
*)
    cat <<EOF
Usage: $0 setup /path/to/cygwin/setup.exe
       $0 sdist
       $0 [-j<n>] [-m{32|64}] bdist
       $0 [-m{32|64}] clean [package...]
       $0 updates

Packages:
$packages
EOF
    exit 1
    ;;
esac
exit 0
