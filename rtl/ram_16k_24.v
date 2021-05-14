/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module ram_16k_24(
	input  wire        clk,
	input  wire [13:0] addr,
	input  wire [ 5:0] we,
	input  wire [23:0] data_in,
	output wire [23:0] data_out
);


reg [3:0] mem_0[0:16383];
reg [3:0] mem_1[0:16383];
reg [3:0] mem_2[0:16383];
reg [3:0] mem_3[0:16383];
reg [3:0] mem_4[0:16383];
reg [3:0] mem_5[0:16383];

wire [23:0] mem_i = data_in;

reg [23:0] mem_o;

always @(posedge clk) begin
	mem_o <= { mem_5[addr], mem_4[addr], mem_3[addr], mem_2[addr], mem_1[addr], mem_0[addr] };
	
	if(we[5]) mem_5[addr] <= mem_i[23:20];
	if(we[4]) mem_4[addr] <= mem_i[19:16];
	if(we[3]) mem_3[addr] <= mem_i[15:12];
	if(we[2]) mem_2[addr] <= mem_i[11: 8];
	if(we[1]) mem_1[addr] <= mem_i[ 7: 4];
	if(we[0]) mem_0[addr] <= mem_i[ 3: 0];
end

assign data_out = mem_o;

endmodule
