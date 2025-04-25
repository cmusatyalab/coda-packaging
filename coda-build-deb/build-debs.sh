#!/bin/bash
#
# Debian/Ubuntu package builds
# expected to run inside ubuntu-pbuilder container
#

# approximate number of lines written to stdout during build
BUILD_LINES=5000

set -e

if [ "$1" = "--update" ] ; then
    UPDATE=1
    shift
fi

# expect something like "jessie-amd64"
DIST="$@"

# if a specific release wasn't given, build all releases (will take a while.....)
ALL_DISTS="bullseye bookworm focal jammy noble"

declare -A RELEASES
#RELEASES["jessie"]="debian8.0"
#RELEASES["stretch"]="debian9.0"
RELEASES["buster"]="debian10.0"
RELEASES["bullseye"]="debian11.0"
RELEASES["bookworm"]="debian12.0"
#RELEASES["trixie"]="debian13.0"
#RELEASES["forky"]="debian14.0"
#RELEASES["sid"]="debian.unstable"

#RELEASES["xenial"]="ubuntu16.04"
RELEASES["bionic"]="ubuntu18.04"
RELEASES["focal"]="ubuntu20.04"
RELEASES["jammy"]="ubuntu22.04"
RELEASES["noble"]="ubuntu24.04"
RELEASES["oracular"]="ubuntu24.10"
RELEASES["plucky"]="ubuntu25.04"

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
OTHER_REPOS["jessie"]='|deb http://archive.debian.org/debian/ DISTRO-backports main'
OTHER_REPOS["stretch"]='|deb http://archive.debian.org/debian/ DISTRO-backports main'
OTHER_REPOS["buster"]='|deb http://archive.debian.org/debian/ DISTRO-backports main'

declare -A EXTRA_PKGS
EXTRA_PKGS["jessie"]="dh-systemd netcat"
EXTRA_PKGS["stretch"]="dh-systemd netcat"
EXTRA_PKGS["buster"]="dh-systemd netcat"
EXTRA_PKGS["bullseye"]="netcat"
EXTRA_PKGS["bookworm"]="netcat-openbsd"
EXTRA_PKGS["sid"]="dh-systemd netcat"
EXTRA_PKGS["xenial"]="dh-systemd netcat"
EXTRA_PKGS["bionic"]="dh-systemd netcat"
EXTRA_PKGS["focal"]="dh-systemd netcat"
EXTRA_PKGS["jammy"]="netcat"
EXTRA_PKGS["noble"]="netcat-openbsd"

chroots=$(pwd)/chroots-deb
mkdir -p "$chroots"

distdir=$(pwd)/dist
mkdir -p "$distdir"

project=$(dpkg-parsechangelog | sed -ne 's/Source: \(.*\)/\1/p')
version=$(dpkg-parsechangelog | sed -ne 's/Version: \(.*\)-[^-]*/\1/p')

tmp=$(mktemp -dt debpkg-XXXXXXXX)
cp coda-*.tar.xz $tmp/${project}_$version.orig.tar.xz

for dist in ${DIST:-$ALL_DISTS}
do
  release=$(echo "$dist" | sed 's/^\(.*\)-\([^-]*\)$/\1/')
  arch=$(echo "$dist" | sed 's/^\(.*\)-\([^-]*\)$/\2/')
  distver="${RELEASES[$release]}"

  chroot_tgz=$chroots/$dist.tgz
  extra_pkgs="debootstrap fakeroot pbuilder wget debhelper dh-python libreadline-dev libncurses5-dev liblua5.1-0-dev flex bison pkg-config python3 automake systemd eatmydata libuv1-dev libgnutls28-dev ${EXTRA_PKGS[$release]}"

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
      [ "$release" = "bullseye" ] && DEB_SECURITY="deb http://deb.debian.org/debian-security DISTRO-security main"
      [ "$release" = "bookworm" ] && DEB_SECURITY="deb http://deb.debian.org/debian-security DISTRO-security main"
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
  # noble has systemd units in /usr/lib/systemd/system instead of /lib/systemd/system
  if [ "$release" = "noble" ]
  then
      sed -i -e 's_\(lib/systemd/.*\)_usr/\1_' \
          $tmp/$project-$version/debian/coda-client.install
      sed -i -e 's_\(lib/systemd/.*\)_usr/\1_' \
          $tmp/$project-$version/debian/coda-server.install
      sed -i -e 's_\(lib/systemd/.*\)_usr/\1_' \
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
