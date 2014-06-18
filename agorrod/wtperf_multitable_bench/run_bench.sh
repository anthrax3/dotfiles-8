#!/bin/bash

# General usage is:
# ./run_bench.sh multi-btree-db.wtperf 5db_1tbl_50g_40thrd_stat

mkdir -p WT_TEST
rm -rf ./WT_TEST

if [ $# != 2 ]; then
	echo "Usage $0 wtperf_config result_dir_name"
	exit 1
fi

CONFIG="../bench/wtperf/runners/$1"

if [ ! -e $CONFIG -o -e "results/$2" ]; then
	echo "Usage $0 wtperf_config result_dir_name"
	exit 1
fi

LD_PRELOAD=/usr/lib64/libjemalloc.so.1 ./bench/wtperf/wtperf -O ../bench/wtperf/runners/$1

sh ./save_output.sh $2

