#
# see also:  https://github.com/mmornati/docker-mock-rpmbuilder
#
FROM fedora:latest

RUN dnf install -y --nodocs \
    make mock pv rpmdevtools rpm-build \
 && dnf clean all \
 && rm -rf /var/cache/yum

VOLUME [ "/src" ]
WORKDIR /src

COPY build-rpms.sh /build-rpms.sh
ENTRYPOINT [ "/build-rpms.sh" ]
