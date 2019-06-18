/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module ram_cmos(
	input  wire        clk,
	input  wire        cs,
	input  wire        we,
	input  wire [ 9:0] addr,
	input  wire [ 3:0] data_in,
	output reg  [ 3:0] data_out
);

reg [3:0] mem[0:1023];

integer i;
initial
	$readmemh("build/cmos.hex", mem);

always @(posedge clk) begin
	if(cs && we)
		mem[addr] <= data_in;

	if(cs && !we)
		data_out <= mem[addr];
end

endmodule
