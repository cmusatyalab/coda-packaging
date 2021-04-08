#!/bin/bash
#
# Debian/Ubuntu package builds
# expected to run inside ubuntu-pbuilder container
#

# approximate number of lines written to stdout during build
BUILD_LINES=5000

set -e

if [ "$1" != "--in-docker" ] ; then
    echo "This script is expected to run inside the ubuntu-pbuilder container"
    exit 1
fi
shift

if [ "$1" = "--update" ] ; then
    UPDATE=1
    shift
fi

# expect something like "jessie"
DIST="$@"

# if a specific release wasn't given, build all releases (will take a while.....)
ALL_DISTS="jessie stretch buster xenial bionic focal groovy"

declare -A RELEASES
RELEASES["jessie"]="debian8.0"
RELEASES["stretch"]="debian9.0"
RELEASES["buster"]="debian10.0"
RELEASES["bullseye"]="debian.testing"
RELEASES["sid"]="debian.unstable"
RELEASES["xenial"]="ubuntu16.04"
RELEASES["bionic"]="ubuntu18.04"
RELEASES["focal"]="ubuntu20.04"
RELEASES["groovy"]="ubuntu20.10"

if [ -n "${DIST}" ] ; then
    for dist in ${DIST} ; do
        known=0
        for release in ${!RELEASES[@]} ; do
            [ "$dist" = "$release" ] && known=1
        done
        if [ $known -eq 0 ] ; then
            echo "Unknown Debian or Ubuntu release: $dist"
            exit 0
        fi
    done
fi

## enable backports to get more up-to-date versions
declare -A OTHER_REPOS
OTHER_REPOS["jessie"]='|deb http://archive.debian.org/debian/ DISTRO-backports main'
#OTHER_REPOS["stretch"]="|deb http://deb.debian.org/debian/ DISTRO-backports main"

declare -A EXTRA_PKGS
EXTRA_PKGS["jessie"]=""
EXTRA_PKGS["stretch"]=""
EXTRA_PKGS["buster"]=""
EXTRA_PKGS["bullseye"]=""
EXTRA_PKGS["sid"]=""
EXTRA_PKGS["xenial"]=""
EXTRA_PKGS["bionic"]=""
EXTRA_PKGS["focal"]=""
EXTRA_PKGS["groovy"]=""

chroots=$(pwd)/chroots-deb
mkdir -p "$chroots"

distdir=$(pwd)/dist
mkdir -p "$distdir"

project=$(dpkg-parsechangelog | sed -ne 's/Source: \(.*\)/\1/p')
version=$(dpkg-parsechangelog | sed -ne 's/Version: \(.*\)-[^-]*/\1/p')

tmp=$(mktemp -dt debpkg-XXXXXXXX)
cp coda-*.tar.xz $tmp/${project}_$version.orig.tar.xz

for release in ${DIST:-$ALL_DISTS}
do
  distver="${RELEASES[$release]}"

  for arch in amd64 i386
  do
    [ "$release-$arch" = "focal-i386" ] && break
    [ "$release-$arch" = "groovy-i386" ] && break

    chroot_tgz=$chroots/$release-$arch.tgz
    extra_pkgs="debootstrap fakeroot pbuilder wget debhelper dh-python dh-systemd libreadline-dev libncurses5-dev liblua5.1-0-dev flex bison pkg-config python3 python3-attr python3-setuptools automake systemd netcat eatmydata libuv1-dev libgnutls28-dev ${EXTRA_PKGS[$release]}"

    ##
    ## Create/update chroot
    ##
    if [ ! -s $chroot_tgz ]
    then
        case "$distver" in
        debian*)
            DEB_MIRROR="http://deb.debian.org/debian"
            DEB_SECURITY="deb http://security.debian.org/debian-security DISTRO/updates main"
            DEB_KEYRING="/usr/share/keyrings/debian-archive-keyring.gpg"
            DEB_COMPONENTS="main"
            ;;
        ubuntu*)
            DEB_MIRROR="http://us.archive.ubuntu.com/ubuntu"
            DEB_SECURITY="deb http://security.ubuntu.com/ubuntu DISTRO-security main universe"
            DEB_KEYRING="/usr/share/keyrings/ubuntu-archive-keyring.gpg"
            DEB_COMPONENTS="main universe"
            ;;
        esac
        OTHER_MIRRORS=$(echo ${DEB_SECURITY}${OTHER_REPOS[$release]} | sed -e "s/DISTRO/$release/g")

        pbuilder --create \
            --basetgz $chroot_tgz \
            --distribution "$release" \
            --architecture "$arch" \
            --mirror "$DEB_MIRROR" \
            --othermirror "$OTHER_MIRRORS" \
            --hookdir "$(pwd)/pbuilder-hooks" \
            --debootstrapopts --variant=buildd \
            --debootstrapopts --keyring=$DEB_KEYRING \
            --components "$DEB_COMPONENTS" \
            --extrapackages "$extra_pkgs"

    elif [ -n "$UPDATE" ]
    then
        pbuilder --update --basetgz $chroot_tgz \
            --extrapackages "$extra_pkgs"
    fi
  done
done

for release in ${DIST:-$ALL_DISTS}
do
  distver="${RELEASES[$release]}"

  for arch in amd64 i386
  do
    # Ubuntu dropped 32-bit distributions
    [ "$release-$arch" = "focal-i386" ] && break
    [ "$release-$arch" = "groovy-i386" ] && break

    chroot_tgz=$chroots/$release-$arch.tgz

    ##
    ## Build package
    ##
    tar xf $tmp/${project}_$version.orig.tar.xz -C $tmp
    cp -a debian $tmp/$project-$version/

    sed -i -e "s/DISTVER/$distver/g" \
           -e "s/UNRELEASED/$release/g" \
        $tmp/$project-$version/debian/changelog

    # jessie does not have libuv1
    #if [ "$release" = "jessie" ]
    #then
    #    sed -i -e "s/ libuv1-dev,//g" \
    #        $tmp/$project-$version/debian/control
    #fi
    # jessie and xenial do not have debhelper >= 10
    if [ "$release" = "jessie" -o "$release" = "xenial" ] ; then
        echo 9 > $tmp/$project-$version/debian/compat
        sed -i -e 's/debhelper (>= 10)/debhelper (>= 9)/g' \
            $tmp/$project-$version/debian/control
    fi
    # groovy has modules-load.d in /lib instead of /usr/lib
    if [ "$release" = "groovy" ]
    then
        sed -i -e 's_usr/\(lib/modules-load\.d/.*\)_\1_' \
            $tmp/$project-$version/debian/coda-client.install
    fi

    (
        binary_only=""
        [ "$arch" != "amd64" ] && binary_only="--debbuildopts -B"

        cd $tmp/$project-$version/
        pdebuild --architecture $arch --buildresult $distdir $binary_only \
            --use-pdebuild-internal -- --basetgz "$chroot_tgz" 2>&1 | \
            pv -l -s $BUILD_LINES -N "${project}-${distver}-${arch}" > \
                $distdir/build-${distver}-${arch}.log
    )
    rm -r $tmp/$project-$version/
  done
done

rm -r $tmp

