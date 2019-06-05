/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module video_output(
	input        rst,
	input        clk,
	input        screen_control,
	input [23:0] data_in,
	input        data_in_en,
	output [3:0] data_out,
	input        data_out_en
);

reg [3:0] shifter_sc0_5;
reg [3:0] shifter_sc0_4;
reg [3:0] shifter_sc0_3;
reg [3:0] shifter_sc0_2;
reg [3:0] shifter_sc0_1;
reg [3:0] shifter_sc0_0;

always @(posedge clk) begin
	if(rst) begin
		shifter_sc0_5 <= 0;
		shifter_sc0_4 <= 0;
		shifter_sc0_3 <= 0;
		shifter_sc0_2 <= 0;
		shifter_sc0_1 <= 0;
		shifter_sc0_0 <= 0;
	end else if(data_in_en) begin
		shifter_sc0_5 <= screen_control ? data_in[23:20] : data_in[19:16];
		shifter_sc0_4 <= screen_control ? data_in[19:16] : data_in[23:20];
		shifter_sc0_3 <= screen_control ? data_in[15:12] : data_in[11: 8];
		shifter_sc0_2 <= screen_control ? data_in[11: 8] : data_in[15:12];
		shifter_sc0_1 <= screen_control ? data_in[ 7: 4] : data_in[ 3: 0];
		shifter_sc0_0 <= screen_control ? data_in[ 3: 0] : data_in[ 7: 4];
	end else if(data_out_en) begin
		shifter_sc0_5 <= 4'h0;
		shifter_sc0_4 <= shifter_sc0_5;
		shifter_sc0_3 <= shifter_sc0_4;
		shifter_sc0_2 <= shifter_sc0_3;
		shifter_sc0_1 <= shifter_sc0_2;
		shifter_sc0_0 <= shifter_sc0_1;
	end
end

assign data_out = shifter_sc0_0;

endmodule
