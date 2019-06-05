/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module mux_74154(
	input  [ 3:0] a,
	input  [ 1:0] g_n,
	output [15:0] y_n
);

wire g0 = !g_n[0];
wire g1 = !g_n[1];

assign y_n[ 0] = !((a == 4'h0) && g0 && g1);
assign y_n[ 1] = !((a == 4'h1) && g0 && g1);
assign y_n[ 2] = !((a == 4'h2) && g0 && g1);
assign y_n[ 3] = !((a == 4'h3) && g0 && g1);
assign y_n[ 4] = !((a == 4'h4) && g0 && g1);
assign y_n[ 5] = !((a == 4'h5) && g0 && g1);
assign y_n[ 6] = !((a == 4'h6) && g0 && g1);
assign y_n[ 7] = !((a == 4'h7) && g0 && g1);
assign y_n[ 8] = !((a == 4'h8) && g0 && g1);
assign y_n[ 9] = !((a == 4'h9) && g0 && g1);
assign y_n[10] = !((a == 4'hA) && g0 && g1);
assign y_n[11] = !((a == 4'hB) && g0 && g1);
assign y_n[12] = !((a == 4'hC) && g0 && g1);
assign y_n[13] = !((a == 4'hD) && g0 && g1);
assign y_n[14] = !((a == 4'hE) && g0 && g1);
assign y_n[15] = !((a == 4'hF) && g0 && g1);

endmodule
