#!/bin/sh
#
# Updates src/third_party/wiredtiger contents
#

set -o errexit

REMOTEBRANCH="develop"
LOCALBRANCH=$(git symbolic-ref HEAD)
OUTPUTFILE="wiredtiger_update.diff"

# Ensure working directory is TOPLEVEL/src/third_party
STARTPWD=$(pwd)
TOPLEVEL=$(git rev-parse --show-toplevel)
cd ${TOPLEVEL}/src/third_party

# Begin tracing commands
#set -o xtrace

chose_branch=0
while [[ $# > 1 ]]; do
	key="$1"

	case $key in
	    -b|--branch)
	    REMOTEBRANCH="$2"
	    chose_branch = 1
	    shift
	    ;;
	    -o|--output)
	    OUTPUTFILE="$2"
	    shift
	    ;;
	    *)
		    # unknown option
	    ;;
	esac
	shift
done

if [ chose_branch == 0 ]; then
	echo "No WiredTiger branch chosen, using $REMOTEBRANCH"
fi

# Write file according to "Content-Disposition: attachment" header. Example:
# Content-Disposition: attachment; filename=wiredtiger-wiredtiger-2.4.0-109-ge5aec44.tar.gz

rm -f wiredtiger-wiredtiger-*.tar.gz
curl -sOJL https://api.github.com/repos/wiredtiger/wiredtiger/tarball/${REMOTEBRANCH}

TARBALL=$(echo wiredtiger-wiredtiger-*.tar.gz)
test -f "$TARBALL"

# Delete everything in wiredtiger dir, then selectively undelete

mkdir -p wiredtiger
(cd wiredtiger;
 rm -rf *;
 git checkout -- .gitignore 'SCons*';
 git checkout -- 'build_*/wiredtiger_config.h')

# Tar options:
# - Exclude subdirs "api", "test", "src/docs"
# - Strip 'wiredtiger-wiredtiger-e5aec44/' prefix after exclude applied
# - Change to dir "wiredtiger" before extracting

tar -x --strip-components 1 \
    --exclude '*/api' --exclude '*/dist/package' --exclude '*/examples' \
    --exclude '*/src/docs' --exclude '*/test' \
    --exclude '*/tools/wtperf_stats' \
    --exclude '*/tools/wtstats/template' \
    -C wiredtiger -f ${TARBALL}

# Figure out if there have been file changes - they can mess with regular
# diff generation of patch files.
# If this gets noisy, could try:
# git diff src/third_party/wiredtiger/dist/filelist
# Instead - but it will only pick up files in src, not extensions.
changed_files=`(cd $TOPLEVEL && git ls-files --exclude-standard --others src/third_party/wiredtiger)`
if [ "x$changed_files" != "x" ]; then
	echo "Files were added, removed or updated. Be careful submitting patch builds"
	echo "$changed_files"
fi

set -o errexit
cd $STARTPWD

echo "Done applying $TARBALL to $LOCALBRANCH"

echo "Creating diff that can be used for MCI build in $OUTPUTFILE"
git diff > $OUTPUTFILE
