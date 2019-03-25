#
# see also:  https://github.com/mmornati/docker-mock-rpmbuilder
#
FROM fedora:29

RUN yum install -y --setopt="tsflag=nodocs" \
    make mock rpmdevtools rpm-build \
 && yum clean all \
 && rm -rf /var/cache/yum

COPY epel-7-coda-x86_64.cfg /etc/mock
RUN useradd -u 1000 -G mock builder \
 && chmod g+w /etc/mock/*.cfg

VOLUME [ "/src" ]
WORKDIR /src

