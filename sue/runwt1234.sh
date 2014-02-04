#!/bin/sh

dir=/mnt/fast/sue/WT.1234
runnerdir=../../../bench/wtperf/runners
#
# This script assumes you're executing from the build
# directory for wtperf: .../build_posix/bench/wtperf
#
if test "$#" -ne "1"; then
	echo "Must specify long or short"
	exit 1
fi
if test "$1" == "short"; then
	t1=$runnerdir/test1-50m-lsm.wtperf
	t2=$runnerdir/test2-50m-lsm.wtperf
	t3=$runnerdir/test3-50m-lsm.wtperf
	t4=$runnerdir/test4-50m-lsm.wtperf
else
	t1=$runnerdir/test1-500m-lsm.wtperf
	t2=$runnerdir/test2-500m-lsm.wtperf
	t3=$runnerdir/test3-500m-lsm.wtperf
	t4=$runnerdir/test4-500m-lsm.wtperf
fi
out=~/wtperf.out
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
runtest $t2
runtest $t3
runtest $t4
echo `date`
echo "======== DONE ========" >> $out
echo "======== DONE ========" 
