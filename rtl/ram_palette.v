/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module ram_palette(
	input        clk,
	input        we,
	input  [3:0] addr_wr,
	input  [3:0] addr_rd,
	input  [7:0] data_in,
	output [7:0] data_out
);

reg [7:0] mem[0:15];

integer i;
initial
	for (i=0; i<16; i=i+1)
		mem[i] = 8'h00;

reg [7:0] data_out;
always @(posedge clk) begin
	if(we)
		mem[addr_wr] <= data_in;

	data_out <= mem[addr_rd];
end

endmodule
