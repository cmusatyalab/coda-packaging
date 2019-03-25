#!/bin/sh

TOKEN=${TOKEN:?missing gitlab API token}
CODA_REF=${CODA_REF:-master}

curl --output artifacts.zip --header "PRIVATE-TOKEN: $TOKEN" \
    https://git.cmusatyalab.org/api/v4/projects/24/jobs/artifacts/$CODA_REF/download?job=build_source

unzip artifacts.zip


VERSION=${1:-$(ls coda-*.tar.?z 2>/dev/null | head -1 | sed -ne 's/^coda-\(.*\)\.tar\..z/\1/p')}
VERSION=${VERSION:?usage: $0 <version>}
DEB_DATE="$(date -R)"
RPM_DATE="$(date +'%a %b %d %Y')"
AUTHOR='Jan Harkes <jaharkes@cs.cmu.edu>'

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

tar -xJf coda-$VERSION.tar.xz
mv coda-$VERSION coda-$RPM_VERSION
tar -cJf coda-$RPM_VERSION.tar.xz coda-$RPM_VERSION
rm -r coda-$RPM_VERSION

rpmbuild -bs --define "_sourcedir ." --define "_srcrpmdir ." rpm/coda.spec

rm -r coda-$RPM_VERSION.tar.xz

# artifacts: coda-*.tar.?z debian/ *.src.rpm

