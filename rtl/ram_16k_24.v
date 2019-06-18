/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module ram_16k_24(
	input  wire        clk,
	input  wire [13:0] addr,
	input  wire [ 5:0] we,
	input  wire [23:0] data_in,
	output wire [23:0] data_out
);

wire wren = we[5] || we[4] || we[3] || we[2] || we[1] || we[0];

`ifdef SIM

reg [23:0] mem[0:16383];

integer i;
initial
	for (i=0; i<16384; i++)
		mem[i] = 0;

assign data_out = wren ? 'bx : mem[addr];

always @(posedge clk) begin
	if(we[5] && wren) mem[addr][23:20] <= data_in[23:20];
	if(we[4] && wren) mem[addr][19:16] <= data_in[19:16];
	if(we[3] && wren) mem[addr][15:12] <= data_in[15:12];
	if(we[2] && wren) mem[addr][11: 8] <= data_in[11: 8];
	if(we[1] && wren) mem[addr][ 7: 4] <= data_in[ 7: 4];
	if(we[0] && wren) mem[addr][ 3: 0] <= data_in[ 3: 0];
end
`endif

// NOTE: Bad nomenclature, apparently POWEROFF=1 is power *on*!

`ifdef ICE40
SB_SPRAM256KA mem_0(
	.DATAIN(data_in[15:0]),
	.ADDRESS(addr),
	.MASKWREN(we[3:0]),
	.WREN(wren),
	.CHIPSELECT(1'b1),
	.CLOCK(clk),
	.STANDBY(1'b0),
	.SLEEP(1'b0),
	.POWEROFF(1'b1),
	.DATAOUT(data_out[15:0])
);

wire [15:0] data_out_ignored;

SB_SPRAM256KA mem_1(
	.DATAIN({ 8'h00, data_in[23:16] }),
	.ADDRESS(addr),
	.MASKWREN({ 2'b00, we[5:4] }),
	.WREN(wren),
	.CHIPSELECT(1'b1),
	.CLOCK(clk),
	.STANDBY(1'b0),
	.SLEEP(1'b0),
	.POWEROFF(1'b1),
	.DATAOUT({ data_out_ignored, data_out[23:16] })
);
`endif

`ifdef ECP5

reg [23:0] mem[0:16383];

wire [23:0] mem_i = data_in;

reg [23:0] mem_o;

always @(posedge clk) begin
	mem_o <= mem[addr];

	if(we[5]) mem[addr][23:20] <= mem_i[23:20];
	if(we[4]) mem[addr][19:16] <= mem_i[19:16];
	if(we[3]) mem[addr][15:12] <= mem_i[15:12];
	if(we[2]) mem[addr][11: 8] <= mem_i[11: 8];
	if(we[1]) mem[addr][ 7: 4] <= mem_i[ 7: 4];
	if(we[0]) mem[addr][ 3: 0] <= mem_i[ 3: 0];
end

assign data_out = mem_o;

`endif

endmodule
