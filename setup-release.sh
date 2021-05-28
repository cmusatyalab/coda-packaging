#!/bin/sh

#TOKEN=${TOKEN:?missing gitlab API token}
#CODA_REF=${CODA_REF:-master}
#
#echo "Fetching most recent coda:$CODA_REF artifacts"
#curl --output artifacts.zip --header "PRIVATE-TOKEN: $TOKEN" \
#    https://git.cmusatyalab.org/api/v4/projects/24/jobs/artifacts/$CODA_REF/download?job=build_source
#
#unzip -u artifacts.zip
#rm artifacts.zip
#echo

VERSION=${1:-$(ls coda-*.tar.?z 2>/dev/null | head -1 | sed -ne 's/^coda-\(.*\)\.tar\..z/\1/p')}
VERSION=${VERSION:?usage: $0 <version>}
DEB_DATE="$(date -R)"
RPM_DATE="$(date +'%a %b %d %Y')"
AUTHOR='Jan Harkes <jaharkes@cs.cmu.edu>'

echo "Updating deb and rpm package files for coda-$VERSION"
cat > debian/changelog << EOF
coda ($VERSION-1+DISTVER) UNRELEASED; urgency=medium

  * Automatic package build.

 -- $AUTHOR  $DEB_DATE
EOF

RPM_VERSION=$(echo $VERSION | tr - _)

sed -e "s/%%VERSION%%/$RPM_VERSION/" \
    -e "s/%%AUTHOR%%/$AUTHOR/" \
    -e "s/%%DATE%%/$RPM_DATE/" \
    < rpm/coda.spec.in > rpm/coda.spec

# artifacts: coda-*.tar.?z debian/ rpm/coda.spec
