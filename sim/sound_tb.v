/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module sound_tb;

	reg rst = 1;
	reg clk = 0;

	always #500 clk = !clk;

	wire       dac_en;
	wire [7:0] dac_value;
	
	sound dut(
		.rst(rst),
		.clk_4e(clk),
		.diagnostic(1'b1),
		.pb(6'b000000),
		.hand(1'b0),
		.dac_en(dac_en),
		.dac_value(dac_value)
	);

	initial begin
		$dumpfile("sound_tb.vcd");
		$dumpvars(0, dut);	
	end

	initial begin
		#5000 rst <= 0;
	end

endmodule
