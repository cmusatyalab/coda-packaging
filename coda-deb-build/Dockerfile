FROM ubuntu:bionic

RUN apt-get update \
 && apt-get install -y curl pbuilder \
 && apt-get clean && rm -r /var/cache/apt

VOLUME [ "/src" ]
WORKDIR /src
