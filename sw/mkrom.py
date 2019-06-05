#!/usr/bin/env python3

# Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.

import sys
import os.path

import numpy

width = 16

files = (
	'robotron.sb1',
	'robotron.sb2',
	'robotron.sb3',
	'robotron.sb4',
	'robotron.sb5',
	'robotron.sb6',
	'robotron.sb7',
	'robotron.sb8',
	'robotron.sb9',
	None,
	None,
	None,
	None,
	'robotron.sba',
	'robotron.sbb',
	'robotron.sbc',
)

data = []
for file in files:
	if file is None:
		data.append(numpy.zeros((4096,), dtype=numpy.uint8))
	else:
		path = os.path.join(sys.argv[1], file)
		data.append(numpy.fromfile(path, dtype=numpy.uint8))

data = numpy.concatenate(data)
data.tofile(sys.argv[2])

if width == 16:
	data = numpy.reshape(data, (len(data) // 2, 2))
	s = ''.join(['%02x%02x\n' % (l, h) for h, l in data])
elif width == 8:
	s = ''.join(['%02x\n' % v for v in data])

with open(sys.argv[3], 'w') as f:
	f.write(s)
