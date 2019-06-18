/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module williams_sc1 #(
	parameter IS_SC1 = 1
)(
	input         rst,
	input         clk,
	input         en_e_n,
	input         reg_cs,
	input  [ 7:0] reg_data_in,
	input  [ 2:0] rs,
	output        halt,
	input         halt_ack,
	input         blt_ack,
	output        blt_rd,
	output        blt_wr,
	input  [ 7:0] blt_data_in,
	output [ 7:0] blt_data_out,
	output [15:0] blt_address_out,
	output [ 1:0] blt_nibble_en
);

	localparam
		ST_IDLE = 0,
		ST_WAIT_FOR_HALT = 1,
		ST_SRC = 2,
		ST_DST = 3;

	reg  [ 7:0] reg_ctrl;
	reg  [ 7:0] reg_solid;
	reg  [15:0] reg_src_base;
	reg  [15:0] reg_dst_base;
	reg  [ 7:0] reg_width;
	reg  [ 7:0] reg_height;

	// break out control reg into individual signals
	wire ctrl_span_src   = reg_ctrl[0];
	wire ctrl_span_dst   = reg_ctrl[1];
	wire ctrl_slow       = reg_ctrl[2];
	wire ctrl_foreground = reg_ctrl[3];
	wire ctrl_solid      = reg_ctrl[4];
	wire ctrl_shift      = reg_ctrl[5];
	wire ctrl_no_lower   = reg_ctrl[6];
	wire ctrl_no_upper   = reg_ctrl[7];

	// Internal
	reg  [ 1:0] state;

	reg  [ 7:0] blt_src_data;
	reg  [ 3:0] blt_shift;

	reg  [15:0] src_address;
	reg  [15:0] dst_address;

	reg  [ 7:0] x_count;
	wire [ 7:0] x_count_next = x_count + 1;
	reg  [ 7:0] y_count;
	wire [ 7:0] y_count_next = y_count + 1;

	//SC1 had a bug so values had to be xored with 0X04, SC2 fixed the bug so no xor required
	wire [ 7:0] xorval = IS_SC1 ? 8'h04 : 8'h00;

	assign halt = !(state == ST_IDLE);
	assign blt_rd = (state == ST_SRC);
	assign blt_wr = (state == ST_DST);

	assign blt_address_out = (state == ST_DST) ? dst_address : src_address;

	assign blt_nibble_en[1] = !halt_ack || ((state == ST_SRC) || (!(ctrl_no_upper || (ctrl_foreground && (blt_src_data[7:4] == 4'h0)))));
	assign blt_nibble_en[0] = !halt_ack || ((state == ST_SRC) || (!(ctrl_no_lower || (ctrl_foreground && (blt_src_data[3:0] == 4'h0)))));

	assign blt_data_out = ctrl_solid ? reg_solid : blt_src_data;

	// register access
	always @(posedge clk)
	begin
		if(rst) begin
			reg_ctrl <= 8'b00000000;
			reg_solid <= 8'b00000000;
			reg_src_base <= 0;
			reg_dst_base <= 0;
			reg_width <= 0;
			reg_height <= 0;
		end else
			if(en_e_n)
				if(reg_cs)
					case(rs)
					// 0: Start BLT with control attributes
					3'b000: reg_ctrl  <= reg_data_in;
					// 1: mask
					3'b001: reg_solid <= reg_data_in;
					// 2: source address high
					3'b010: reg_src_base[15:8] <= reg_data_in;
					// 3: source address low
					3'b011: reg_src_base[ 7:0] <= reg_data_in;
					//4: destination address high
					3'b100: reg_dst_base[15:8] <= reg_data_in;
					// 5: destination address low
					3'b101: reg_dst_base[ 7:0] <= reg_data_in;
					// 6: width
					3'b110: reg_width  <= reg_data_in ^ xorval;
					// 7: height
					3'b111: reg_height <= reg_data_in ^ xorval;
					endcase
	end

	// state machine
	always @(posedge clk)
	begin
		if(rst) begin
			state <= ST_IDLE;
			blt_src_data <= 8'h00;
			blt_shift <= 4'b0000;
			src_address <= 0;
			dst_address <= 0;
			x_count <= 0;
			y_count <= 0;
		end else
			if(en_e_n)
				case(state)
				ST_IDLE:
					if(reg_cs && (rs == 3'b000))
						state <= ST_WAIT_FOR_HALT;

				ST_WAIT_FOR_HALT:
					if(halt_ack) begin
						src_address <= reg_src_base;
						dst_address <= reg_dst_base;

						x_count   <= 0;
						y_count   <= 0;
						blt_shift <= 0;

						state <= ST_SRC;
					end

				ST_SRC:
					if(blt_ack) begin
						if(!ctrl_shift) begin
							// unshifted
							blt_src_data <= blt_data_in;
						end else begin
							// shifted right one pixel
							blt_shift    <= blt_data_in[3:0];
							blt_src_data <= { blt_shift, blt_data_in[7:4] };
						end
						state <= ST_DST;
					end

				ST_DST:
					if(blt_ack) begin
						state <= ST_SRC;

						if(x_count_next < reg_width) begin
							x_count <= x_count_next;
							src_address <= src_address + (ctrl_span_src ? 256 : 1);
							dst_address <= dst_address + (ctrl_span_dst ? 256 : 1);
						end else begin
							x_count <= 0;
							y_count <= y_count_next;

							if(y_count_next == reg_height)
								state <= ST_IDLE;

							src_address <= ctrl_span_src ? (reg_src_base + { 8'h00, y_count_next }) : (src_address + 1);
							dst_address <= ctrl_span_dst ? (reg_dst_base + { 8'h00, y_count_next }) : (dst_address + 1);
						end
					end
				endcase
	end

endmodule
