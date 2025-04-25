#!/bin/sh

DEBIAN_RELEASES="bullseye-amd64 bullseye-i386 bookworm-amd64 bookworm-i386"
UBUNTU_RELEASES="focal-amd64 jammy-amd64 noble-amd64"
FEDORA_RELEASES="$(/bin/bash -c 'echo fedora-{40,41}-{x86_64,i386}')"
EPEL_RELEASES="$(/bin/bash -c 'echo rocky+epel-{8,9}-x86_64')"

docker build -t coda-build-deb:latest coda-build-deb
docker build -t coda-build-rpm:latest coda-build-rpm

## $1 can be 'update' to update existing chroots
UPDATE=""
if [ "$1" = "--update" ] ; then
    UPDATE="--update"
    shift
fi

ALL_RELEASES="$DEBIAN_RELEASES $UBUNTU_RELEASE $FEDORA_RELEASES $EPEL_RELEASES"
DIST="${@:-$ALL_RELEASES}"

for dist in ${DIST} ; do
    case "$dist" in
      fedora-*|alma*|rocky*|*epel-*)
        docker run --rm -it -v $(pwd):/src --privileged \
            coda-build-rpm:latest $UPDATE $dist
        ;;
      *)
        docker run --rm -it -v $(pwd):/src --privileged \
            coda-build-deb:latest $UPDATE $dist
        ;;
    esac
done
