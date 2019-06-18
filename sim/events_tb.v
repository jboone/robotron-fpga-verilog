/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module events_tb;

reg rst = 0;
reg clk = 0;

wire       uart_ready;
wire [7:0] uart_data_in;
wire       uart_write;
wire       uart_data_out;

uart_tx #(
	.BDIV(2)
) uart(
	.rst(rst),
	.clk(clk),
	.ready(uart_ready),
	.data_in(uart_data_in),
	.write(uart_write),
	.data_out(uart_data_out)
);

wire event_boot = 1'b0;
wire event_game_start = 1'b0;
wire event_player_death = 1'b0;
wire event_still_trying = 1'b0;
wire event_human_saved = 1'b0;
wire event_human_killed = 1'b0;
wire event_grunt_killed_by_electrode = 1'b0;
reg  event_game_over = 1'b0;
reg  event_score_change = 1'b0;
wire [31:0] score_p1 = 32'h12345678;
wire event_enforcer_spark = 1'b0;
wire event_wave_change = 1'b0;
wire event_nvram_dump = 1'b0;

events events(
	.rst(rst),
	.clk(clk),

	.event_nvram_dump(event_nvram_dump),
	.event_wave_change(event_wave_change),
	.event_enforcer_spark(event_enforcer_spark),
	.event_score_change(event_score_change),
	.score_p1(score_p1),
	.event_game_over(event_game_over),
	.event_grunt_killed_by_electrode(event_grunt_killed_by_electrode),
	.event_human_killed(event_human_killed),
	.event_human_saved(event_human_saved),
	.event_still_trying(event_still_trying),
	.event_player_death(event_player_death),
	.event_game_start(event_game_start),
	.event_boot(event_boot),

	.uart_ready(uart_ready),
	.uart_out(uart_data_in),
	.uart_out_en(uart_write)
);

always #50 clk = !clk;

initial begin
	$dumpfile("events_tb.vcd");
	$dumpvars(0, events);	
	$dumpvars(0, uart);	

	#300 rst <= 1'b1;
	#100 rst <= 1'b0;

	#1000 event_game_over <= 1'b1;
	#100 event_game_over <= 1'b0;

	#7000 event_score_change <= 1'b1;
	#100 event_score_change <= 1'b0;

	#150000 $finish;
end

endmodule
