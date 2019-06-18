/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module m6810(
	input  wire        clk,
	input  wire        rst,
	input  wire [ 6:0] address,
	input  wire        cs,
	input  wire        rw,
	input  wire [ 7:0] data_in,
	output reg  [ 7:0] data_out
);

wire we = !rw;

reg [7:0] mem[0:127];

always @(posedge clk) begin
	if(cs && we)
		mem[address] <= data_in;
	
	data_out <= mem[address];
end
	
endmodule
