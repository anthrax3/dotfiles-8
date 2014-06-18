#!/usr/bin/env python

import os, re, sys

if len(sys.argv) != 3:
	print 'Usage: ' + sys.argv[0] + ' source dest'
	sys.exit(1)

SOURCE = sys.argv[1]
DEST = sys.argv[2]

line_re = re.compile(r'(?P<reads>[0-9]*) reads, (?P<inserts>[0-9]*) inserts, (?P<updates>[0-9]*) updates, (?P<checkpoints>[0-9]*) checkpoints in [0-9]* secs \((?P<secs>[0-9]*) total secs\)')
summary_re = re.compile(r'Executed (?P<count>[0-9]*) (?P<type>\w*) operations \([0-9]*%\) (?P<rate>[0-9]*) ops/sec')
summary_norate_re = re.compile(r'Executed (?P<count>[0-9]*) (?P<type>\w*) operations')

time_dict = { }
summary_dict = { }

for filename in os.listdir(SOURCE):
	for line in open(os.path.join(SOURCE, filename, 'test.stat')):
		values = summary_re.match(line)
		if values != None:
			value = summary_dict.get(values.group('type'), [0, 0])
			value[0] += int(values.group('count'))
			value[1] += int(values.group('rate'))
			summary_dict[values.group('type')] = value
			continue
		values = summary_norate_re.match(line)
		if values != None:
			value = summary_dict.get(values.group('type'), [0, 0])
			value[0] += int(values.group('count'))
			summary_dict[values.group('type')] = value
			continue
		values = line_re.match(line)
		if values == None:
			continue
		value = time_dict.get(int(values.group('secs')), [ 0, 0, 0, 0 ])
		value[0] += int(values.group('reads'))
		value[1] += int(values.group('inserts'))
		value[2] += int(values.group('updates'))
		value[3] += int(values.group('checkpoints'))
		time_dict[int(values.group('secs'))] = value

outfile = open(DEST, 'w+')

for key in sorted(time_dict.iterkeys()):
	value = time_dict[key]
	outfile.write('{reads} reads, {inserts} inserts, {updates} updates, {checkpoints} checkpoints in 20 secs ({secs} total secs)\n'.format(
	    reads=value[0], inserts=value[1],
	    updates=value[2], checkpoints=value[3], secs=key))

for key in summary_dict:
	value = summary_dict[key]
	outfile.write('Executed {count} {optype} operations (XX%) {rate} ops/sec\n'.format(
	    count=value[0], optype=key, rate=value[1]))

outfile.close()
