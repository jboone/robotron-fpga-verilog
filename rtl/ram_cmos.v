/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module ram_cmos(
	input        clk,
	input        cs,
	input        we,
	input  [9:0] addr,
	input  [3:0] data_in,
	output [3:0] data_out
);

reg [3:0] mem[0:1023];

integer i;
initial
	$readmemh("build/cmos.hex", mem);

reg [3:0] data_out;
always @(posedge clk) begin
	if(cs && we)
		mem[addr] <= data_in;

	if(cs && !we)
		data_out <= mem[addr];
end

endmodule
