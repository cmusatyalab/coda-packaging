FROM ubuntu:bionic

RUN apt-get update \
 && apt-get install -y curl debian-archive-keyring pbuilder rpm \
 && apt-get clean && rm -r /var/cache/apt

VOLUME [ "/src" ]
WORKDIR /src
