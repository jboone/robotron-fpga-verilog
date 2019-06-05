/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module top(
	input        clk_osc_12m,

	output [9:0] dac_r,
	output [9:0] dac_g,
	output [9:0] dac_b,
	output       dac_clock,
	output       dac_blank_n,
	output       dac_sync_n,
	output       dac_psave_n,

	output       enc_hsync,
	output       enc_vsync,
	output       enc_4fsc,
	output       enc_stnd,
	output       enc_sa,
	input        enc_tvdet,
	output       enc_term,
	output       enc_ce,

	output       vga_hsync,
	output       vga_vsync/*,

	output       audio_sdin,
	output       audio_sclk,
	output       audio_sync_n*/
	/*
	input        p1_start,

    input        p1_move_up,
    input        p1_move_down,
    input        p1_move_left,
    input        p1_move_right,

    input        p1_fire_up,
    input        p1_fire_down,
    input        p1_fire_left,
    input        p1_fire_right
    */
);

///////////////////////////////////////////////////////////////////////
// PLL: 12MHz -> 12MHz

wire clk_12m_i = clk_osc_12m;
wire clk_12m_fb;
wire clk_12m_op;
wire clk_12m_locked;

(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
	.PLLRST_ENA("DISABLED"),
	.INTFB_WAKE("DISABLED"),
	.STDBY_ENABLE("DISABLED"),
	.DPHASE_SOURCE("DISABLED"),
	.CLKOP_FPHASE(0),
	.CLKOP_CPHASE(24),
	.OUTDIVIDER_MUXA("DIVA"),
	.CLKOP_ENABLE("ENABLED"),
	.CLKOP_DIV(50),
	.CLKFB_DIV(1),
	.CLKI_DIV(1),
	.FEEDBK_PATH("INT_OP")
) pll_12m (
	.CLKI(clk_12m_i),
	.CLKFB(clk_12m_fb),
	.CLKINTFB(clk_12m_fb),
	.CLKOP(clk_12m_op),
	.RST(1'b0),
	.STDBY(1'b0),
	.PHASESEL0(1'b0),
	.PHASESEL1(1'b0),
	.PHASEDIR(1'b0),
	.PHASESTEP(1'b0),
	.PLLWAKESYNC(1'b0),
	.ENCLKOP(1'b0),
	.LOCK(clk_12m_locked)
);

wire clk_12m = clk_12m_op;

///////////////////////////////////////////////////////////////////////
// PLL: 12MHz -> 14.3181818...MHz (4 x NTSC color burst)

wire clk_14m318182_i = clk_osc_12m;
wire clk_14m318182_fb;
wire clk_14m318182_op;
wire clk_14m318182_os;
wire clk_14m318182_locked;


(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
	.PLLRST_ENA("DISABLED"),
	.INTFB_WAKE("DISABLED"),
	.STDBY_ENABLE("DISABLED"),
	.DPHASE_SOURCE("DISABLED"),
	.CLKOP_FPHASE(0),
	.CLKOP_CPHASE(9),
	.OUTDIVIDER_MUXA("DIVA"),
	.CLKOP_ENABLE("ENABLED"),
	.CLKOP_DIV(35),
	.CLKOS_ENABLE("ENABLED"),
	.CLKOS_DIV(44),
	.CLKOS_CPHASE(-1),
	.CLKOS_FPHASE(0),
	.CLKFB_DIV(3),
	.CLKI_DIV(2),
	.FEEDBK_PATH("INT_OP")
) pll_14m318182 (
	.CLKI(clk_14m318182_i),
	.CLKFB(clk_14m318182_fb),
	.CLKINTFB(clk_14m318182_fb),
	.CLKOP(clk_14m318182_op),
	.CLKOS(clk_14m318182_os),
	.RST(1'b0),
	.STDBY(1'b0),
	.PHASESEL0(1'b0),
	.PHASESEL1(1'b0),
	.PHASEDIR(1'b0),
	.PHASESTEP(1'b0),
	.PLLWAKESYNC(1'b0),
	.ENCLKOP(1'b0),
	.LOCK(clk_14m318182_locked)
);

wire clk_14m318182 = clk_14m318182_os;
wire enc_4fsc = clk_14m318182;

///////////////////////////////////////////////////////////////////////
// Reset

reg [7:0] w = 8'h80;
wire rst = w[7];
always @(posedge clk_12m) begin
	if(rst)
		w <= w + 1;
end

///////////////////////////////////////////////////////////////////////
// Robotron CPU and ROM boards

wire [1:0] widget_move_up      = 2'b00;
wire [1:0] widget_move_down    = 2'b00;
wire [1:0] widget_move_left    = 2'b00;
wire [1:0] widget_move_right   = 2'b00;
wire [1:0] widget_fire_up      = 2'b00;
wire [1:0] widget_fire_down    = 2'b00;
wire [1:0] widget_fire_left    = 2'b00;
wire [1:0] widget_fire_right   = 2'b00;
wire [1:0] widget_player_start = 2'b00;

wire coin_door_auto_up          = 1'b0;
wire coin_door_advance          = 1'b0;
wire coin_door_high_score_reset = 1'b0;
wire coin_door_left_coin        = 1'b0;
wire coin_door_center_coin      = 1'b0;
wire coin_door_right_coin       = 1'b0;
wire coin_door_slam_tilt        = 1'b0;

wire [2:0] cpu_r;
wire [2:0] cpu_g;
wire [1:0] cpu_b;
wire cpu_blank;
wire cpu_pixel_clk;
wire cpu_hsync;
wire cpu_vsync;

cpu cpu(
	.rst(rst),
	.clk_12m(clk_12m),
	.red(cpu_r),
	.green(cpu_g),
	.blue(cpu_b),
	.blank(cpu_blank),
	.pixel_clk(cpu_pixel_clk),
	.horiz_sync(cpu_hsync),
	.vert_sync(cpu_vsync),
	.widget_move_up(widget_move_up),
	.widget_move_down(widget_move_down),
	.widget_move_left(widget_move_left),
	.widget_move_right(widget_move_right),
	.widget_fire_up(widget_fire_up),
	.widget_fire_down(widget_fire_down),
	.widget_fire_left(widget_fire_left),
	.widget_fire_right(widget_fire_right),
	.widget_player_start(widget_player_start),
	.coin_door_auto_up(coin_door_auto_up),
	.coin_door_advance(coin_door_advance),
	.coin_door_high_score_reset(coin_door_high_score_reset),
	.coin_door_left_coin(coin_door_left_coin),
	.coin_door_center_coin(coin_door_center_coin),
	.coin_door_right_coin(coin_door_right_coin),
	.coin_door_slam_tilt(coin_door_slam_tilt),
	.rom_write_addr(16'h0000),
	.rom_write_data(8'h00),
	.rom_write_en(1'b0)
);

assign dac_r = { cpu_r, cpu_r, cpu_r, cpu_r[2] };
assign dac_g = { cpu_g, cpu_g, cpu_g, cpu_g[2] };
assign dac_b = { cpu_b, cpu_b, cpu_b, cpu_b, cpu_b };
assign dac_clock = cpu_pixel_clk;

assign enc_hsync = !cpu_hsync;
assign enc_vsync = !cpu_vsync;

assign vga_hsync = !cpu_hsync;
assign vga_vsync = !cpu_vsync;

endmodule
