#!/bin/bash

if [ "x$1" == "x" ]; then
	echo "Usage $0 dest"
	exit 1
fi

DEST="./results/$1"
SOURCE="WT_TEST"
TMP=__t

if [ -e $DEST ]; then
	echo "Error specified dest directory $DEST already exists"
	exit 1
fi

mkdir -p $DEST

if [ -d "$SOURCE/D00" ]; then
	python merge_wtperf_files.py $SOURCE $DEST/test.stat
	#grep "Executed " $SOURCE/D??/test.stat > $TMP
	#readops=`grep "read op" $TMP | cut -d ' ' -f 2 | paste -sd+ | bc`
	#insertops=`grep "insert op" $TMP | cut -d ' ' -f 2 | paste -sd+ | bc`

	#echo "total reads: $readops" >> $DEST/test.stat
	#echo "total inserts: $insertops" >> $DEST/test.stat

	for i in `ls $SOURCE` ; do
		cp $SOURCE/$i/test.stat $DEST/test$i.stat
		for f in `ls $SOURCE/$i/WiredTigerStat*`; do
			cat $f >> $DEST/WiredTigerStat.$i
		done
	done

	cp ../bench/wtperf/runners/multi-btree-db.wtperf $DEST/config
else
	cp $SOURCE/test.stat $DEST/test.stat
	for f in `ls $SOURCE/WiredTigerStat*`; do
		cat $f >> $DEST/WiredTigerStat
	done
	cp ../bench/wtperf/runners/multi-btree-table.wtperf $DEST/config
fi

dbsize=`du -sh $SOURCE`
echo "$dbsize" >> $DEST/info

rm -f $TMP
