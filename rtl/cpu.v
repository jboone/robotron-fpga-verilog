/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module cpu(
	input        rst,
	input        clk_12m,
	output [2:0] red,
	output [2:0] green,
	output [1:0] blue,
	output       pixel_clk,
	output       blank,
	output       horiz_sync,
	output       vert_sync,
	
	input [ 1:0] widget_move_up,
	input [ 1:0] widget_move_down,
	input [ 1:0] widget_move_left,
	input [ 1:0] widget_move_right,
	input [ 1:0] widget_fire_up,
	input [ 1:0] widget_fire_down,
	input [ 1:0] widget_fire_left,
	input [ 1:0] widget_fire_right,
	input [ 1:0] widget_player_start,

	input        coin_door_auto_up,
	input        coin_door_advance,
	input        coin_door_high_score_reset,
	input        coin_door_left_coin,
	input        coin_door_center_coin,
	input        coin_door_right_coin,
	input        coin_door_slam_tilt,
	
	input [15:0] rom_write_addr,
	input [ 7:0] rom_write_data,
	input        rom_write_en
);

/////////////////////////////////////////////////

// Force screen_control to 0 to save a little logic. FPGA resources are getting tight.
wire screen_control = 1'b0;

// reg [7:0] data;

///////////////////////////////////////////////////////////////////////

wire en_6m;
wire en_4m;
wire en_q;
wire en_e;
wire en_q_n;
wire en_e_n;
wire [11:0] phase_e;

clock_generator clock_generator(
	.rst(rst),
	.clk(clk_12m),
	.en_6m(en_6m),
	.en_4m(en_4m),
	.en_q(en_q),
	.en_e(en_e),
	.en_q_n(en_q_n),
	.en_e_n(en_e_n),
	.phase_e(phase_e)
);

reg sync_q;
reg sync_e;

always @(posedge clk_12m) begin
	if(rst) begin
		sync_q <= 1'b0;
		sync_q <= 1'b0;
	end else begin
		if(en_q || en_q_n)
			sync_q <= en_q ? 1 : 0;
		if(en_e || en_e_n)
			sync_e <= en_e ? 1 : 0;
	end
end

wire clk_q = sync_q;
wire clk_e = sync_e;

///////////////////////////////////////////////////////////////////////

reg en_video_counter;
always @(posedge clk_12m) begin
	if(rst)
		en_video_counter <= 1'b0;
	else if(phase_e[6])
		en_video_counter <= 1'b1;
end

wire [13:0] video_addr;
wire [ 7:0] video_prom_addr;

wire blank;
wire irq_4ms;
wire count_240;

video_counter video_counter(
	.rst(rst),
	.clk(clk_12m),
	.clk_en(en_4m && en_video_counter),
	.screen_control(screen_control),
	.video_addr(video_addr),
	.video_prom_addr(video_prom_addr),
	.hsync(horiz_sync),
	.vsync(vert_sync),
	.blank(blank),
	.count_240(count_240),
	.irq_4ms(irq_4ms)
);

///////////////////////////////////////////////////////////////////////

wire avma;
reg vma;
always @(posedge clk_12m) begin
	if(rst)
		vma <= 1'b0;
	else
		if(en_e_n)
			vma <= avma;
end

reg e_rom;

wire [15:0] addr;
wire r_w_n;
wire [13:0] ram_addr_mpu;
wire [1:0] ram_lane_sel;
wire racnt;
wire rom_cs;
wire palette_ram_mpu_cs;
wire pia_widget_cs;
wire pia_rom_cs;
wire reg_misc_cs;
wire evie;
wire video_count_cs;
wire cmos_ram_cs;

address_decode_mpu address_decode_mpu(
	.clk(clk_12m),
	.vma(vma),
	.e_rom(e_rom),
	.screen_control(screen_control),
	.addr(addr),
	.r_w_n(r_w_n),
	.ram_addr(ram_addr_mpu),
	.ram_lane_sel(ram_lane_sel),
	.racnt(racnt),
	.rom_cs(rom_cs),
	.palette_ram_cs(palette_ram_mpu_cs),
	.pia_widget_cs(pia_widget_cs),
	.pia_rom_cs(pia_rom_cs),
	.reg_misc_cs(reg_misc_cs),
	.evie(evie),
	.video_count_cs(video_count_cs),
	.cmos_ram_cs(cmos_ram_cs)
);

wire ram_phase_video = !clk_e;
wire ram_phase_mcu = clk_e;

// wire ram_data_out_mpu_en = ram_read_byte_en[2] || ram_read_byte_en[1] || ram_read_byte_en[0];
wire ram_cs = racnt && ram_phase_mcu;

wire [13:0] ram_addr_video = { video_prom_addr, video_addr[5:0] };
/*
wire [2:0] ram_read_byte_en = {
	(ram_lane_sel == 2'b10) && r_w_n && racnt,
	(ram_lane_sel == 2'b01) && r_w_n && racnt,
	(ram_lane_sel == 2'b00) && r_w_n && racnt
};
*/
wire [1:0] sc1_nibble_en;
wire [5:0] ram_write_nibble_en = {
	(ram_lane_sel == 2'b10) && sc1_nibble_en[1] && (!r_w_n && en_e_n && ram_cs),
	(ram_lane_sel == 2'b10) && sc1_nibble_en[0] && (!r_w_n && en_e_n && ram_cs),
	(ram_lane_sel == 2'b01) && sc1_nibble_en[1] && (!r_w_n && en_e_n && ram_cs),
	(ram_lane_sel == 2'b01) && sc1_nibble_en[0] && (!r_w_n && en_e_n && ram_cs),
	(ram_lane_sel == 2'b00) && sc1_nibble_en[1] && (!r_w_n && en_e_n && ram_cs),
	(ram_lane_sel == 2'b00) && sc1_nibble_en[0] && (!r_w_n && en_e_n && ram_cs)
};

always @(posedge clk_12m) begin
	if(rst) begin
		e_rom <= 0;
		//screen_control <= 0;
	end else begin
		if(reg_misc_cs && !r_w_n && en_e_n) begin
			e_rom <= mpu_data_o[0];
			//screen_control <= mpu_data_o[1];
		end
	end
end
/*
reg mux_1;
always @(posedge clk_12m) begin
	if(rst)
		mux_1 <= 1'b1;
	else
		if(phase_e[11] || phase_e[5])
			mux_1 <= phase_e[11] || (phase_e[5] && !racnt);
end
*/
wire mux_1 = ram_phase_video || !racnt;

wire [13:0] ram_addr = mux_1 ? ram_addr_video : ram_addr_mpu;
wire [ 5:0] ram_nibble_we = { ram_write_nibble_en };
wire [ 7:0] ram_data_in_byte;
wire [23:0] ram_data_in = { ram_data_in_byte, ram_data_in_byte, ram_data_in_byte };
wire [23:0] ram_data_out;

ram_16k_24 ram(
	.clk(clk_12m),
	.addr(ram_addr),
	.we(ram_nibble_we),
	.data_in(ram_data_in),
	.data_out(ram_data_out)
);
/*
reg [7:0] ram_data_out_mux;
always @* begin
	case(ram_read_byte_en)
	3'b000: ram_data_out_mux <= 8'h00;
	3'b001: ram_data_out_mux <= ram_data_out[ 7: 0];
	3'b010: ram_data_out_mux <= ram_data_out[15: 8];
	3'b100: ram_data_out_mux <= ram_data_out[23:16];
	default: ram_data_out_mux <= 8'hXX;
	endcase
end
*/
/*
wire [7:0] ram_data_out_mux =
	ram_read_byte_en[2] ? ram_data_out[23:16] :
		(ram_read_byte_en[1] ? ram_data_out[15:8] : ram_data_out[7:0]);
*/
reg [7:0] ram_data_out_mux;
always @* begin
	case(ram_lane_sel)
	2'b00:   ram_data_out_mux = ram_data_out[ 7: 0];
	2'b01:   ram_data_out_mux = ram_data_out[15: 8];
	2'b10:   ram_data_out_mux = ram_data_out[23:16];
	default: ram_data_out_mux = ram_data_out[ 7: 0];
	endcase
end

///////////////////////////////////////////////////////////////////////
// Video shift registers

wire video_shifter_load = phase_e[5];
wire video_shifter_shift = en_6m;

wire [23:0] video_shifter_in = ram_data_out;
wire [3:0] video_shifter_out;

video_output video_output(
	.rst(rst),
	.clk(clk_12m),
	.screen_control(screen_control),
	.data_in(video_shifter_in),
	.data_in_en(video_shifter_load),
	.data_out(video_shifter_out),
	.data_out_en(video_shifter_shift)
);

reg pixel_clk;
always @(posedge clk_12m) begin
	pixel_clk <= video_shifter_shift && (video_addr[5:0] < 53) && (video_addr[13:6] < 240);
end

///////////////////////////////////////////////////////////////////////

wire sc1_blt_rd;
wire sc1_blt_wr;

wire        mpu_e_i = clk_e;
wire        mpu_q_i = clk_q;
wire [7:0]  mpu_data_i;
wire [7:0]  mpu_data_o;
wire [15:0] mpu_addr_o;
wire        irq_n;
wire        halt_n;
wire        mpu_lic_o;
wire        mpu_avma_o;
wire        mpu_r_w_n;
wire        mpu_ba_o;
wire        mpu_bs_o;
wire        mpu_busy_o;
wire [111:0] mpu_RegData;

wire bs_ba = mpu_bs_o && mpu_ba_o;

mc6809i #(
	.ILLEGAL_INSTRUCTIONS("GHOST")
) cpucore (
    .D(mpu_data_i),
    .DOut(mpu_data_o),
    .ADDR(mpu_addr_o),
    .RnW(mpu_r_w_n),
    .E(mpu_e_i),
    .Q(mpu_q_i),
    .BS(mpu_bs_o),
    .BA(mpu_ba_o),
    .nIRQ(irq_n),
    .nFIRQ(1'b1),
    .nNMI(1'b1),
    .AVMA(mpu_avma_o),
    .BUSY(mpu_busy_o),
    .LIC(mpu_lic_o),
    .nHALT(halt_n),
    .nRESET(!rst),
    .nDMABREQ(1'b1),
    .RegData(mpu_RegData)
);

// mc6809_small new_cpu(
// 	.E(mpu_e_i),
// 	.data_in(mpu_data_i),
// 	.nRESET(!rst)
// );

wire [7:0] rom_data_out;

rom_64k_8 rom(
	.clock_i(clk_12m),
	.address_i(rst ? rom_write_addr : addr),
	.write_enable_i(rom_write_en),
	.data_i(rom_write_data),
	.data_o(rom_data_out)
);

///////////////////////////////////////////////////////////////////////
// Address decode

wire [ 7:0] sc1_mpu_data_in = mpu_data_o;
wire [ 2:0] sc1_mpu_addr_in = mpu_addr_o[2:0];
wire [15:0] sc1_blt_addr_out;
wire [7:0] sc1_blt_data_in;
wire [7:0] sc1_blt_data_out;

wire sc1_halt;
wire sc1_halt_ack = bs_ba;
wire sc1_blt_ack = (sc1_blt_rd || sc1_blt_wr) && sc1_halt_ack;
assign halt_n = !sc1_halt;

williams_sc1 sc1(
	.rst(rst),
	.clk(clk_12m),
	.en_e_n(en_e_n),
	.reg_cs(evie),
	.reg_data_in(sc1_mpu_data_in),
	.rs(sc1_mpu_addr_in),
	.halt(sc1_halt),
	.halt_ack(sc1_halt_ack),
	.blt_rd(sc1_blt_rd),
	.blt_wr(sc1_blt_wr),
	.blt_ack(sc1_blt_ack),
	.blt_data_in(sc1_blt_data_in),
	.blt_data_out(sc1_blt_data_out),
	.blt_address_out(sc1_blt_addr_out),
	.blt_nibble_en(sc1_nibble_en)
);


///////////////////////////////////////////////////////////////////////
// Palette RAM

wire [3:0] palette_addr_rd = video_shifter_out;
wire [3:0] palette_addr_wr = mpu_addr_o[3:0];
wire       palette_ram_we = palette_ram_mpu_cs && !r_w_n && en_e_n;
wire [7:0] palette_ram_data_in = mpu_data_o;
wire [7:0] palette_ram_data_out;

ram_palette ram_palette_1b_2b(
	.clk(clk_12m),
	.we(palette_ram_we),
	.addr_wr(palette_addr_wr),
	.addr_rd(palette_addr_rd),
	.data_in(palette_ram_data_in),
	.data_out(palette_ram_data_out)
);

assign blue  = palette_ram_data_out[7:6];
assign green = palette_ram_data_out[5:3];
assign red   = palette_ram_data_out[2:0];

///////////////////////////////////////////////////////////////////////
// ROM Board PIA

wire [5:0] sound_pb;

wire [7:0] pia_rom_pa_out;
wire sound_hand = pia_rom_pa_out[7];

wire [7:0] pia_rom_pa_in = {
	coin_door_auto_up,
	coin_door_advance,
	coin_door_high_score_reset,
	coin_door_left_coin,
	coin_door_center_coin,
	coin_door_right_coin,
	coin_door_slam_tilt,
	pia_rom_pa_out[7]
};

wire [7:0] pia_rom_pb_out;
wire [7:0] pia_rom_pb_in = pia_rom_pb_out;

wire [7:0] pia_rom_pa_oe;
wire [7:0] pia_rom_pb_oe;

wire pia_rom_ca2;
wire pia_rom_ca2_oe;
wire pia_rom_cb2;
wire pia_rom_cb2_oe;

wire [1:0] pia_rom_rs = mpu_addr_o[1:0];
wire [7:0] pia_rom_data_in = mpu_data_o;
wire [7:0] pia_rom_data_out;
wire pia_rom_irq_a;
wire pia_rom_irq_b;

pia_6821 pia_rom(
	.rst(rst),
	.clk(clk_12m),
	.en_e_n(en_e_n),
	.rs(pia_rom_rs),
	.r_w_n(r_w_n),
	.cs(pia_rom_cs),
	.data_in(pia_rom_data_in),
	.data_out(pia_rom_data_out),
	.irq_a(pia_rom_irq_a),
	.irq_b(pia_rom_irq_b),
	.pa_i(pia_rom_pa_in),
	.pa_o(pia_rom_pa_out),
	.pa_oe(pia_rom_pa_oe),
	.ca1_i(count_240),
	.ca2_i(pia_rom_ca2),
	.ca2_o(pia_rom_ca2),
	.ca2_oe(pia_rom_ca2_oe),
	.pb_i(pia_rom_pb_in),
	.pb_o(pia_rom_pb_out),
	.pb_oe(pia_rom_pb_oe),
	.cb1_i(irq_4ms),
	.cb2_i(pia_rom_cb2),
	.cb2_o(pia_rom_cb2),
	.cb2_oe(pia_rom_cb2_oe)
);

wire [3:0] decoder_1f_a = { pia_rom_ca2, pia_rom_cb2, pia_rom_pb_out[7:6] };

assign irq_n = !(pia_rom_irq_a || pia_rom_irq_b);

///////////////////////////////////////////////////////////////////////
// Widget Board

wire widget_mux_sel;
wire widget_w1_jumper = 1'b0;

wire [7:0] widget_mux_source_a = {
	widget_fire_right[1], widget_fire_left[1], widget_fire_down[1], widget_fire_up[1],
	widget_move_right[1], widget_move_left[1], widget_move_down[1], widget_move_up[1]
};
wire [7:0] widget_mux_source_b = {
	widget_fire_right[0], widget_fire_left[0], widget_fire_down[0], widget_fire_up[0],
	widget_move_right[0], widget_move_left[0], widget_move_down[0], widget_move_up[0]
};
wire [7:0] widget_mux_source = widget_mux_sel ? widget_mux_source_b : widget_mux_source_a;

wire [1:0] pia_widget_rs = mpu_addr_o[1:0];
wire [7:0] pia_widget_data_in = mpu_data_o;
wire [7:0] pia_widget_data_out;
wire [7:0] pia_widget_pa_i = { widget_mux_source[5:4], widget_player_start, widget_mux_source[3:0] };
wire [7:0] pia_widget_pa_o;
wire [7:0] pia_widget_pa_oe;
wire [7:0] pia_widget_pb_i = { widget_w1_jumper, 5'b00000, widget_mux_source[7:6] };
wire [7:0] pia_widget_pb_o;
wire [7:0] pia_widget_pb_oe;

wire pia_widget_irq_a;
wire pia_widget_irq_b;

wire pia_widget_ca2_o;
wire pia_widget_ca2_oe;
wire pia_widget_cb2_oe;

pia_6821 pia_widget(
	.rst(rst),
	.clk(clk_12m),
	.en_e_n(en_e_n),
	.rs(pia_widget_rs),
	.r_w_n(r_w_n),
	.cs(pia_widget_cs),
	.data_in(pia_widget_data_in),
	.data_out(pia_widget_data_out),
	.irq_a(pia_widget_irq_a),
	.irq_b(pia_widget_irq_b),
	.pa_i(pia_widget_pa_i),
	.pa_o(pia_widget_pa_o),
	.pa_oe(pia_widget_pa_oe),
	.ca1_i(1'b0),
	.ca2_i(1'b0),
	.ca2_o(pia_widget_ca2_o),
	.ca2_oe(pia_widget_ca2_oe),
	.pb_i(pia_widget_pb_i),
	.pb_o(pia_widget_pb_o),
	.pb_oe(pia_widget_pb_oe),
	.cb1_i(1'b0),
	.cb2_i(widget_mux_sel),
	.cb2_o(widget_mux_sel),
	.cb2_oe(pia_widget_cb2_oe)
);

///////////////////////////////////////////////////////////////////////

wire [9:0] cmos_ram_addr_in = mpu_addr_o[9:0];
wire [3:0] cmos_ram_data_in = mpu_data_o[3:0];
wire [7:0] cmos_ram_data_out;

ram_cmos ram_cmos(
	.clk(clk_12m),
	.cs(cmos_ram_cs),
	.we(!r_w_n && en_e_n),
	.addr(cmos_ram_addr_in),
	.data_in(cmos_ram_data_in),
	.data_out(cmos_ram_data_out[3:0])
);
assign cmos_ram_data_out[7:4] = 4'b0000;

///////////////////////////////////////////////////////////////////////
// Data Bus Multiplexing

assign mpu_data_i =
	cmos_ram_cs ? cmos_ram_data_out : (
		pia_widget_cs ? pia_widget_data_out : (
			pia_rom_cs ? pia_rom_data_out : (
				video_count_cs ? { video_addr[13:8], 2'b00 } : (
					rom_cs ? rom_data_out : ram_data_out_mux
				)
			)
		)
	);

assign sc1_blt_data_in =
	rom_cs ? rom_data_out : ram_data_out_mux;

assign addr = mpu_ba_o ? sc1_blt_addr_out : mpu_addr_o;
assign ram_data_in_byte = mpu_ba_o ? sc1_blt_data_out : mpu_data_o;
assign r_w_n = mpu_ba_o ? !sc1_blt_wr : mpu_r_w_n;
assign avma = mpu_ba_o ? 1'b1 : mpu_avma_o;

endmodule
