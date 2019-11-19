#!/bin/sh
set -e

if [ -z "$CODA_DISTRIBUTE_HOST" -o -z "$CODA_INCOMING_DIR" ]
then
    echo "need host and dir"
    exit 1
fi

rsync -rv dist/ "$CODA_DISTRIBUTE_HOST:$CODA_INCOMING_DIR"
