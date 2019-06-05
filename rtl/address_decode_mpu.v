/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module address_decode_mpu(
	input clk,
	input vma,
	input e_rom,
	input screen_control,
	input [15:0] addr,
	input r_w_n,
	output [13:0] ram_addr,
	output [1:0] ram_lane_sel,
	output racnt,
	output rom_cs,
	output palette_ram_cs,
	output pia_widget_cs,
	output pia_rom_cs,
	output reg_misc_cs,
	output evie,
	output video_count_cs,
	output cmos_ram_cs
);

wire [5:0] pseudo_addr;
rom_decoder_4 decoder_4(
	.clock_i(clk),
	.clock_enable_i(1'b1),
	.address_i({ screen_control, addr[15:8] }),
	.data_o({ ram_lane_sel, pseudo_addr })
);

assign ram_addr = { addr[7:0], pseudo_addr };

wire mux_8e_g1 = (addr[15] && addr[14]) || (r_w_n && e_rom);
wire mux_8e_g2 = vma;

wire [15:0] mux_8e_y_n;
mux_74154 mux_8e(
	.a(addr[15:12]),
	.g_n({ !mux_8e_g2, !mux_8e_g1 }),
	.y_n(mux_8e_y_n)
);

assign racnt = (!mux_8e_y_n[9] || !mux_8e_y_n[10] || !mux_8e_y_n[11] || !mux_8e_g1) && vma;

wire i_o = !mux_8e_y_n[12];

assign rom_cs =
	   !mux_8e_y_n[0]
	|| !mux_8e_y_n[1]
	|| !mux_8e_y_n[2]
	|| !mux_8e_y_n[3]
	|| !mux_8e_y_n[4]
	|| !mux_8e_y_n[5]
	|| !mux_8e_y_n[6]
	|| !mux_8e_y_n[7]
	|| !mux_8e_y_n[8]
	|| !mux_8e_y_n[13]
	|| !mux_8e_y_n[14]
	|| !mux_8e_y_n[15]
	;

wire addr_c0xx_c3xx = i_o && (addr[11:10] == 2'b00);
wire addr_c4xx_c7xx = i_o && (addr[11:10] == 2'b01);
wire addr_c8xx_cbxx = i_o && (addr[11:10] == 2'b10);
wire addr_ccxx_cfxx = i_o && (addr[11:10] == 2'b11);

wire addr_c8xx      = i_o && (addr[11: 8] == 4'b1000);
wire addr_c9xx      = i_o && (addr[11: 8] == 4'b1001);
wire addr_caxx      = i_o && (addr[11: 8] == 4'b1010);
wire addr_cbxx      = i_o && (addr[11: 8] == 4'b1011);

assign palette_ram_cs  = addr_c0xx_c3xx;

assign pia_widget_cs  = addr_c8xx && (addr[3:2] == 2'b01);
assign pia_rom_cs     = addr_c8xx && (addr[3:2] == 2'b11);

assign reg_misc_cs    = addr_c9xx;

assign evie           = addr_caxx;

assign video_count_cs = addr_cbxx && (addr[0] == 1'b0);

assign cmos_ram_cs    = addr_ccxx_cfxx;
/*
localparam
	ADDR_RAM,
	ADDR_ROM,
	ADDR_PIA_ROM,
	ADDR_PIA_WIDGET,
	ADDR_PALETTE,
	ADDR_MISC,
	ADDR_EVIE,
	ADDR_VIDEO_COUNT,
	ADDR_CMOS
	;
always @* begin
	casez(addr[15:12])
	16'b0000_????_????_????: blah;
	endcase
end
*/
endmodule
