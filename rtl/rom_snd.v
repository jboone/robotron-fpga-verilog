/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module rom_snd(
	input  wire        clock_i,
	input  wire [11:0] address_i,
	output wire [ 7:0] data_o
);

reg [7:0] mem[0:4095];
initial
	$readmemh("build/rom_snd.hex", mem);

reg [7:0] mem_o;

always @(posedge clock_i) begin
	mem_o <= mem[address_i];
end

assign data_o = mem_o[7:0];

endmodule
