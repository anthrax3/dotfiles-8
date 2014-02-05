#!/bin/sh

interval=10
i=0
imax=4000

# XXX: This really needs real arg processing.
# For now all earlier args must be specified if you want a later one.
# Usage: rumpmp.sh pid [start] [end] [interval]
if test "$#" -eq 0; then
	echo "Must give wtperf pid"
	exit 1
fi
pid=$1
if test "$#" -gt 1; then
	i=$2
fi
if test "$#" -gt 2; then
	imax=$3
fi
if test "$#" -gt 3; then
	interval=$4
fi
# Sleep enough to make sure some output gets into the sumfile.
if test "$i" -eq "0"; then
	echo "Sleeping 10 then starting"
	sleep 10
else
	# Or if we want to start later, sleep until then.
	echo "Sleeping $i.  Then run until $imax every $interval seconds"
	sleep $i
fi
date=`date`
curdir=~/wtperf.tests/current
outdir=$curdir/statusinfo
if test -d $outdir; then
	`rm $outdir/*`
else
	mkdir $outdir
fi
echo "$date: Beginning data gathering in $outdir."
homedir=/mnt/fast/sue/WT.1234
monitorfile=$curdir/monitor
perfsleep=2
waittime=`expr $interval - $perfsleep`
# The start time given by the user is approximate, get the real time
# from the csv file so our time suffix is close to the output time.
# NOTE:  This only works when riak and basho_bench are running on the
# same system.
i=`tail -1 $monitorfile | awk 'BEGIN {FS=","}{last=$2}END{print last}'`
if test "$i" -gt "$imax"; then
	echo "Start $i must be less than max $imax."
	exit 1
fi
while test "$i" -lt "$imax" ; do
	echo -n "$i "
	echo "Executing pmp.sh"
	~/pmppid.sh $pid > $outdir/pmp.$i
	date=`date`
	echo "======== $date ======== for ls "
	echo "======== $date ========" > $outdir/ls.$i
	ls -l $homedir >> $outdir/ls.$i
	echo "======== $date ========" > $outdir/vmstat.$i
	vmstat >> $outdir/vmstat.$i
	iostat -d -m -t /dev/md0 >> $outdir/iostat.$i
	#
	# These generate large data files.  Comment them out if you're going
	# to run frequently or a long time, and adjust waittime above.
	#
	# To view the perf data use: perf report -i <perfdata.#>
	#
        sudo perf record -a -g -s -o $outdir/perfdata.$i sleep $perfsleep
        sudo chown sue $outdir/perfdata.$i
	sleep $waittime
	i=`tail -1 $monitorfile | awk 'BEGIN {FS=","}{last=$2}END{print last}'`
done
