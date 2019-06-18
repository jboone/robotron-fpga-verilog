/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module uart_tx
#(
	parameter integer BDIV = 103
)
(
	input  wire       rst,
	input  wire       clk,
	output wire       ready,
	input  wire [7:0] data_in,
	input  wire       write,
	output wire       data_out
);

///////////////////////////////////////////////////////////////////////
// Baud rate generator

reg  [7:0] baud_div = 8'd0;
wire       baud_div_match = (baud_div == BDIV);
wire [7:0] baud_div_next = baud_div_match ? 8'd0 : (baud_div + 8'd1);

reg        shift_en = 1'b0;

///////////////////////////////////////////////////////////////////////
// Data shift register

reg  [10:0] shifter;
reg  [10:0] shifter_valid;

always @(posedge clk) begin
	if(rst) begin
		baud_div <= 8'd0;
		shift_en <= 1'b0;

		shifter <= 11'b111_1111_1111;
		shifter_valid <= 11'b000_0000_0000;
	end else if(ready && write) begin
		baud_div <= 8'd0;
		shift_en <= 1'b0;

		shifter       <= { 2'b11, data_in,      1'b0 };
		shifter_valid <= { 2'b11, 8'b1111_1111, 1'b1 };
	end else begin
		baud_div <= baud_div_next;
		shift_en <= baud_div_match;

		if(shift_en) begin
			shifter       <= { 1'b1,       shifter[10:1] };
			shifter_valid <= { 1'b0, shifter_valid[10:1] };
		end
	end
end

assign data_out = shifter[0];
assign ready = !shifter_valid[0];

endmodule