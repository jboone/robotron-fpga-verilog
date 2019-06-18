/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module top(
	input  wire        button_n,
	input  wire        clk_osc_12m,

	output wire [ 9:0] dac_r,
	output wire [ 9:0] dac_g,
	output wire [ 9:0] dac_b,
	output wire        dac_clock,
	output reg         dac_blank_n,
	output wire        dac_sync_n,
	output wire        dac_psave_n,

	output reg         enc_hsync,
	output reg         enc_vsync,
	output wire        enc_4fsc,
	output wire        enc_stnd,
	output wire        enc_sa,
	input  wire        enc_tvdet,
	output wire        enc_term,
	output wire        enc_ce,

	output reg         vga_hsync,
	output reg         vga_vsync,

	output wire        sound_sclk,
	output wire        sound_sdin,
	output wire        sound_sync_n,

	output wire        events_tx,

	input  wire        move_up_n,
	input  wire        move_down_n,
	input  wire        move_left_n,
	input  wire        move_right_n,

	input  wire        fire_up_n,
	input  wire        fire_down_n,
	input  wire        fire_left_n,
	input  wire        fire_right_n,

	input  wire        player_start_1up_n,

	output wire [ 7:0] led_n,
	input  wire [ 7:0] dip_n
);

///////////////////////////////////////////////////////////////////////

wire button = !button_n;

wire [7:0] led;
assign led_n = led ^ 8'hff;

wire [7:0] dip = dip_n ^ 8'hff;

///////////////////////////////////////////////////////////////////////
// Reset

reg [7:0] w = 8'h80;
wire rst = w[7];
always @(posedge clk_osc_12m) begin
	/*if(button)
		w <= 8'h80;
	else */if(rst)
		w <= w + 8'h01;
end

///////////////////////////////////////////////////////////////////////
// PLL: 12MHz -> 12MHz

wire clk_12m_i = clk_osc_12m;
wire clk_12m_fb;
wire clk_12m_op;
wire clk_12m_os;
wire clk_12m_os2;
wire clk_12m_os3;
wire clk_12m_locked;

(* FREQUENCY_PIN_CLKI="12.000000" *)
(* FREQUENCY_PIN_CLKOP="12.000000" *)
(* ICP_CURRENT="12" *)
(* LPF_RESISTOR="8" *)
(* MFG_ENABLE_FILTEROPAMP="1" *)
(* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
	.PLLRST_ENA("DISABLED"),
	.INTFB_WAKE("DISABLED"),
	.STDBY_ENABLE("DISABLED"),
	.DPHASE_SOURCE("DISABLED"),
	.CLKFB_DIV(1),
	.CLKI_DIV(1),
	.FEEDBK_PATH("INT_OP"),
	.CLKOP_ENABLE("ENABLED"),
	.CLKOP_DIV(50),
	.CLKOP_CPHASE(49)
) pll_12m (
	.CLKI(clk_12m_i),
	.CLKFB(clk_12m_fb),
	.CLKINTFB(clk_12m_fb),
	.CLKOP(clk_12m_op),
	.ENCLKOP(1'b1),
	.CLKOS(clk_12m_os),
	.ENCLKOS(1'b0),
	.CLKOS2(clk_12m_os2),
	.ENCLKOS2(1'b0),
	.CLKOS3(clk_12m_os3),
	.ENCLKOS3(1'b0),
	.RST(rst),
	.STDBY(1'b0),
	.PHASESEL0(1'b0),
	.PHASESEL1(1'b0),
	.PHASEDIR(1'b0),
	.PHASESTEP(1'b0),
	.PHASELOADREG(1'b0),
	.PLLWAKESYNC(1'b0),
	.LOCK(clk_12m_locked)
);

wire clk_12m = clk_12m_op;

///////////////////////////////////////////////////////////////////////
// PLL: 12MHz -> 14.3181818...MHz (4 x NTSC color burst)

wire clk_14m318182_i = clk_osc_12m;
wire clk_14m318182_fb;
wire clk_14m318182_op;
wire clk_14m318182_os;
wire clk_14m318182_os2;
wire clk_14m318182_os3;
wire clk_14m318182_locked;


(* FREQUENCY_PIN_CLKI="12.000000" *)
(* FREQUENCY_PIN_CLKOS="14.318181818181818" *)
(* FREQUENCY_PIN_CLKOS2="28.636363636363637" *)
(* ICP_CURRENT="12" *)
(* LPF_RESISTOR="8" *)
(* MFG_ENABLE_FILTEROPAMP="1" *)
(* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
	.PLLRST_ENA("DISABLED"),
	.INTFB_WAKE("DISABLED"),
	.STDBY_ENABLE("DISABLED"),
	.DPHASE_SOURCE("DISABLED"),
	
	.CLKI_DIV(2),
	.CLKFB_DIV(3),
	.FEEDBK_PATH("INT_OP"),
	.CLKOP_ENABLE("ENABLED"),
	.CLKOP_DIV(35),
	.CLKOP_CPHASE(34),
	.CLKOS_ENABLE("ENABLED"),
	.CLKOS_DIV(44),
	.CLKOS2_ENABLE("ENABLED"),
	.CLKOS2_DIV(22)
) pll_14m318182 (
	.CLKI(clk_14m318182_i),
	.CLKFB(clk_14m318182_fb),
	.CLKINTFB(clk_14m318182_fb),
	.CLKOP(clk_14m318182_op),
	.ENCLKOP(1'b0),
	.CLKOS(clk_14m318182_os),
	.ENCLKOS(1'b1),
	.CLKOS2(clk_14m318182_os2),
	.ENCLKOS2(1'b1),
	.CLKOS3(clk_14m318182_os3),
	.ENCLKOS3(1'b0),
	.RST(rst),
	.STDBY(1'b0),
	.PHASESEL0(1'b0),
	.PHASESEL1(1'b0),
	.PHASEDIR(1'b0),
	.PHASESTEP(1'b0),
	.PHASELOADREG(1'b0),
	.PLLWAKESYNC(1'b0),
	.LOCK(clk_14m318182_locked)
);

wire clk_14m318182 = clk_14m318182_os;
assign enc_4fsc = clk_14m318182;

wire clk_28m636364 = clk_14m318182_os2;
assign sound_sclk = clk_28m636364;

///////////////////////////////////////////////////////////////////////

wire ready = !rst && clk_12m_locked && clk_14m318182_locked;

///////////////////////////////////////////////////////////////////////
// Robotron CPU and ROM boards

wire cpu_en_e_n;

wire [1:0] widget_move_up      = { 1'b0, !move_up_n };
wire [1:0] widget_move_down    = { 1'b0, !move_down_n };
wire [1:0] widget_move_left    = { 1'b0, !move_left_n };
wire [1:0] widget_move_right   = { 1'b0, !move_right_n };
wire [1:0] widget_fire_up      = { 1'b0, !fire_up_n };
wire [1:0] widget_fire_down    = { 1'b0, !fire_down_n };
wire [1:0] widget_fire_left    = { 1'b0, !fire_left_n };
wire [1:0] widget_fire_right   = { 1'b0, !fire_right_n };
wire [1:0] widget_player_start = { 1'b0, !player_start_1up_n };

wire [5:0] sound_pb;
wire       sound_hand;

wire coin_door_auto_up          = 1'b0;
wire coin_door_advance          = 1'b0;
wire coin_door_high_score_reset = 1'b0;
wire coin_door_left_coin        = button;
wire coin_door_center_coin      = 1'b0;
wire coin_door_right_coin       = 1'b0;
wire coin_door_slam_tilt        = 1'b0;

wire [2:0] cpu_r;
wire [2:0] cpu_g;
wire [1:0] cpu_b;
wire cpu_pixel_clk;
wire [13:0] video_addr;

wire        event_boot;
wire        event_game_start;
wire        event_player_death;
wire        event_still_trying;
wire        event_human_saved;
wire        event_human_killed;
wire        event_grunt_killed_by_electrode;
wire        event_game_over;
wire        event_score_change;
wire [31:0] score_p1;
wire        event_enforcer_spark;
wire        event_wave_change;
wire [ 7:0] wave_p1;
wire        event_nvram_dump;
wire [23:0] initials;

cpu cpu(
	.rst(!ready),
	.clk_12m(clk_12m),
	.en_e_n(cpu_en_e_n),
	.red(cpu_r),
	.green(cpu_g),
	.blue(cpu_b),
	.pixel_clk(cpu_pixel_clk),
	.video_addr(video_addr),
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
	.sound_pb(sound_pb),
	.sound_hand(sound_hand),
	.rom_write_addr(16'h0000),
	.rom_write_data(8'h00),
	.rom_write_en(1'b0),
	.event_boot(event_boot),
	.event_game_start(event_game_start),
	.event_player_death(event_player_death),
	.event_still_trying(event_still_trying),
	.event_human_saved(event_human_saved),
	.event_human_killed(event_human_killed),
	.event_grunt_killed_by_electrode(event_grunt_killed_by_electrode),
	.event_game_over(event_game_over),
	.event_score_change(event_score_change),
	.score_p1(score_p1),
	.event_enforcer_spark(event_enforcer_spark),
	.event_wave_change(event_wave_change),
	.wave_p1(wave_p1),
	.event_nvram_dump(event_nvram_dump),
	.initials(initials)
);

// VGA 640x480@60
//`define HSYNC_BEGIN        8
//`define HSYNC_END          53
//`define HSYNC_PERIOD       381

//`define VSYNC_BEGIN        490
//`define VSYNC_END          492
//`define VSYNC_PERIOD       525

// Robotron @ 12MHz
//`define HSYNC_BEGIN        12'd0
//`define HSYNC_END          12'd56
//`define HSYNC_PERIOD       12'd768

//`define HVALID_BEGIN       12'd128	// 10.9us
//`define HVALID_END         12'd736

//`define VSYNC_BEGIN        12'd3
//`define VSYNC_END          12'd6
//`define VSYNC_PERIOD       12'd260

//`define VVALID_BEGIN       12'd24
//`define VVALID_END         12'd250

/*
// Known Good!!!!
// Robotron @ 6MHz
`define HSYNC_BEGIN        6'd56
`define HSYNC_END          6'd61
// `define HSYNC_PERIOD       12'd64

`define HVALID_BEGIN       6'd3
`define HVALID_END         6'd53

`define VSYNC_BEGIN        8'd251
`define VSYNC_END          8'd254
// `define VSYNC_PERIOD       8'd260

`define VVALID_BEGIN       8'd8
`define VVALID_END         8'd248
*/

// Robotron @ 6MHz
`define HSYNC_BEGIN        6'd56
`define HSYNC_END          6'd61
// `define HSYNC_PERIOD       12'd64

`define HVALID_BEGIN       6'd3
`define HVALID_END         6'd53

`define VSYNC_BEGIN        8'd251
`define VSYNC_END          8'd254
// `define VSYNC_PERIOD       8'd260

`define VVALID_BEGIN       8'd8
`define VVALID_END         8'd248

assign dac_r = { cpu_r, cpu_r, cpu_r, cpu_r[2] };
assign dac_g = { cpu_g, cpu_g, cpu_g, cpu_g[2] };
assign dac_b = { cpu_b, cpu_b, cpu_b, cpu_b, cpu_b };

wire [5:0] hcount = video_addr[5:0];
wire [7:0] vcount = video_addr[13:6];

always @(posedge clk_12m) begin
	if(!ready) begin
		vga_hsync <= 1'b1;
		vga_vsync <= 1'b1;
		
		enc_hsync <= 1'b0;
		enc_vsync <= 1'b0;

		dac_blank_n <= 1'b0;
	end else begin
		vga_hsync <= !((hcount >= `HSYNC_BEGIN) && (hcount < `HSYNC_END));
		vga_vsync <= !((vcount >= `VSYNC_BEGIN) && (vcount < `VSYNC_END));

		enc_hsync <=  ((hcount >= `HSYNC_BEGIN) && (hcount < `HSYNC_END));
		enc_vsync <=  ((vcount >= `VSYNC_BEGIN) && (vcount < `VSYNC_END));

		dac_blank_n <= (hcount >= `HVALID_BEGIN) && (hcount < `HVALID_END) && (vcount >= `VVALID_BEGIN) && (vcount < `VVALID_END);
	end
end

assign dac_clock = !clk_12m;
assign dac_sync_n = 1'b0;
assign dac_psave_n = 1'b1;

assign enc_term = 1'b1;
assign enc_ce = 1'b1;
assign enc_sa = 1'b0;
assign enc_stnd = 1'b1;

///////////////////////////////////////////////////////////////////////

reg [7:0] sound_mpu_clk_4e_shift;
wire sound_mpu_clk_4e = sound_mpu_clk_4e_shift[7];

always @(posedge sound_sclk) begin
	if(!ready)
		sound_mpu_clk_4e_shift <= 8'h0f;
	else
		sound_mpu_clk_4e_shift <= { sound_mpu_clk_4e_shift[6:0], sound_mpu_clk_4e_shift[7] };
end

wire        sound_dac_en;
wire [ 7:0] sound_dac_value;

sound sound(
	.rst(!ready),
	.clk_4e(sound_mpu_clk_4e),
	.pb(sound_pb),
	.hand(sound_hand),
	.dac_en(sound_dac_en),
	.dac_value(sound_dac_value)
);

reg [15:0] sound_data;

assign sound_sdin = sound_data[15];
assign sound_sync_n = sound_dac_en;

always @(posedge sound_sclk) begin
	if(!ready) begin
		sound_data <= 16'h0;
	end else begin
		if(sound_dac_en) begin
			sound_data <= { 2'b00, sound_dac_value, 6'h0 };
		end else begin
			sound_data <= { sound_data[14:0], 1'b0 };
		end
	end
end

///////////////////////////////////////////////////////////////////////

wire       events_uart_ready;
wire [7:0] events_uart_data_in;
wire       events_uart_write;
wire       events_uart_data_out;

uart_tx events_uart(
	.rst(!ready),
	.clk(clk_12m),
	.ready(events_uart_ready),
	.data_in(events_uart_data_in),
	.write(events_uart_write),
	.data_out(events_uart_data_out)
);

assign events_tx = events_uart_data_out;

events events(
	.rst(!ready),
	.clk(clk_12m),

	.event_nvram_dump(event_nvram_dump),
	.initials(initials),
	.event_wave_change(event_wave_change),
	.wave_p1(wave_p1),
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

	.uart_ready(events_uart_ready),
	.uart_out(events_uart_data_in),
	.uart_out_en(events_uart_write)
);

///////////////////////////////////////////////////////////////////////

assign led = { sound_hand, 1'b0, sound_pb };

endmodule
