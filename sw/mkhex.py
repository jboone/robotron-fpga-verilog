#!/usr/bin/env python3

# Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.

import sys
import os.path

import numpy

data = numpy.fromfile(sys.argv[1], dtype=numpy.uint8)
if len(data) != 65536:
	raise RuntimeError('Incorrect data length: %d' % len(data))

data = numpy.reshape(data, (len(data) // 2, 2))
s = ''.join(['%02x%02x\n' % (l, h) for h, l in data])
with open(sys.argv[2], 'w') as f:
	f.write(s)
