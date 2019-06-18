/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module video_counter(
	input  wire        rst,
	input  wire        clk,
	input  wire        clk_en,
	input  wire        screen_control,
	output wire [13:0] video_addr,
	output wire [ 7:0] video_prom_addr,
	output reg         count_240,
	output reg         irq_4ms
);

reg [15:0] q;
reg pe;

wire pe_toggle = (q == 16'hffff);

wire [15:0] q_next = (pe_toggle && !pe) ? 16'hfc00 : q + 1;

wire [13:0] video_addr_next = q_next[15:2];

wire count_240_next = (video_addr_next[13:10] == 4'hF);

wire irq_4ms_next = video_addr_next[11];

always @(posedge clk) begin
	if(rst) begin
		q <= 0;
		pe <= 0;
		count_240 <= 0;
		irq_4ms <= 0;
	end else if(clk_en) begin
		q <= q_next;

		if(pe_toggle)
			pe <= !pe;

		count_240 <= count_240_next;
		irq_4ms <= irq_4ms_next;
	end
end

assign video_addr = q[15:2];

wire en_decode = (q_next[7:0] == 0) && clk_en;

rom_decoder_6 decoder_6(
	.clock_i(clk),
	.clock_enable_i(en_decode || rst),
	.address_i({ screen_control, q_next[15:8] }),
	.data_o(video_prom_addr)
);

endmodule
