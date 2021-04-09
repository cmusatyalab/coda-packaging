#!/bin/sh

DEB_RELEASES="jessie stretch buster xenial bionic focal groovy"
RPM_RELEASES="$(/bin/bash -c 'echo fedora-{32,33}-{x86_64,i386}') epel-7-coda-x86_64 epel-8-x86_64"

( cd build-container-ubuntu &&
  docker build -t build-container-ubuntu:latest . )

( cd build-container-fedora &&
  docker build -t build-container-fedora:latest . )

## $1 can be 'update' to update existing chroots
UPDATE=""
if [ "$1" = "--update" ] ; then
    UPDATE="--update"
    shift
fi

ALL_RELEASES="$DEB_RELEASES $RPM_RELEASES"
DIST="${@:-$ALL_RELEASES}"

DEB_DIST=
RPM_DIST=
for dist in ${DIST} ; do
    known=0
    for release in ${DEB_RELEASES} ; do
        if [ "$dist" = "$release" ] ; then
            DEB_DIST="$DEB_DIST $dist"
            known=1
        fi
    done
    for release in ${RPM_RELEASES} ; do
        if [ "$dist" = "$release" ] ; then
            RPM_DIST="$RPM_DIST $dist"
            known=1
        fi
    done
    if [ "$known" -eq 0 ] ; then
        echo "Unknown release $dist"
        exit 0
    fi
done

if [ -n "$DEB_DIST" ] ; then
    docker run --rm -it \
        -v $(pwd):/src \
        --privileged \
        --entrypoint ./build-debs.sh \
        build-container-ubuntu:latest --in-docker $UPDATE $DEB_DIST
fi

if [ -n "$RPM_DIST" ] ; then
    docker run --rm -it \
        -v $(pwd):/src \
        --privileged \
        --entrypoint ./build-rpms.sh \
        build-container-fedora:latest --in-docker $RPM_DIST
fi
