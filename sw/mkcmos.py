#!/usr/bin/env python3

# Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.

import sys
import os.path

import numpy

data = numpy.fromfile(sys.argv[1], dtype=numpy.uint8)
if len(data) != 1024:
	raise RuntimeError('Incorrect data length: %d' % len(data))

s = '\n'.join(['%1x' % (n & 0xf) for n in data])
print(s)
