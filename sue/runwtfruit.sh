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
echo "======== $t1 ========" >> ~/wtperf.out
datestr=`date +%Y%m%d_%H%M%S`
datadir=~/wtperf.tests/$datestr
mkdir $datadir
rm -rf $dir
mkdir $dir
echo "wtperf -h $dir -O $t1 -m $datadir"
echo `date` >> ~/wtperf.out
./wtperf -O $t1 -h $dir -m $datadir 2>&1 ~/wtperf.out
echo `date`
echo "======== DONE ========" 
