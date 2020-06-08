#!/bin/sh

docker_repo=registry.cmusatyalab.org/coda/coda-packaging/coda-build
native_arch=amd64
build_arch=amd64 i386 # arm32_v6 arm64v8


docker build -f Dockerfile -t ${docker_repo}:${native_arch}-latest .
#docker push ${docker_repo}:${native_arch}-latest

for docker_arch in $build_arch
do
    if [ "${docker_arch}" = "${native_arch}" ] ; then
        continue
    fi

    case ${docker_arch} in
        amd64   ) qemu_arch="x86_64" ;;
        i386    ) qemu_arch="i386" ;;
        arm32v6 ) qemu_arch="arm" ;;
        arm64v8 ) qemu_arch="aarch64" ;;
    esac

    sed -e "s|^FROM \(.*\)|FROM ${docker_arch}/\1\nCOPY qemu-${qemu_arch}-static /usr/bin/|" \
	    < Dockerfile > Dockerfile.${docker_arch}
    cp /usr/bin/qemu-${qemu_arch}-static .

    docker build -f Dockerfile.${docker_arch} -t ${docker_repo}:${docker_arch}-latest .
    #docker push ${docker_repo}:${docker_arch}-latest

    #rm -f Dockerfile.${docker_arch} qemu-${qemu_arch}-static
done

#... expand $build_arch
#docker manifest create --amend ${docker_repo}:latest \
#	${docker_repo}:amd64-latest \
#	${docker_repo}:arm32v6-latest \
#	${docker_repo}:arm64v8-latest
#docker manifest annotate ${docker_repo}:latest \
#	${docker_repo}:arm32v6-latest --os linux --arch arm
#docker manifest annotate ${docker_repo}:latest \
#	${docker_repo}:arm64v8-latest --os linux --arch arm64 --variant armv8
#docker manifest push ${docker_repo}:latest

