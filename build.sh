#!/bin/sh

( cd build-container-ubuntu &&
  docker build -t build-container-ubuntu:latest . )

( cd build-container-fedora &&
  docker build -t build-container-fedora:latest . )

## $1 can be 'update' to update existing chroots

docker run --rm -it \
    -v $(pwd):/src \
    --privileged \
    --entrypoint ./build-debs.sh \
    build-container-ubuntu:latest --in-docker $@

docker run --rm -it \
    -v $(pwd):/src \
    --privileged \
    --entrypoint ./build-rpms.sh \
    build-container-fedora:latest --in-docker $@
