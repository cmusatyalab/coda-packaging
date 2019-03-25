FROM ubuntu:bionic

RUN apt-get update \
 && apt-get install -y curl debian-archive-keyring pbuilder rpm sudo \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

VOLUME [ "/src" ]
WORKDIR /src
