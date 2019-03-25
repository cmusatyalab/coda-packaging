#!/bin/bash
#
# Build Debian/Ubuntu pbuilder chroots
#
# rebuild iteration: 0
#
set -e

# assume something like "jessie:debian8.0" optionally prefixed with "chroot:"
DIST=${1#chroot:}

# if a specific release wasn't given, build all releases (will take a while.....)
ALL_DISTS="jessie:debian8.0 stretch:debian9.0 trusty:ubuntu14.04 xenial:ubuntu16.04 bionic:ubuntu18.04 cosmic:ubuntu18:10"

## enable backports to get more up-to-date versions
declare -A OTHER
OTHER["jessie"]="|deb http://deb.debian.org/debian/ DISTRO-backports main"
#OTHER["stretch"]="|deb http://deb.debian.org/debian/ DISTRO-backports main"

# really want this everywhere for codatunnel, but at least trusty (and jessie?)
# don't have a current version
declare -A EXTRA_PKGS
#EXTRA_PKGS["jessie"]="libuv1-dev"      # seems to have gone from jessie-backports
EXTRA_PKGS["stretch"]="libuv1-dev"
EXTRA_PKGS["xenial"]="libuv1-dev"
EXTRA_PKGS["bionic"]="libuv1-dev"
EXTRA_PKGS["cosmic"]="libuv1-dev"

chroots=$(pwd)/coda-deb-build/chroots
mkdir -p "$chroots"

for dist in ${DIST:-$ALL_DISTS}
do
  for arch in amd64 i386
  do
    release=$(echo $dist | cut -d: -f1)
    distver=$(echo $dist | cut -d: -f2)

    chroot_tgz=$chroots/$release-$arch.tgz
    extra_pkgs="debootstrap fakeroot pbuilder wget debhelper dh-python dh-systemd libreadline-dev libncurses5-dev liblua5.1-0-dev flex bison pkg-config python automake systemd netcat ${EXTRA_PKGS[$release]}"

    if [ ! -s $chroot_tgz ]
    then
        case "$distver" in
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
        OTHER_MIRRORS=$(echo ${DEB_SOURCES}${OTHER[$release]} | sed -e "s/DISTRO/$release/g")

        pbuilder --create \
            --basetgz $chroot_tgz \
            --distribution "$release" \
            --architecture "$arch" \
            --mirror "$DEB_MIRROR" \
            --othermirror "$OTHER_MIRRORS" \
            --debootstrapopts --variant=buildd \
            --debootstrapopts --keyring=$DEB_KEYRING \
            --components "$DEB_COMPONENTS" \
            --extrapackages "$extra_pkgs"
    else
        pbuilder --update --basetgz $chroot_tgz \
            --extrapackages "$extra_pkgs"
    fi
  done
done

