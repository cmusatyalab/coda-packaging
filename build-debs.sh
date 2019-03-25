#!/bin/bash
#
# Debian/Ubuntu
#

set -e

DIST=${1#build:}

ALL_DISTS="jessie:debian8.0 stretch:debian9.0 trusty:ubuntu14.04 xenial:ubuntu16.04 bionic:ubuntu18.04 cosmic:ubuntu18:10"

declare -A INSTALL_SED
INSTALL_SED["trusty"]="/\(systemd\|modules-load\.d\)/ d"

chroots=$(pwd)/chroots
mkdir -p "$chroots"

distdir=$(pwd)/dist
mkdir -p "$distdir"

project=$(dpkg-parsechangelog | sed -ne 's/Source: \(.*\)/\1/p')
version=$(dpkg-parsechangelog | sed -ne 's/Version: \(.*\)-[^-]*/\1/p')

tmp=$(mktemp -dt debpkg-XXXXXXXX)
cp coda-*.tar.xz $tmp/${project}_$version.orig.tar.xz

for dist in ${DIST:-$ALL_DISTS}
do
  for arch in amd64 i386
  do
    release=$(echo $dist | cut -d: -f1)
    distver=$(echo $dist | cut -d: -f2)

    chroot_tgz=$chroots/$release-$arch.tgz

    tar xf $tmp/${project}_$version.orig.tar.xz -C $tmp
    cp -a debian $tmp/$project-$version/

    sed -i -e "s/DISTVER/$distver/g" \
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
done

rm -r $tmp

