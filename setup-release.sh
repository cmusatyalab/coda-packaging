#!/bin/sh

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

sed -e "s/%%VERSION%%/$VERSION/" \
    -e "s/%%AUTHOR%%/$AUTHOR/" \
    -e "s/%%DATE%%/$RPM_DATE/" \
    < rpm/coda.spec.in > rpm/coda.spec


rpmbuild -bs --define "_sourcedir ." --define "_srcrpmdir ." rpm/coda.spec

# artifacts: debian/ *.src.rpm

