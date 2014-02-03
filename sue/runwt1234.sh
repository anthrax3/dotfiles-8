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
echo "======== $t1 ========" >> $out
datestr=`date +%Y%m%d_%H%M%S`
datadir=~/wtperf.tests/$datestr
mkdir $datadir
rm -rf $dir
mkdir $dir
echo "wtperf -h $dir -O $t1 -m $datadir"
cp $t1 $datadir
echo `date` >> $out 
./wtperf -O $t1 -h $dir -m $datadir 2>&1 $out
echo `date` >> $out

echo "======== $t2 ========" >> $out
datestr=`date +%Y%m%d_%H%M%S`
datadir=~/wtperf.tests/$datestr
mkdir $datadir
echo "wtperf -h $dir -O $t2 -m $datadir"
cp $t2 $datadir
echo `date` >> $out
./wtperf -O $t2 -h $dir -m $datadir 2>&1 $out
echo `date` >> $out

echo "======== $t3 ========" >> $out
datestr=`date +%Y%m%d_%H%M%S`
datadir=~/wtperf.tests/$datestr
mkdir $datadir
echo "wtperf -h $dir -O $t3 -m $datadir"
cp $t3 $datadir
echo `date` >> $out
./wtperf -O $t3 -h $dir -m $datadir 2>&1 $out
echo `date` >> $out

echo "======== $t4 ========" >> $out
datestr=`date +%Y%m%d_%H%M%S`
datadir=~/wtperf.tests/$datestr
mkdir $datadir
echo "wtperf -h $dir -O $t4 -m $datadir"
cp $t4 $datadir
echo `date` >> $out
./wtperf -O $t4 -h $dir -m $datadir 2>&1 $out
echo `date` >> $out

echo `date`
echo `date` >> $out
echo "======== DONE ========" >> $out
echo "======== DONE ========" 
