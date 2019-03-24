#!/bin/sh

TOKEN=${TOKEN:?missing gitlab API token}
REF=${REF:-master}

curl --output artifacts.zip --header "PRIVATE-TOKEN: $TOKEN" \
    https://git.cmusatyalab.org/api/v4/projects/24/jobs/artifacts/$REF/download?job=build_source

unzip artifacts.zip

