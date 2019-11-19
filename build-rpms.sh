#!/bin/bash
#
# Fedora/RHEL/CentOS package builds
# expected to run inside fedora container
#

# approximate number of lines written to stdout during build
BUILD_LINES=5000

set -e

if [ "$1" != "--in-docker" ] ; then
    echo "This script is expected to run inside a fedora container"
    exit 1
fi
shift

if [ "$1" = "--update" ] ; then
    shift
fi

DIST=${1}

RPMROOTS="$(echo fedora-{29,30,31}-{x86_64,i386}) epel-6-x86_64 epel-7-coda-x86_64"

if [ -n "${DIST}" ] ; then
    for dist in ${DIST} ; do
        known=0
        for root in ${RPMROOTS} ; do
            [ "${DIST}" = "$root" ] && known=1
        done
        if [ $known -eq 0 ] ; then
            echo "Unknown Fedora/RHEL/CentOS release: $dist"
            exit 0
        fi
    done
fi

sourcedir=$(pwd)

cachedir=$(pwd)/chroots-rpm/mock
install -g mock -m 2775 -d "$cachedir"

distdir=$(pwd)/dist
mkdir -p "$distdir"

chown -R builder:mock "$cachedir" "$distdir"

echo "config_opts['use_nspawn'] = False" >> /etc/mock/site-defaults.cfg 
echo "config_opts['cache_topdir'] = '$cachedir'" >> /etc/mock/site-defaults.cfg 

## Build .src.rpm
cd /var/tmp
RPM_VERSION=$(sed -ne 's/^Version: *\(.*\)$/\1/p' $sourcedir/rpm/coda.spec)
VERSION=$(echo $RPM_VERSION | tr _ -)

tar -xJf $sourcedir/coda-$VERSION.tar.xz
[ "$VERSION" != "$RPM_VERSION" ] && mv coda-$VERSION coda-$RPM_VERSION
tar -cJf coda-$RPM_VERSION.tar.xz coda-$RPM_VERSION
rm -r coda-$RPM_VERSION

rpmbuild -bs --define "_sourcedir ." --define "_srcrpmdir ." $sourcedir/rpm/coda.spec
[ "$VERSION" != "$RPM_VERSION" ] && rm coda-$RPM_VERSION.tar.xz

for root in ${DIST:-$RPMROOTS}
do
    runuser -l builder -c "mock -r $root -v --rebuild /var/tmp/coda-$RPM_VERSION-*.src.rpm --resultdir=$distdir" 2>&1 | \
        pv -l -s $BUILD_LINES -N "coda-${root}" > $distdir/build-${root}.log
done

#rm coda-$RPM_VERSION-*.src.rpm

# artifacts = "$distdir/*.rpm"

