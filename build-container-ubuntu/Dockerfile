FROM ubuntu:bionic

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
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

