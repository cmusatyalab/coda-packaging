#!/bin/bash
#
# Fedora/RHEL/CentOS
#

set -e

DIST=${1:-${CI_JOB_NAME#build:}}
RPMROOTS="fedora-{28,29,30}-{i386,x86_64} epel-6-x86_64 epel-7-coda-x86_64"

sourcedir=$(pwd)

cachedir=$(pwd)/cache/mock
install -g mock -m 2775 -d "$cachedir"

distdir=$(pwd)/dist
mkdir -p "$distdir"

chown -R builder:mock "$cachedir" "$distdir"

echo "config_opts['use_nspawn'] = False" >> /etc/mock/site-defaults.cfg 
echo "config_opts['cache_topdir'] = '$cachedir'" >> /etc/mock/site-defaults.cfg 

for root in ${DIST:-$RPMROOTS}
do
    runuser -l builder -c "mock -r $root -v --rebuild $sourcedir/*.src.rpm --resultdir=$distdir"
done

# artifacts = "$distdir/*.rpm"

