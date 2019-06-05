#!/usr/bin/env python3

# Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.

import sys
import numpy

l = []
data = numpy.fromfile(sys.argv[1], dtype=numpy.uint8)
for w in data:
	l.append('%02x' % w)
s = '\n'.join(l)
print(s)
