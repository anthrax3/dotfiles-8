#!/bin/sh

homedir=/mnt/fast/sue/WT.1234
runnerdir=../../../bench/wtperf/runners
testdir=~/wtperf.tests
#
# This script assumes you're executing from the build
# directory for wtperf: .../build_posix/bench/wtperf
#
if test "$#" -lt "1"; then
	echo "Must specify long or short"
	exit 1
fi
if test "$1" == "short"; then
	t1=$runnerdir/test1-50m-lsm.wtperf
	t2=$runnerdir/test2-50m-lsm.wtperf
	t3=$runnerdir/test3-50m-lsm.wtperf
	t4=$runnerdir/test4-50m-lsm.wtperf
	statsec=30
else
	t1=$runnerdir/test1-500m-lsm.wtperf
	t2=$runnerdir/test2-500m-lsm.wtperf
	t3=$runnerdir/test3-500m-lsm.wtperf
	t4=$runnerdir/test4-500m-lsm.wtperf
	statsec=60
fi
statarg=""
if test "$#" -eq "2"; then
	if test "$2" == "stat"; then
		statarg="-C statistics=(fast,clear),statistics_log=(wait=$statsec)"
	fi
fi
out=$testdir/wtperf.out.$$
runtest() {
	echo "======== $1 ========" >> $out
	datestr=`date +%Y%m%d_%H%M%S`
	datadir=$testdir/$datestr
	mkdir $datadir
	echo `git rev-parse HEAD` > $datadir/WT.gitrev
	echo "wtperf -h $homedir -O $1 -m $datadir $statarg"
	cp $1 $datadir
	echo `date` >> $out 
	./wtperf -O $1 -h $homedir -m $datadir $statarg 2>&1 $out
	echo `date` >> $out
	if test -e $homedir/test.stat; then
		cp $homedir/test.stat $datadir
	fi
	statfiles=`ls $homedir/WiredTigerStat*`
	for s in $statfiles; do
		f=$(basename "$s")
		cp $s $datadir/$f
	done
}

rm -rf $homedir
mkdir $homedir
runtest $t1
#
# If it is the large run, compact may not have finished.  Give it time.
#
if test "$1" == "long"; then
	sleep 1200
fi
runtest $t2
runtest $t3
runtest $t4
echo `date`
echo "======== DONE ========" >> $out
echo "======== DONE ========" 
