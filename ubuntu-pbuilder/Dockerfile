FROM ubuntu:bionic

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    debian-archive-keyring \
    pbuilder \
    rpm \
    sudo \
    unzip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

VOLUME [ "/src" ]
WORKDIR /src

