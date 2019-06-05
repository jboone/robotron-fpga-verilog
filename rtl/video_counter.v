/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module video_counter(
	input         rst,
	input         clk,
	input         clk_en,
	input         screen_control,
	output [13:0] video_addr,
	output [ 7:0] video_prom_addr,
	output        hsync,
	output        vsync,
	output        blank,
	output        count_240,
	output        irq_4ms
);

reg [15:0] q;
reg pe;

wire pe_toggle = (q == 16'hffff);

wire [15:0] q_next = (pe_toggle && !pe) ? 16'hfc00 : q + 1;

wire [13:0] video_addr_next = q_next[15:2];

wire hsync_check = q_next[1:0] == 2'b10;

wire hsync_active = video_addr_next[5:2] == 4'b1110;
reg hsync;

wire vsync_next = (video_addr_next[13:9] == 5'b11111);
reg vsync;

wire hblank_start = video_addr_next[5] && video_addr_next[4] && video_addr_next[2] && video_addr_next[0];
wire hblank_end = !video_addr_next[5] && video_addr_next[1] && video_addr_next[0];
reg hblank;

wire vblank_clock = (q_next[8:0] == 9'b1_0000_0000);
reg vblank;

wire count_240_next = (video_addr_next[13:10] == 4'hF);
reg count_240;

wire irq_4ms_next = video_addr_next[11];
reg irq_4ms;

always @(posedge clk) begin
	if(rst) begin
		q <= 0;
		pe <= 0;
		hsync <= 0;
		vsync <= 0;
		hblank <= 1;
		vblank = 1;
		count_240 <= 0;
		irq_4ms <= 0;
	end else if(clk_en) begin
		q <= q_next;

		if(pe_toggle)
			pe <= !pe;

		if(hsync_check)
			hsync <= hsync_active;

		vsync <= vsync_next;

		if(hblank_start || hblank_end)
			hblank <= hblank_start;

		if(vblank_clock)
			vblank <= vsync_next;

		count_240 <= count_240_next;
		irq_4ms <= irq_4ms_next;
	end
end

assign video_addr = q[15:2];
assign blank = hblank || vblank;

wire en_decode = (q_next[7:0] == 0) && clk_en;

rom_decoder_6 decoder_6(
	.clock_i(clk),
	.clock_enable_i(en_decode || rst),
	.address_i({ screen_control, q_next[15:8] }),
	.data_o(video_prom_addr)
);

endmodule
