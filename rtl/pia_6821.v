/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module pia_6821(
	// Host interface
	input  wire       rst,
	input  wire       clk,
	input  wire       en_e_n,
	input  wire [1:0] rs,
	input  wire       r_w_n,
	input  wire       cs,
	input  wire [7:0] data_in,
	output reg  [7:0] data_out,
	output wire       irq_a,
	output wire       irq_b,

	// Peripheral port A
	input  wire [7:0] pa_i,
	output wire [7:0] pa_o,
	output wire [7:0] pa_oe,
	input  wire       ca1_i,
	input  wire       ca2_i,
	output wire       ca2_o,
	output wire       ca2_oe,

	// Peripheral port B
	input  wire [7:0] pb_i,
	output wire [7:0] pb_o,
	output wire [7:0] pb_oe,
	input  wire       cb1_i,
	input  wire       cb2_i,
	output wire       cb2_o,
	output wire       cb2_oe
);

reg [7:0] porta_ddr;
reg [7:0] porta_data;
reg [5:0] porta_ctrl;
reg porta_read;

reg [7:0] portb_ddr;
reg [7:0] portb_data;
reg [5:0] portb_ctrl;
reg portb_read;
reg portb_write;

reg ca1_del;
reg ca1_rise;
reg ca1_fall;
reg ca1_edge;
reg irqa1;

reg ca2_del;
reg ca2_rise;
reg ca2_fall;
reg ca2_edge;
reg irqa2;

reg cb1_del;
reg cb1_rise;
reg cb1_fall;
reg cb1_edge;
reg irqb1;

reg cb2_del;
reg cb2_rise;
reg cb2_fall;
reg cb2_edge;
reg irqb2;

// Read I/O ports

integer count;

always @* begin
	case(rs)
	2'b00: begin
		for(count=0; count<8; count=count+1) begin
			data_out[count] = porta_ctrl[2] ? (porta_ddr[count] ? porta_data[count] : pa_i[count]) : porta_ddr[count];
		end
		porta_read = porta_ctrl[2] ? cs : 1'b0;
		portb_read = 1'b0;
	end

	2'b01: begin
		data_out = { irqa1, irqa2, porta_ctrl };
		porta_read = 1'b0;
		portb_read = 1'b0;
	end

	2'b10: begin
		for(count=0; count<8; count=count+1) begin
			data_out[count] = portb_ctrl[2] ? (portb_ddr[count] ? portb_data[count] : pb_i[count]) : portb_ddr[count];
		end
		portb_read = portb_ctrl[2] ? cs : 1'b0;
		porta_read = 1'b0;
	end

	2'b11: begin
		data_out = { irqb1, irqb2, portb_ctrl };
		portb_read = 1'b0;
		porta_read = 1'b0;
	end
	endcase
end

// Write I/O ports

always @(posedge clk) begin
	if(rst) begin
		porta_ddr  <= 8'b0000_0000;
		porta_data <= 8'b0000_0000;
		porta_ctrl <=   6'b00_0000;
		portb_ddr  <= 8'b0000_0000;
		portb_data <= 8'b0000_0000;
		portb_ctrl <=   6'b00_0000;
		portb_write <= 1'b0;
	end else begin
		if(en_e_n && cs && !r_w_n) begin
			case(rs)
			2'b00: begin
				if(porta_ctrl[2])
					porta_data <= data_in;
				else
					porta_ddr  <= data_in;
				portb_write <= 1'b0;
			end

			2'b01: begin
				porta_ctrl  <= data_in[5:0];
				portb_write <= 1'b0;
			end

			2'b10: begin
				if(portb_ctrl[2]) begin
					portb_data  <= data_in;
					portb_write <= 1'b1;
				end else begin
					portb_ddr   <= data_in;
					portb_write <= 1'b0;
				end
			end

			2'b11: begin
				portb_ctrl  <= data_in[5:0];
				portb_write <= 1'b0;
			end

			endcase
		end
	end
end

// Direction Control Port A

assign pa_o  = porta_data & porta_ddr;
assign pa_oe = porta_ddr;

// CA1 Edge Detect

always @(posedge clk) begin
	if(rst) begin
		ca1_del  <= 1'b0;
		ca1_rise <= 1'b0;
		ca1_fall <= 1'b0;
		ca1_edge <= 1'b0;
		irqa1    <= 1'b0;
	end else begin
		if(en_e_n) begin
			ca1_del  <= ca1_i;
			ca1_rise <= !ca1_del &&  ca1_i;
			ca1_fall <=  ca1_del && !ca1_i;
			if(ca1_edge)
				irqa1 <= 1'b1;
			else if(porta_read)
				irqa1 <= 1'b0;
		end  

		ca1_edge <= porta_ctrl[1] ? ca1_rise : ca1_fall;
	end
end

// CA2 Edge Detect

always @(posedge clk) begin
	if(rst) begin
		ca2_del  <= 1'b0;
		ca2_rise <= 1'b0;
		ca2_fall <= 1'b0;
		ca2_edge <= 1'b0;
		irqa2    <= 1'b0;
	end else begin
		if(en_e_n) begin
			ca2_del  <= ca2_i;
			ca2_rise <= !ca2_del &&  ca2_i;
			ca2_fall <=  ca2_del && !ca2_i;
			if(!porta_ctrl[5] && ca2_edge)
				irqa2 <= 1'b1;
			else if(porta_read)
				irqa2 <= 1'b0;
		end

		ca2_edge <= porta_ctrl[4] ? ca2_rise : ca2_fall;
	end
end

// CA2 Output Control

reg ca2_out;
always @(posedge clk) begin
	if(rst)
		ca2_out <= 1'b0;
	else if(en_e_n) begin
		case(porta_ctrl[5:3])
		3'b100: // read PA clears, CA1 edge sets
			if(porta_read)
				ca2_out <= 1'b0;
			else if(ca1_edge)
				ca2_out <= 1'b1;
		3'b101: // read PA clears, E sets
			ca2_out <= !porta_read;
		3'b110: // set low
			ca2_out <= 1'b0;
		3'b111: // set high
			ca2_out <= 1'b1;
		default:
			ca2_out <= ca2_out;
		endcase
	end
end

// CA2 Direction Control

assign ca2_o  = porta_ctrl[5] ? ca2_out : 1'b0;
assign ca2_oe = porta_ctrl[5];

// Direction Control Port B

assign pb_o  = portb_data & portb_ddr;
assign pb_oe = portb_ddr;

// CB1 Edge Detect

always @(posedge clk) begin
	if(rst) begin
		cb1_del  <= 1'b0;
		cb1_rise <= 1'b0;
		cb1_fall <= 1'b0;
		cb1_edge <= 1'b0;
		irqb1    <= 1'b0;
	end else begin
		if(en_e_n) begin
			cb1_del  <= cb1_i;
			cb1_rise <= !cb1_del &&  cb1_i;
			cb1_fall <=  cb1_del && !cb1_i;
			if(cb1_edge)
				irqb1 <= 1'b1;
			else if(portb_read)
				irqb1 <= 1'b0;
		end

		cb1_edge <= portb_ctrl[1] ? cb1_rise : cb1_fall;
	end
end

// CB2 Edge Eetect

always @(posedge clk) begin
	if(rst) begin
		cb2_del  <= 1'b0;
		cb2_rise <= 1'b0;
		cb2_fall <= 1'b0;
		cb2_edge <= 1'b0;
		irqb2    <= 1'b0;
	end else if(en_e_n) begin
		cb2_del  <= cb2_i;
		cb2_rise <= !cb2_del &&  cb2_i;
		cb2_fall <=  cb2_del && !cb2_i;
		if(!portb_ctrl[5] && cb2_edge)
			irqb2 <= 1'b1;
		else if(portb_read)
			irqb2 <= 1'b0;
	end
end

// CB2 Output Control

reg cb2_out;
always @(posedge clk) begin
	if(rst)
		cb2_out <= 1'b0;
	else if(en_e_n) begin
		case(portb_ctrl[5:3])
		3'b100: // write PB clears, CA1 edge sets
			if(portb_write)
				cb2_out <= 1'b0;
			else if(cb1_edge)
				cb2_out <= 1'b1;
		3'b101: // write PB clears, E sets
			cb2_out <= !portb_write;
		3'b110: // set low
			cb2_out <= 1'b0;
		3'b111: // set high
			cb2_out <= 1'b1;
		default:
			cb2_out <= cb2_out;
		endcase
	end
end

// CB2 Direction Control

assign cb2_o  = portb_ctrl[5] ? cb2_out : 1'b0;
assign cb2_oe = portb_ctrl[5];

// IRQ Control

assign irq_a = (irqa1 && porta_ctrl[0]) || (irqa2 && porta_ctrl[3]);
assign irq_b = (irqb1 && portb_ctrl[0]) || (irqb2 && portb_ctrl[3]);

endmodule
