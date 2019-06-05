#!/usr/bin/env python3

# Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.

width = 53 * 6
height = 240

cmds = (
	# Reset Low, wait 10ms
	('io', 0b10000011, 10),

	# Reset High, wait 120ms
	('io', 0b10000000, 120),

	# LCDs are configured for IM[2:0] = 001
	# 8080-I system, 16-bit parallel bus

	#
	# 0x3a: DBI[2:0] = 101
	# MDT[1:0] = XX (if not in 18-bit mode, right?)

	# Power control B
	# 0
	# PCEQ=1, DRV_ena=0, Power control=3
	('lcd', (0xCF, (0x00, 0xD9, 0x30))),

	# Power on sequence control
	('lcd', (0xED, (0x64, 0x03, 0x12, 0x81))),

	# Driver timing control A
	('lcd', (0xE8, (0x85, 0x10, 0x78))),

	# Power control A
	('lcd', (0xCB, (0x39, 0x2C, 0x00, 0x34, 0x02))),

	# Pump ratio control
	('lcd', (0xF7, (0x20,))),

	# Driver timing control B
	('lcd', (0xEA, (0x00, 0x00))),

	('lcd', (0xB1, (0x00, 0x1B))),

	# Blanking Porch Control
	# VFP = 0b0000010 = 2 (number of HSYNC of vertical front porch)
	# VBP = 0b0000010 = 2 (number of HSYNC of vertical back porch)
	# HFP = 0b0001010 = 10 (number of DOTCLOCK of horizontal front porch)
	# HBP = 0b0010100 = 20 (number of DOTCLOCK of horizontal back porch)
	('lcd', (0xB5, (0x02, 0x02, 0x0a, 0x14))),

	# Display Function Control
	# PT[1:0] = 0b10
	# PTG[1:0] = 0b10
	# ISC[3:0] = 0b0010 (scan cycle interval of gate driver: 5 frames)
	# SM = 0 (gate driver pin arrangement in combination with GS)
	# SS = 1 (source output scan direction S720 -> S1)
	# GS = 0 (gate output scan direction G1 -> G320)
	# REV = 1 (normally white)
	# NL = 0b100111 (default)
	# PCDIV = 0b000000 (default?)
	('lcd', (0xB6, (0x0A, 0xA2, 0x27, 0x00))),

	# Power Control 1
	#VRH[5:0]
	('lcd', (0xC0, (0x1B,))),

	# Power Control 2
	#SAP[2:0];BT[3:0]
	('lcd', (0xC1, (0x12,))),

	# VCOM Control 1
	('lcd', (0xC5, (0x32, 0x3C))),

	# VCOM Control 2
	('lcd', (0xC7, (0x9B,))),

	# Memory Access Control
	# Invert X and Y memory access order, so upper-left of
	# screen is (0,0) when writing to display.
	('lcd', (0x36, (
		(0 << 7) |	# MY
		(1 << 6) |	# MX
		(1 << 5) |	# MV
		(1 << 4) |	# ML=1: reverse vertical refresh to simplify scrolling logic
		(1 << 3),	# BGR=1: For Kingtech LCD, BGR filter.
	))),

	# COLMOD: Pixel Format Set
	# DPI=101 (16 bits/pixel), DBI=101 (16 bits/pixel)
	('lcd', (0x3A, (0x55,))),

	#(0xF6, (0x01, 0x30)),
	# WEMODE=1 (reset column and page number on overflow)
	# MDT[1:0]
	# EPF[1:0]=00 (use channel MSB for LSB)
	# RIM=0 (If COLMOD[6:4]=101 (65k color), 16-bit RGB interface (1 transfer/pixel))
	# RM=0 (system interface/VSYNC interface)
	# DM[1:0]=00 (internal clock operation)
	# ENDIAN=0 (doesn't matter with 16-bit interface)
	('lcd', (0xF6, (0x01, 0x30, 0x00))),

	# 3Gamma Function Disable
	('lcd', (0xF2, (0x00,))),

	# Gamma curve selected
	('lcd', (0x26, (0x01,))),

	# Set Gamma
	('lcd', (0xE0, (
		0x0F, 0x1D, 0x19, 0x0E, 0x10, 0x07, 0x4C, 0x63,
		0x3F, 0x03, 0x0D, 0x00, 0x26, 0x24, 0x04
	))),

	# Set Gamma
	('lcd', (0xE1, (
		0x00, 0x1C, 0x1F, 0x02, 0x0F, 0x03, 0x35, 0x25,
		0x47, 0x04, 0x0C, 0x0B, 0x29, 0x2F, 0x05
	))),

	# lcd_sleep_out();
	# "It will be necessary to wait 120msec after sending Sleep Out
	# command (when in Sleep In Mode) before Sleep In command can be
	# sent."
	('lcd', (0x11, ()), 120),

	# lcd_display_on();
	('lcd', (0x29, ())),

	# Turn on Tearing Effect Line (TE) output signal.
	('lcd', (0x35, (0b00000000,))),

	# Set column range
	('lcd', (0x2a, (0x00, 0x00, (width-1) >> 8, (width-1) & 0xff))),

	# Set row range
	('lcd', (0x2b, (0x00, 0x00, (height-1) >> 8, (height-1) & 0xff))),

	# Start full-screen transfer.
	('lcd', (0x2c, ())),
)

words = []

for cmd in cmds:
	#print(cmd)
	t = cmd[0]
	if t == 'io':
		d, ms = cmd[1], cmd[2]
		# print('io 0x%02x %d' % (d, ms))
		b = ((ms // 10) << 11) | (0b011 << 8) | d
		words.append(b)
	if t == 'lcd':
		c, d = cmd[1]
		if len(cmd) == 3:
			ms = cmd[2]
			# print('lcd 0x%02x %s %d' % (c, d, ms))
		else:
			ms = None
			# print('lcd 0x%02x %s' % (c, d))
		b = [c]
		b.extend(d)
		b[0] |= (0b100 << 8)
		for i in range(1, len(b)):
			b[i] |= (0b101 << 8)
		if ms:
			b[-1] |= ((ms // 10) << 11)
		words.extend(b)

while len(words) < 128:
	words.append(0b0000000100000000)

for w in words:
	print('%04x' % w)
