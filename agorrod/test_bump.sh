#!/bin/sh
#
# Updates src/third_party/wiredtiger contents
# from github.com/wiredtiger/wiredtiger branch "develop"
#

set -o errexit

if [ $# -lt 1 ]; then
	echo "Usage $0 <branch_name>"
	exit 1
fi

REMOTEBRANCH=$1

# Ensure working directory is TOPLEVEL/src/third_party
STARTPWD=$(pwd)
TOPLEVEL=$(git rev-parse --show-toplevel)
cd ${TOPLEVEL}/src/third_party

# Begin tracing commands
set -o xtrace

rm -f wiredtiger-wiredtiger-*.tar.gz
curl -OJL https://api.github.com/repos/wiredtiger/wiredtiger/tarball/${REMOTEBRANCH}

TARBALL=$(echo wiredtiger-wiredtiger-*.tar.gz)
test -f "$TARBALL"

# Delete everything in wiredtiger dir, then selectively undelete

mkdir -p wiredtiger
(cd wiredtiger;
 rm -rf *;
 git checkout -- .gitignore 'SCons*';
 git checkout -- 'build_*/wiredtiger_config.h')

tar -x --strip-components 1 \
    -C wiredtiger -f ${TARBALL}

git add wiredtiger
#git log -n 1

set -o errexit
cd $STARTPWD
echo "Done applying $TARBALL "

read -p "Updated local tree, would you like to create an Evergreen patch build? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then

	MONGO_BRANCH=`git branch | grep "^*" | cut -d ' ' -f 2`
	TEST_SUITE="mongodb-mongo-$MONGO_BRANCH"

	evergreen patch -p $TEST_SUITE

	echo "Finished creating patch build. The build configuration link can be found above."

fi

read -p "Would you like to unstage local changes? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
	git reset HEAD
	git diff | patch -p1 -R
	git status -u --porcelain src/third_party/wiredtiger | cut -d ' ' -f 2 | xargs rm -f
fi

