FROM ubuntu:focal

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

RUN echo "EATMYDATA=yes" > /root/.pbuilderrc

VOLUME [ "/src" ]
WORKDIR /src
