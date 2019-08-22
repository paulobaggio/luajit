#!/bin/bash

set -e
set +x

VER=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3)
WORKDIR=$(pwd)
RPMBUILD=$HOME/rpmbuild
RPM=$WORKDIR/rpm/$VER

rm -rf $RPM $RPMBUILD
mkdir -p $RPM $RPMBUILD/{BUILD,RPMS,SRPMS,SPECS,SOURCES}

cp -r $WORKDIR/specs/* $RPMBUILD/SPECS

/usr/bin/spectool -g -S -C $RPMBUILD/SOURCES $RPMBUILD/SPECS/LuaJIT.spec


/usr/bin/rpmbuild \
        --define "_topdir $RPMBUILD"    \
        -ba $RPMBUILD/SPECS/LuaJIT.spec

cp $(find $RPMBUILD/RPMS $RPMBUILD/SRPMS -name *.rpm) $RPM
