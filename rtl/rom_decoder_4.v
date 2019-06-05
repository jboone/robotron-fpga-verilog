/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module rom_decoder_4(
	input        clock_i,
	input        clock_enable_i,
	input  [8:0] address_i,
	output [7:0] data_o
);

reg [7:0] mem[0:511];

initial
	$readmemh("build/decoder_4.hex", mem);

reg [7:0] data_o;
always @(posedge clock_i) begin
	if(clock_enable_i)
		data_o <= mem[address_i];
end

endmodule
