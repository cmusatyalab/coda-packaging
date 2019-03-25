FROM ubuntu:bionic

RUN apt-get update \
 && apt-get install -y \
    debian-archive-keyring \
    pbuilder \
    sudo \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
