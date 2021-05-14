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

reg [15:0] mem[0:32767];
initial
	$readmemh("build/rom.hex", mem);

reg [15:0] mem_o;

always @(posedge clock_i) begin
	mem_o <= mem[{ bank, sp_address }];
end

assign data_o = data_lane ? mem_o[15:8] : mem_o[7:0];

endmodule
