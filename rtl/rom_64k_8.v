/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module rom_64k_8(
	input  wire        clock_i,
	input  wire [15:0] address_i,
	input  wire        write_enable_i,
	input  wire [ 7:0] data_i,
	output wire [ 7:0] data_o
);

wire bank = address_i[15];
wire [13:0] sp_address = address_i[14:1];
wire data_lane = address_i[0];

`ifdef SIM
`define SIM_OR_ECP5
`endif

`ifdef ECP5
`define SIM_OR_ECP5
`endif

`ifdef SIM_OR_ECP5
/*
reg [7:0] mem[0:65535];
initial
	$readmemh(HEX_FILE, mem);

reg [7:0] data_o;

always @(posedge clock_i) begin
	data_o <= mem[address_i];
end
*/

reg [15:0] mem[0:32767];
initial
	$readmemh("build/rom.hex", mem);

reg [15:0] mem_o;

always @(posedge clock_i) begin
	mem_o <= mem[{ bank, sp_address }];
end

assign data_o = data_lane ? mem_o[15:8] : mem_o[7:0];

`endif

`ifdef ICE40
wire [15:0] sp_datain = { data_i, data_i };
wire sp_clock = clock_i;
wire sp_wren = write_enable_i;

wire [3:0] sp_maskwren = data_lane ? 4'b1100 : 4'b0011;

wire [1:0] sp_cs = { (bank == 1'b1), (bank == 1'b0) };

wire [15:0] sp_dataout[0:1];
wire [15:0] sp_dataout_bank = bank ? sp_dataout[1] : sp_dataout[0];

// NOTE: Bad nomenclature, apparently POWEROFF=1'b1 is power *on*!

(* keep="true" *)
(* BEL="X25/Y0/spram_3" *)
SB_SPRAM256KA mem_0(
	.DATAIN(sp_datain),
	.ADDRESS(sp_address),
	.MASKWREN(sp_maskwren),
	.WREN(sp_wren),
	.CHIPSELECT(sp_cs[0]),
	.CLOCK(sp_clock),
	.STANDBY(1'b0),
	.SLEEP(1'b0),
	.POWEROFF(1'b1),
	.DATAOUT(sp_dataout[0])
);

(* keep="true" *)
(* BEL="X25/Y0/spram_4" *)
SB_SPRAM256KA mem_1(
	.DATAIN(sp_datain),
	.ADDRESS(sp_address),
	.MASKWREN(sp_maskwren),
	.WREN(sp_wren),
	.CHIPSELECT(sp_cs[1]),
	.CLOCK(sp_clock),
	.STANDBY(1'b0),
	.SLEEP(1'b0),
	.POWEROFF(1'b1),
	.DATAOUT(sp_dataout[1])
);

assign data_o = data_lane ? sp_dataout_bank[15:8] : sp_dataout_bank[7:0];

`endif

endmodule
