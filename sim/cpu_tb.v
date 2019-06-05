/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module cpu_tb;

	reg rst = 1;
	reg clk_12m = 0;

	initial begin
		$dumpfile("cpu_tb.vcd");
		$dumpvars(0, dut);	
	end

	initial begin
		#200 rst <= 0;
		#2000000 $finish;
	end

	always #41.667 clk_12m = !clk_12m;

	cpu dut(
		.rst(rst),
		.clk_12m(clk_12m),
		.rom_write_addr(16'h0000),
		.rom_write_data(8'h00),
		.rom_write_en(1'b0)
	);

endmodule
