#!/bin/bash
#
# Debian/Ubuntu package builds
# expected to run inside ubuntu-pbuilder container
#

# approximate number of lines written to stdout during build
BUILD_LINES=5000

set -ex

if [ "$1" = "--update" ] ; then
    UPDATE=1
    shift
fi

# expect something like "trixie-amd64"
DIST="$@"

# if a specific release wasn't given, build all releases (will take a while.....)
ALL_DISTS="bullseye bookworm trixie focal jammy noble"

declare -A RELEASES
#RELEASES["buster"]="debian10.0"
RELEASES["bullseye"]="debian11.0"
RELEASES["bookworm"]="debian12.0"
RELEASES["trixie"]="debian13.0"
RELEASES["forky"]="debian14.0"
RELEASES["sid"]="debian.unstable"

#RELEASES["bionic"]="ubuntu18.04"
RELEASES["focal"]="ubuntu20.04"
RELEASES["jammy"]="ubuntu22.04"
RELEASES["noble"]="ubuntu24.04"
RELEASES["resolute"]="ubuntu26.04"

if [ -n "${DIST}" ] ; then
    for dist in ${DIST} ; do
        known=0
        RELEASE=$(echo "$dist" | sed 's/^\(.*\)-\([^-]*\)$/\1/')
        for release in ${!RELEASES[@]} ; do
            [ "$RELEASE" = "$release" ] && known=1
        done
        if [ $known -eq 0 ] ; then
            echo "Unknown Debian or Ubuntu release: $dist"
            exit 0
        fi
    done
fi

## enable backports to get more up-to-date versions
declare -A OTHER_REPOS
OTHER_REPOS["buster"]='|deb http://archive.debian.org/debian/ DISTRO-backports main'
OTHER_REPOS["bullseye"]='|deb http://archive.debian.org/debian/ DISTRO-backports main'

declare -A EXTRA_PKGS
#EXTRA_PKGS["buster"]="dh-systemd netcat"
EXTRA_PKGS["bullseye"]="netcat"
EXTRA_PKGS["bookworm"]="netcat-openbsd"
EXTRA_PKGS["trixie"]="netcat-openbsd systemd-dev"
EXTRA_PKGS["forky"]="netcat-openbsd"
EXTRA_PKGS["sid"]="netcat-openbsd"
EXTRA_PKGS["bionic"]="dh-systemd netcat"
EXTRA_PKGS["focal"]="dh-systemd netcat"
EXTRA_PKGS["jammy"]="netcat"
EXTRA_PKGS["noble"]="netcat-openbsd"
EXTRA_PKGS["resolute"]="netcat-openbsd systemd-dev"

chroots=$(pwd)/chroots-deb
mkdir -p "$chroots"

distdir=$(pwd)/dist
mkdir -p "$distdir"

project=$(dpkg-parsechangelog | sed -ne 's/Source: \(.*\)/\1/p')
version=$(dpkg-parsechangelog | sed -ne 's/Version: \(.*\)-[^-]*/\1/p')

tmp=$(mktemp -dt debpkg-XXXXXXXX)
src=$(ls coda-*.tar.xz | tail -1)
cp $src $tmp/${project}_$version.orig.tar.xz

for dist in ${DIST:-$ALL_DISTS}
do
  release=$(echo "$dist" | sed 's/^\(.*\)-\([^-]*\)$/\1/')
  arch=$(echo "$dist" | sed 's/^\(.*\)-\([^-]*\)$/\2/')
  distver="${RELEASES[$release]}"

  chroot_tgz=$chroots/$dist.tgz
  extra_pkgs="debootstrap fakeroot pbuilder wget debhelper dh-python libreadline-dev libncurses5-dev liblua5.1-0-dev flex bison pkg-config python3 python3-pip meson ninja-build valgrind systemd eatmydata libuv1-dev libgnutls28-dev ${EXTRA_PKGS[$release]}"

  ##
  ## Create/update chroot
  ##
  if [ ! -s $chroot_tgz ]
  then
      case "$distver" in
      debian*)
          DEB_MIRROR="http://deb.debian.org/debian"
          DEB_SECURITY="deb http://deb.debian.org/debian-security DISTRO-security main"
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
      [ "$release" = "buster" ] && DEB_SECURITY="deb http://security.debian.org/debian-security DISTRO/updates main"
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

for dist in ${DIST:-$ALL_DISTS}
do
  release=$(echo "$dist" | sed 's/^\(.*\)-\([^-]*\)$/\1/')
  arch=$(echo "$dist" | sed 's/^\(.*\)-\([^-]*\)$/\2/')
  distver="${RELEASES[$release]}"

  chroot_tgz=$chroots/$dist.tgz

  ##
  ## Build package
  ##
  tar xf $tmp/${project}_$version.orig.tar.xz -C $tmp
  cp -a debian $tmp/${project}-$version

  sed -i -e "s/DISTVER/$distver/g" \
         -e "s/UNRELEASED/$release/g" \
      $tmp/$project-$version/debian/changelog

  # groovy has modules-load.d in /lib instead of /usr/lib
  if [ "$release" = "groovy" ]
  then
      sed -i -e 's_usr/\(lib/modules-load\.d/.*\)_\1_' \
          $tmp/$project-$version/debian/coda-client.install
  fi
  # bullseye, bookworm, focal, and jammy have systemd units in /lib/systemd/system
  # instead of /usr/lib/systemd/system
  if [ "$release" = "bullseye" -o "$release" = "bookworm" -o "$release" = "focal" -o "$release" = "jammy" ]
  then
      sed -i -e 's_usr/\(lib/systemd/.*\)_\1_' \
          $tmp/$project-$version/debian/coda-client.install
      sed -i -e 's_usr/\(lib/systemd/.*\)_\1_' \
          $tmp/$project-$version/debian/coda-server.install
      sed -i -e 's_usr/\(lib/systemd/.*\)_\1_' \
          $tmp/$project-$version/debian/coda-update.install
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

rm -r $tmp
