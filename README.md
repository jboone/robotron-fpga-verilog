# Robotron FPGA (Verilog)

Classic 1980s arcade video game implemented in an FPGA using Verilog, using
some [custom video](hw/ecp5_analog_video), [sound](hw/ecp5_dac8), and controls interfacing hardware.

## Status

This project is stable. It has served the [Church of Robotron](https://churchofrobotron.com/) well during the [2019 Crowd Supply Teardown conference](https://www.crowdsupply.com/teardown/portland-2019) and the [2019 Portland Mini Maker Faire](https://omsi.edu/calendar/portland-mini-maker-faire-2019).

## Requirements

* Lattice [LFE5UM5G-85F-EVN FPGA evaluation board](https://www.latticesemi.com/products/developmentboardsandkits/ecp5evaluationboard): This is an economical way to get the largest ECP5 FPGA Lattice makes.
* Williams [Robotron: 2084 ROM binary files](https://duckduckgo.com/?q=robotron+2084+rom&t=hc&va=u&ia=web): These files are often used with MAME, the arcade emulator. CPU board ROM files are named "robotron.sb?", where "?" is "1" through "9" and "a" through "c". The sound board ROM file is named "robotron.snd". You'll also want a "nvram" file containing the desired contents of the game's 1K x 4 nonvolatile RAM.
* [Python](https://www.python.org/) 3.7 or newer: Used to transform ROM and PROM files into HEX files for inclusion in the FPGA bitstream.
* [Yosys](https://github.com/YosysHQ/yosys), [nextpnr](https://github.com/YosysHQ/nextpnr), [prjtrellis](https://github.com/YosysHQ/prjtrellis): Open-source FPGA toolchain required to produce a bitstream for the FPGA. If you don't want to build these from source code, give the [fpga-toolchain](https://github.com/YosysHQ/fpga-toolchain) releases a try. It's important to run recent versions of these tools, as they're advancing rapidly.
* [GHDL](https://github.com/ghdl/ghdl) and [GHDL-Yosys Plugin](https://github.com/ghdl/ghdl-yosys-plugin): These are required to build the [CPU68 6800/6801 VHDL core](rtl/cpu68.vhd), which is the processor in the sound board.
* [OpenOCD](http://openocd.org/): Required to program the development board over a USB cable.

## Notes

Once you have obtained ROM files, you need to put them in the `data/rom` directory. There are `MD5SUMS` and `SHA256SUMS` files in there that you can use to check the hashes for the ROMs you've obtained, to ensure they're the same ones I used. You can do this with either the `md5sum` or `sha256sum` programs, which are commonly pre-installed on UNIX/Linux-based computers:

```bash
$ cd data/rom
$ md5sum -c MD5SUMS
# Should report "OK" for all files listed in the MD5SUMS file.
$ sha256sum -c SHA256SUMS
# Should report "OK" for all files listed in the SHA256SUMS file.
```

To permit OpenOCD to program the ECP5 development board over USB, I had to create a `udev` rule on my Linux computer, as follows:

```bash
$ sudo vi /etc/udev/rules.d/53-lattice-ftdi.rules
# Add this to the file:
ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0660", GROUP="plugdev", TAG+="uaccess"
# And save and quit the editor.
# Then ask udev to re-read the rules.
$ sudo udevadm control --reload-rules && sudo udevadm trigger
# (Detach and) attach the development board USB cable.
```

## Project Hardware

This project includes two custom circuit boards which attach to the Lattice ECP5 development board. Both were made with [KiCAD 5](https://www.kicad.org/). Both are four-layer boards. The bill of materials is contained within the schematic, and can be exported from there. If you're located in North America, consider using the [OSH Park](https://oshpark.com/) four-layer service to fabricate your boards.

### [Analog Video Board](hw/ecp5_analog_video)

The analog video board takes DAC, synchronization, and configuration signals from the ECP5 FPGA and outputs composite video, S-video (separate chroma and luma), and VGA-style RGB.

To use the analog video board, the Lattice ECP5 development board needs a slight configuration change. The FPGA's VCCIO1 voltage supply changed from 2.5V to 3.3V, which involves removing resistor R100 and adding a 0 Ohm resistor as R105. Both resistors are located next to each other, in the very center of the bottom of the board. They appear to be "0603" resistors, which are thankfully manageable to solder for somebody experienced in surface-mount soldering, without fancy tools or a microscope.

### [Analog Audio DAC Board](hw/ecp5_dac8)

The analog audio DAC board takes audio sample data from the ECP5 FPGA and outputs an analog signal.

## Development Board Configuration

Before connecting any of the hardware in this project, please ensure the Lattice ECP5 development board is configured as shown in the following tables.

### Jumpers

| Jumper | State      | Function if Installed                                        |
|--------|------------|-------------------------------------------------------------|
| JP1    | Removed    | Holds FTDI FT2232H in reset (also stops 12MHz clock output?) |
| JP2    | Installed  | Supplies 12MHz from FTDI FT2232H to FPGA                     |
| JP3    | Removed    | Applies +12V to Arduino header pin J7.8                      |
| JP4    | Removed    | Applies +5V to Arduino header pin J7.5                       |
| JP5    | Removed    | Applies +3.3V to Arduino header pin J7.4                     |
| JP6    | Removed    | Applies +3.3V to Raspberry Pi header pins JP8.1 and JP8.17   |
| JP7    | Removed    | Applies +5V to Raspberry Pi header pins JP8.2 and JP8.4      |
| JP9    | Removed    | Disables 200MHz LVDS crystal oscillator                      |
| JP10   | Pins 1,2   | Sets VCCIO0 to +3.3V                                         |
| JP11   | Pins 1,2   | Sets VCCIO7 to +3.3V                                         |
| JP18   | Installed  | Connects 128Mb SPI flash CS# to FPGA CSSPIN                  |

### DIP Switch SW1

| Switch   | Position |
|----------|----------|
| TP       | ON       |
| CONFIG 0 | ON       |
| CONFIG 1 | OFF      |
| CONFIG 2 | ON       |

## Reference Material

These documents served me well during development of this project.

* [Sean Riddle](http://seanriddle.com/) - Williams arcade machine information,
  including Robotron: 2084.

    * [Hardware overview](http://seanriddle.com/willhard.html)
    * [Memory map](http://seanriddle.com/memmap.gif)
    * [Processor and video timing](http://seanriddle.com/timing.html)
    * [BLTter description and test code](http://seanriddle.com/blittest.html)

* [Robotron-2084](http://www.robotron-2084.co.uk/) - Williams arcade machine
official documentation.

    * [Robotron schematics and instruction manuals](http://www.robotron-2084.co.uk/manualsrobotron.html)
    * [Defender "later series" theory of operation](http://www.robotron-2084.co.uk/manualsdefender.html),
      interesting because the Robotron and Defender hardware is quite
      similar.

* Documentation for various ICs in the original Robotron: 2084 machine.

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

The open-source license for this project is yet to be determined. Stay tuned.

## Contributing

Contributions are welcome!

Please respect Williams Electronics' copyright and do not post any files built
with or containing their ROM code.

## Contact

Jared Boone <jared@sharebrained.com>

[ShareBrained Technology, Inc.](http://www.sharebrained.com/)

The latest version of this repository can be found at https://github.com/jboone/robotron-fpga-verilog