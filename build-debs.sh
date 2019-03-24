#!/bin/bash
#
# Debian/Ubuntu
#

set -e

DIST=${1:-${CI_JOB_NAME#build:}}

DEB_DISTS="{jessie,stretch,trusty,xenial,bionic,cosmic}-{amd64,i386}"

declare -A DISTVER
DISTVER["jessie"]="debian8.0"
DISTVER["stretch"]="debian9.0"
DISTVER["trusty"]="ubuntu14.04"
DISTVER["xenial"]="ubuntu16.04"
DISTVER["bionic"]="ubuntu18.04"
DISTVER["cosmic"]="ubuntu18.10"

declare -A OTHER
OTHER["jessie"]="|deb http://deb.debian.org/debian/ DISTRO-backports main"

declare -A INSTALL_SED
INSTALL_SED["trusty"]="/\(systemd\|modules-load\.d\)/ d"

declare -A EXTRA_PKGS
EXTRA_PKGS["stretch"]="libuv1-dev"
EXTRA_PKGS["xenial"]="libuv1-dev"
EXTRA_PKGS["bionic"]="libuv1-dev"
EXTRA_PKGS["cosmic"]="libuv1-dev"

cache=$(pwd)/cache
mkdir -p "$cache"

distdir=$(pwd)/dist
mkdir -p "$distdir"

project=$(dpkg-parsechangelog | sed -ne 's/Source: \(.*\)/\1/p')
version=$(dpkg-parsechangelog | sed -ne 's/Version: \(.*\)-[^-]*/\1/p')

tmp=$(mktemp -dt debpkg-XXXXXXXX)
cp coda-*.tar.xz $tmp/${project}_$version.orig.tar.xz


for dist in ${DIST:-$DEB_DISTS}
do
    release=$(echo $DIST | cut -d- -f1)
    arch=$(echo $DIST | cut -d- -f2)

    chroot_tgz=$cache/$dist.tgz
    extra_pkgs="debootstrap fakeroot pbuilder wget debhelper dh-python dh-systemd libreadline-dev libncurses5-dev liblua5.1-0-dev flex bison pkg-config python automake systemd netcat ${EXTRA_PKGS[$release]}"

    if [ ! -s $chroot_tgz ]
    then
        case ${DISTVER[$release]} in
        debian*)
            DEB_MIRROR="http://deb.debian.org/debian"
            DEB_SOURCES="deb http://security.debian.org/debian-security DISTRO/updates main"
            DEB_KEYRING="/usr/share/keyrings/debian-archive-keyring.gpg"
            DEB_COMPONENTS="main"
            ;;
        ubuntu*)
            DEB_MIRROR="http://us.archive.ubuntu.com/ubuntu"
            DEB_SOURCES="deb http://security.ubuntu.com/ubuntu DISTRO-security main"
            DEB_KEYRING="/usr/share/keyrings/ubuntu-archive-keyring.gpg"
            DEB_COMPONENTS="main universe"
            ;;
        esac

        other_mirrors=$(echo $DEB_SOURCES${OTHER[$release]} | sed -e "s/DISTRO/$release/g")
        pbuilder --create \
            --basetgz $chroot_tgz \
            --distribution "$release" \
            --architecture "$arch" \
            --mirror "$DEB_MIRROR" \
            --othermirror "$other_mirrors" \
            --debootstrapopts --variant=buildd \
            --debootstrapopts --keyring=$DEB_KEYRING \
            --components "$DEB_COMPONENTS" \
            --extrapackages "$extra_pkgs"
    #else
    #    pbuilder --update --basetgz $chroot_tgz \
    #        --extrapackages "$extra_pkgs"
    fi


    tar xf $tmp/${project}_$version.orig.tar.xz -C $tmp
    cp -a debian $tmp/$project-$version/

    sed -i -e "s/DISTVER/${DISTVER[$release]}/g" \
           -e "s/UNRELEASED/$release/g" \
        $tmp/$project-$version/debian/changelog

    sed -i -e "${INSTALL_SED[$release]}" \
        $tmp/$project-$version/debian/coda-client.install \
        $tmp/$project-$version/debian/coda-server.install \
        $tmp/$project-$version/debian/coda-update.install

    (
        binary_only=""
        [ "$arch" != "amd64" ] && binary_only="--debbuildopts -B"

        cd $tmp/$project-$version/
        pdebuild --architecture $arch --buildresult $distdir $binary_only \
            --use-pdebuild-internal -- --basetgz "$chroot_tgz"
    )
    rm -r $tmp/$project-$version/
done

rm -r $tmp


