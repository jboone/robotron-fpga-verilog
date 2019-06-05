/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module clock_generator(
	input rst,
	input clk,
	output reg en_6m,
	output reg en_4m,
	output reg en_q,
	output reg en_e,
	output reg en_q_n,
	output reg en_e_n,
	output [11:0] phase_e
);

reg [11:0] phase;

always @(posedge clk) begin
	if(rst) begin
		phase <= 12'b0000_0000_1000;
	end else begin
		phase <= { phase[10:0], phase[11] };
		en_6m <= phase[1] || phase[3] || phase[5] || phase[7] || phase[9] || phase[11];
		en_4m <= phase[0] || phase[3] || phase[6] || phase[9];

		en_q <= phase[0];
		en_e <= phase[3];
		en_q_n <= phase[6];
		en_e_n <= phase[9];
	end
end

assign phase_e = { phase[10:0], phase[11] };

endmodule
