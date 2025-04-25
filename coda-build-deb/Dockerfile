FROM ubuntu:noble

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    debian-archive-keyring \
    eatmydata \
    pbuilder \
    pv \
    rpm \
    sudo \
    unzip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN printf "EATMYDATA=yes\nAPTCACHEHARDLINK=no" > /root/.pbuilderrc

VOLUME [ "/src" ]
WORKDIR /src

COPY build-debs.sh /build-debs.sh
ENTRYPOINT [ "/build-debs.sh" ]
