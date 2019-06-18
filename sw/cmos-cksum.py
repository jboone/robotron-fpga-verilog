#!/usr/bin/env python3

# Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.

import numpy

d = numpy.fromfile('data/nvram', dtype=numpy.uint8)
d &= 0xf

calculated = sum(d[0x000:0x024]) + 0x37
print('calculated: %02x' % calculated)

expected = (d[0x8c] << 4) | d[0x8d]
print('expected:   %02x' % expected)
