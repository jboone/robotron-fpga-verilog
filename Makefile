# Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.

TRELLIS=~/sft/share/trellis

PROJ_RTL_SRCS := $(addprefix rtl/, \
	address_decode_mpu.v \
	clock_generator.v \
	cpu.v \
	events.v \
	fifo_sync_ram.v \
	mc6809i.v \
	mux_74154.v \
	pia_6821.v \
	ram_16k_24.v \
	ram_cmos.v \
	ram_palette.v \
	ram_sdp.v \
	rom_64k_8.v \
	rom_decoder_4.v \
	rom_decoder_6.v \
	top.v \
	uart_tx.v \
	video_counter.v \
	video_output.v \
	williams_sc1.v \
)

all: build/robotron.bit

build/cmos.hex: sw/mkcmos.py data/nvram
	mkdir build
	sw/mkcmos.py data/nvram > $@

build/decoder_4.hex: sw/mkdecoder.py data/rom/decoder.4
	sw/mkdecoder.py data/rom/decoder.4 > $@

build/decoder_6.hex: sw/mkdecoder.py data/rom/decoder.6
	sw/mkdecoder.py data/rom/decoder.6 > $@

build/rom.hex: sw/mkrom.py data/rom/robotron.sb?
	sw/mkrom.py --block-size 4096 --word-width 16 --output-binary build/rom.bin --output-verilog build/rom.hex data/rom/robotron.sb[1-9] none none none none data/rom/robotron.sb[a-c]

build/rom_snd.hex: sw/mkrom.py data/rom/robotron.snd
	sw/mkrom.py --block-size 4096 --word-width 8 --output-binary build/rom_snd.bin --output-verilog build/rom_snd.hex data/rom/robotron.snd

#######################################################################

build/robotron.json: ${PROJ_RTL_SRCS} build/cmos.hex build/decoder_4.hex build/decoder_6.hex build/rom.hex
	yosys -D ECP5 -p "synth_ecp5 -top top -json $@" ${PROJ_RTL_SRCS}

build/robotron_out.config: build/robotron.json data/pre-pack.py
	nextpnr-ecp5 --json $< --textcfg $@ --um5g-85k --package CABGA381 --lpf data/ecp5evn.lpf --pre-pack data/pre-pack.py

build/robotron.bit: build/robotron_out.config
	ecppack --svf build/robotron.svf $< $@

build/robotron.svf : build/robotron.bit

prog: build/robotron.svf
	openocd -f ${TRELLIS}/misc/openocd/ecp5-evn.cfg -c "transport select jtag; init; svf $<; exit"

clean:
	rm -rf build/

.PHONY: prog clean
