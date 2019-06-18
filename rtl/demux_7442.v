/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module demux_7442(
	input  wire [ 3:0] a,
	output reg  [ 9:0] y_n
);

always @* begin
	case(a)
	4'd0:    y_n <= 10'b1111111110;
	4'd1:    y_n <= 10'b1111111101;
	4'd2:    y_n <= 10'b1111111011;
	4'd3:    y_n <= 10'b1111110111;
	4'd4:    y_n <= 10'b1111101111;
	4'd5:    y_n <= 10'b1111011111;
	4'd6:    y_n <= 10'b1110111111;
	4'd7:    y_n <= 10'b1101111111;
	4'd8:    y_n <= 10'b1011111111;
	4'd9:    y_n <= 10'b0111111111;
	default: y_n <= 10'b1111111111;
	endcase
end

endmodule
