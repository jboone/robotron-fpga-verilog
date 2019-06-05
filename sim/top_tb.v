/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module top_tb;

	reg clk_12m = 0;

	initial begin
		$dumpfile("top_tb.vcd");
		$dumpvars(0, dut);	
	end

	initial begin
		#150000000 $finish;
	end

	always #41.667 clk_12m = !clk_12m;

	top dut(
		.clk_osc_12m(clk_12m)
	);

endmodule
