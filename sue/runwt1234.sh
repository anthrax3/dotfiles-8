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
	#	statarg="-C statistics=(fast,clear),statistics_log=(wait=$statsec),verbose=(lsm)"
	fi
fi
out=$testdir/wtperf.out.$$
runtest() {
	echo "======== $1 ========" >> $out
	datestr=`date +%Y%m%d_%H%M%S`
	datadir=$testdir/$datestr
	mkdir $datadir
	rm -f $testdir/current
	ln -s $datadir $testdir/current
	#
	# Before running, remove any stat files from a previous run.
	# Call this now, rather than after we copy them later in this
	# function so that they remain in the home dir after the last
	# call completes.
	#
	rm -f $homedir/WiredTigerStat*
	echo `git rev-parse HEAD` > $datadir/WT.gitrev
	echo "wtperf -h $homedir -O $1 -m $datadir $statarg"
	cp $1 $datadir
	echo `date` >> $out 
	echo "wtperf -h $homedir -O $1 -m $datadir $statarg" >> $out
	./wtperf -O $1 -h $homedir -m $datadir $statarg 2>&1 $out
	echo `ls -l $homedir` >> $out
	echo `date` >> $out
	#
	# After the test runs, copy anything interesting into the
	# data collection directory and generate some graphs.
	#
	if test -e $homedir/test.stat; then
		cp $homedir/test.stat $datadir
	fi
	statfiles=`ls $homedir/WiredTigerStat*`
	statf=0
	for s in $statfiles; do
		f=$(basename "$s")
		cp $s $datadir/$f
		statf=1
	done
	cwd=`pwd`
	if test "$statf" -ne "0"; then
		(cd $datadir; python $cwd/../../../tools/wtstats.py $statfiles)
	fi
	(cd $datadir; python $cwd/../../../tools/wtperf_stats.py monitor)
}

rm -rf $homedir
mkdir $homedir
runtest $t1
runtest $t2
runtest $t3
runtest $t4
echo `date`
echo "======== DONE ========" >> $out
echo "======== DONE ========" 
