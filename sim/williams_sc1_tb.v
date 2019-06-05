/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module williams_sc1_tb;

	reg         rst = 1;
	reg         clk_12m = 0;

	reg         reg_cs = 1'b0;
	reg [ 7:0]  reg_data_in = 8'b0000_0000;
	reg [ 2:0]  rs = 3'b000;
	wire        halt;
	reg         halt_ack = 1'b0;
	reg         blt_ack = 1'b0;
	wire        blt_rd;
	wire        blt_wr;
	wire [15:0] blt_address_out;
	wire [ 7:0] blt_data_in = 8'b0000_0000;
	wire [ 7:0] blt_data_out;
	wire [ 1:0] blt_nibble_en;

	always #41.667 clk_12m = !clk_12m;

	reg [11:0] phase = 1;
	always @(posedge clk_12m) begin
		if(rst)
			phase <= 1;
		else
			phase <= { phase[10:0], phase[11] };
	end

	initial begin
		$dumpfile("williams_sc1_tb.vcd");
		$dumpvars(0, dut);	
	end

	wire en_e_n = phase[11];
	
	initial begin
		#200 rst <= 0;

		rs <= 1;
		reg_data_in <= 8'h3c;
		@(posedge clk_12m && phase[11]); reg_cs <= 1; @(posedge clk_12m); reg_cs <= 0;

		rs <= 2;
		reg_data_in <= 8'hfc;
		@(posedge clk_12m && phase[11]); reg_cs <= 1; @(posedge clk_12m); reg_cs <= 0;

		rs <= 3;
		reg_data_in <= 8'hf5;
		@(posedge clk_12m && phase[11]); reg_cs <= 1; @(posedge clk_12m); reg_cs <= 0;

		rs <= 4;
		reg_data_in <= 8'h00;
		@(posedge clk_12m && phase[11]); reg_cs <= 1; @(posedge clk_12m); reg_cs <= 0;

		rs <= 5;
		reg_data_in <= 8'h00;
		@(posedge clk_12m && phase[11]); reg_cs <= 1; @(posedge clk_12m); reg_cs <= 0;

		rs <= 6;
		reg_data_in <= 8'h14;
		@(posedge clk_12m && phase[11]); reg_cs <= 1; @(posedge clk_12m); reg_cs <= 0;

		rs <= 7;
		reg_data_in <= 8'h14;
		@(posedge clk_12m && phase[11]); reg_cs <= 1; @(posedge clk_12m); reg_cs <= 0;

		rs <= 0;
		reg_data_in <= 8'h00;
		@(posedge clk_12m && phase[11]); reg_cs <= 1; @(posedge clk_12m); reg_cs <= 0;

		@(posedge clk_12m && halt);
		halt_ack <= 1'b1;

		repeat(512) begin
			@(posedge clk_12m && phase[11]); blt_ack <= 1; @(posedge clk_12m); blt_ack <= 0;
		end

		#50000000 $finish;
	end

	williams_sc1 dut(
		.rst(rst),
		.clk(clk_12m),
		.en_e_n(en_e_n),
		.reg_cs(reg_cs),
		.reg_data_in(reg_data_in),
		.rs(rs),
		.halt(halt),
		.halt_ack(halt_ack),
		.blt_ack(blt_ack),
		.blt_rd(blt_rd),
		.blt_wr(blt_wr),
		.blt_address_out(blt_address_out),
		.blt_data_in(blt_data_in),
		.blt_data_out(blt_data_out),
		.blt_nibble_en(blt_nibble_en)
	);

endmodule
