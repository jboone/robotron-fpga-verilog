/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module sound(
	input  wire        rst,
	input  wire        clk_4e,
	
	output wire [ 5:0] pb,
	output wire        hand,
	
	output wire        dac_en,
	output wire [ 7:0] dac_value
);

///////////////////////////////////////////////////////////////////////

wire reset = rst;

reg [3:0] phase_e;
reg sync_e;
reg en_e_n;

always @(posedge clk_4e) begin
	if(reset) begin
		phase_e <= 4'b0001;
		sync_e <= 1'b0;
		en_e_n <= 1'b1;
	end else begin
		phase_e <= { phase_e[2:0], phase_e[3] };
		sync_e <= phase_e[0] || phase_e[1];
		en_e_n <= phase_e[3];
	end
end

wire clk_e = sync_e;
wire clk_cpu = clk_e;

///////////////////////////////////////////////////////////////////////

wire [15:0] CPU_ADDRESS_OUT;
wire [ 7:0] CPU_DATA_IN;
wire [ 7:0] CPU_DATA_OUT;
wire        CPU_RW;
wire        CPU_IRQ;
wire        CPU_VMA;
wire        CPU_HALT;
wire        CPU_HOLD;
wire        CPU_NMI;

wire        ROM_CS;
wire [ 7:0] ROM_DATA_OUT;

wire        RAM_CS;
wire        RAM_RW;
wire [ 7:0] RAM_DATA_IN;
wire [ 7:0] RAM_DATA_OUT;

wire        PIA_RW;
wire        PIA_CS;
wire        PIA_IRQA;
wire        PIA_IRQB;
wire [ 7:0] PIA_DATA_IN;
wire [ 7:0] PIA_DATA_OUT;
wire        PIA_CA1;
wire        PIA_CB1;
wire        PIA_CA2_I;
wire        PIA_CA2_O;
wire        PIA_CB2_I;
wire        PIA_CB2_O;
wire [ 7:0] PIA_PA_I;
wire [ 7:0] PIA_PA_O;
wire [ 7:0] PIA_PB_I;
wire [ 7:0] PIA_PB_O;

wire [ 3:0] BCD_DEMUX_INPUT;
wire [ 9:0] BCD_DEMUX_OUTPUT;

wire        SPEECH_CLOCK;
wire        SPEECH_DATA;

///////////////////////////////////////////////////////////////////////

assign CPU_HALT = 1'b0;
assign CPU_HOLD = 1'b0;
assign CPU_NMI = 1'b0;

assign SPEECH_CLOCK = 1'b0;
assign SPEECH_DATA = 1'b0;

cpu68 mpu(
	.clk(clk_cpu),
	.rst(reset),
	.rw(CPU_RW),
	.vma(CPU_VMA),
	.address(CPU_ADDRESS_OUT),
	.data_in(CPU_DATA_IN),
	.data_out(CPU_DATA_OUT),
	.hold(CPU_HOLD),
	.halt(CPU_HALT),
	.irq(CPU_IRQ),
	.nmi(CPU_NMI)
);

assign CPU_IRQ = PIA_IRQA || PIA_IRQB;
assign CPU_DATA_IN = PIA_CS ? PIA_DATA_OUT : (RAM_CS ? RAM_DATA_OUT : ROM_DATA_OUT);

///////////////////////////////////////////////////////////////////////

m6810 ram(
	.clk(clk_cpu),
	.rst(reset),
	.address(CPU_ADDRESS_OUT[6:0]),
	.cs(RAM_CS),
	.rw(RAM_RW),
	.data_in(RAM_DATA_IN),
	.data_out(RAM_DATA_OUT)
);

assign RAM_CS = (CPU_ADDRESS_OUT[11:8] == 4'b0000) && (BCD_DEMUX_OUTPUT[8] == 1'b0) && CPU_VMA;
assign RAM_RW = CPU_RW;
assign RAM_DATA_IN = CPU_DATA_OUT;

///////////////////////////////////////////////////////////////////////

wire [7:0] PIA_PA_OE;
wire       PIA_CA2_OE;
wire [7:0] PIA_PB_OE;
wire       PIA_CB2_OE;

pia_6821 pia(
	.rst(reset),
	.clk(clk_4e),
	.en_e_n(en_e_n),
	.rs(CPU_ADDRESS_OUT[1:0]),
	.r_w_n(PIA_RW),
	.cs(PIA_CS),
	.data_in(PIA_DATA_IN),
	.data_out(PIA_DATA_OUT),
	.irq_a(PIA_IRQA),
	.irq_b(PIA_IRQB),
	.pa_i(PIA_PA_I),
	.pa_o(PIA_PA_O),
	.pa_oe(PIA_PA_OE),
	.ca1_i(PIA_CA1),
	.ca2_i(PIA_CA2_I),
	.ca2_o(PIA_CA2_O),
	.ca2_oe(PIA_CA2_OE),
	.pb_i(PIA_PB_I),
	.pb_o(PIA_PB_O),
	.pb_oe(PIA_PB_OE),
	.cb1_i(PIA_CB1),
	.cb2_i(PIA_CB2_I),
	.cb2_o(PIA_CB2_O),
	.cb2_oe(PIA_CB2_OE)
);

assign PIA_CA1 = 1'b1;
assign PIA_CA2_I = SPEECH_DATA;
assign PIA_CB1 = !(hand && pb[5] && pb[4] && pb[3] && pb[2] && pb[1] && pb[0]);
assign PIA_CB2_I = SPEECH_CLOCK;
assign PIA_CS = (!(BCD_DEMUX_OUTPUT[0] && BCD_DEMUX_OUTPUT[8])) && CPU_ADDRESS_OUT[10] && CPU_VMA;
assign PIA_DATA_IN = CPU_DATA_OUT;
assign PIA_RW = CPU_RW;
assign PIA_PA_I = 8'b00000000;

// Checked on Brian's machine, it appears DS1 switches 1 and 2 are both set to "OPEN".
wire DS1_1 = 1'b1;
assign PIA_PB_I = { 1'b0, DS1_1, pb[5:0] };

assign dac_en = en_e_n;
assign dac_value = PIA_PA_O;

rom_snd rom(
	.clock_i(clk_4e),
	.address_i(CPU_ADDRESS_OUT[11:0]),
	.data_o(ROM_DATA_OUT)
);

assign ROM_CS = (!BCD_DEMUX_OUTPUT[7]) && CPU_VMA;

demux_7442 bcd_demux(
	.a(BCD_DEMUX_INPUT),
	.y_n(BCD_DEMUX_OUTPUT)
);

assign BCD_DEMUX_INPUT = { !CPU_ADDRESS_OUT[15], CPU_ADDRESS_OUT[14:12] };

endmodule
