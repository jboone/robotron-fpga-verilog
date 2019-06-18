/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module ram_palette(
	input  wire        clk,
	input  wire        we,
	input  wire [ 3:0] addr_wr,
	input  wire [ 3:0] addr_rd,
	input  wire        en_rd,
	input  wire [ 7:0] data_in,
	output reg  [ 7:0] data_out
);

reg [7:0] mem[0:15];

integer i;
initial
	for (i=0; i<16; i=i+1)
		mem[i] = 8'h00;

always @(posedge clk) begin
	if(we)
		mem[addr_wr] <= data_in;

	if(en_rd)
		data_out <= mem[addr_rd];
end

endmodule
