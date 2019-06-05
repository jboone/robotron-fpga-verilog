# Robotron FPGA (Verilog)

Classic 1980s arcade video game implemented in an FPGA using Verilog, using
some custom video, sound, and controls interfacing hardware.

## Status
[status]: #status

This project is under active and urgent development.

## Requirements
[requirements]: #requirements

* Lattice LFE5UM5G-85F-EVN FPGA development board:

    This is an economical way to get the largest ECP5 FPGA Lattice makes.

* Williams Robotron: 2084 ROM binary files:

    These files are often used with MAME, the arcade emulator. CPU board
    ROM files are named "robotron.sb?", where "?" is "1" through "9" and
    "a" through "c". The sound board ROM file is named "robotron.snd".
    You'll also want a "nvram" file containing the desired contents of
    the game's 1K x 4 nonvolatile RAM.

* Python 3.7:

    Used to transform ROM and PROM files into HEX files for inclusion in
    the FPGA bitstream.

* Yosys, NextPNR, PrjTrellis:

	Open-source FPGA toolchain required to produce a bitstream for the
	FPGA. I recommend using [summon-fpga-tools](https://github.com/esden/summon-fpga-tools)
	to build the toolchain from scratch, as ECP5 support is very new and is improving
	rapidly.

## Reference Material
[reference]: #reference

These documents served me well during development of this project.

[Sean Riddle](http://seanriddle.com/) - Williams arcade machine information,
including Robotron: 2084.

* [Hardware overview](http://seanriddle.com/willhard.html)
* [Memory map](http://seanriddle.com/memmap.gif)
* [Processor and video timing](http://seanriddle.com/timing.html)
* [BLTter description and test code](http://seanriddle.com/blittest.html)

[Robotron-2084](http://www.robotron-2084.co.uk/) - Williams arcade machine
official documentation.

* [Robotron schematics and instruction manuals](http://www.robotron-2084.co.uk/manualsrobotron.html)
* [Defender "later series" theory of operation](http://www.robotron-2084.co.uk/manualsdefender.html),
    interesting because the Robotron and Defender hardware is quite
    similar.
    
Documentation for various ICs in the original Robotron: 2084 machine.

* [MC6809E microprocessor datasheet](http://www.classiccmp.org/dunfield/r/6809e.pdf)
* [MC6809E microprocessor programming manual](http://www.classiccmp.org/dunfield/r/6809prog.pdf)
* [DM9316 Synchronous 4-Bit Binary Counter](http://www.ti.com/product/dm9316)
* National Semiconductor(?) DM7489 64-bit random access read/write memory
    (no good reference)
* [Harris HM-7641 512 x 8 PROM](http://www.bitsavers.org/pdf/harris/_dataBooks/1978_Harris_Memory_Vol1.pdf) (page 2-35)
* [Harris HM-6514 1024 x 4 CMOS RAM](http://www.bitsavers.org/pdf/harris/_dataBooks/1978_Harris_Memory_Vol1.pdf) (page 3-49)
* [Mostek MK4116 16,384 x 1 bit dynamic RAM](http://hardware.speccy.org/datasheet/MK4116.pdf)
* [Signetics 8T97 hex buffer](http://www.bitsavers.org/pdf/signetics/_dataBooks/1977_Bipolar_Microprocessor.pdf) (page 96)
* [Various 74-series logic ICs](http://www.ti.com/lsds/ti/logic/home_overview.page)

## License
[license]: #license

The open-source license for this project is yet to be determined. Stay tuned.

## Contributing
[contributing]: #contributing

Contributions are welcome!

Please respect Williams Electronics' copyright and do not post any files built
with or containing their ROM code.

## Contact
[contact]: #contact

Jared Boone <jared@sharebrained.com>

ShareBrained Technology, Inc.

<http://www.sharebrained.com/>

The latest version of this repository can be found at
https://github.com/jboone/robotron-fpga-verilog
