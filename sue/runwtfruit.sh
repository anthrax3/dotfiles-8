#!/bin/sh

dir=/mnt/fast/sue/WT.FRUIT
runnerdir=../../../bench/wtperf/runners
#
# This directory assumes you're executing from the build
# directory for wtperf: .../build_posix/bench/wtperf
#
if test "$#" -ne "1"; then
	echo "Must specify long or short."
	exit 1
fi
if test "$1" == "long"; then
	t1=$runnerdir/fruit-lsm.wtperf
else
	t1=$runnerdir/fruit-short.wtperf
fi
runtest() {
	echo "======== $1 ========" >> $out
	datestr=`date +%Y%m%d_%H%M%S`
	datadir=~/wtperf.tests/$datestr
	mkdir $datadir
	echo "wtperf -h $dir -O $1 -m $datadir"
	cp $1 $datadir
	echo `date` >> $out 
	./wtperf -O $1 -h $dir -m $datadir 2>&1 $out
	echo `date` >> $out
	echo `git rev-parse HEAD` > $datadir/WT.gitrev
	if test -e $dir/test.stat; then
		cp $dir/test.stat $datadir
	fi
	statfiles=`ls $dir/WiredTigerStat*`
	for s in $statfiles; do
		f=$(basename "$s")
		cp $s $datadir/$f
	done
}
rm -rf $dir
mkdir $dir
runtest $t1
echo `date`
echo "======== DONE ========" 
