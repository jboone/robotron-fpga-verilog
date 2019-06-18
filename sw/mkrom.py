#!/usr/bin/env python3

# Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.

import sys
import os.path
import argparse

import numpy

parser = argparse.ArgumentParser()
parser.add_argument('files', metavar='F', type=str, nargs='+', help='ROM binary image file')
parser.add_argument('--block-size', type=int, required=True, help='Size of an individual ROM image')
parser.add_argument('--word-width', type=int, required=True, choices=[8, 16], help='Bit-width of each line in output hex file')
parser.add_argument('--output-binary', type=str, help='Output binary file')
parser.add_argument('--output-verilog', type=str, help='Output hex file for use in Verilog')
args = parser.parse_args()

width = args.word_width

files = args.files

data = []
for file in files:
	if file.lower() == 'none':
		data.append(numpy.zeros((args.block_size,), dtype=numpy.uint8))
	else:
		block_data = numpy.fromfile(file, dtype=numpy.uint8)
		assert(len(block_data) == args.block_size)
		data.append(block_data)

data = numpy.concatenate(data)
if args.output_binary:
	data.tofile(args.output_binary)

if args.output_verilog:
	if width == 16:
		data = numpy.reshape(data, (len(data) // 2, 2))
		s = ''.join(['%02x%02x\n' % (l, h) for h, l in data])
	elif width == 8:
		s = ''.join(['%02x\n' % v for v in data])

	with open(args.output_verilog, 'w') as f:
		f.write(s)
