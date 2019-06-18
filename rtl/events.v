/* Copyright 2019 Jared Boone <jared@sharebrained.com>. Open-source license to be determined.
 */

`default_nettype none
`timescale 1ns / 100ps

module events(
	input  wire        rst,
	input  wire        clk,

	input  wire        event_nvram_dump,
	input  wire [23:0] initials,
	input  wire        event_wave_change,
	input  wire [ 7:0] wave_p1,
	input  wire        event_enforcer_spark,
	input  wire        event_score_change,
	input  wire [31:0] score_p1,
	input  wire        event_game_over,
	input  wire        event_grunt_killed_by_electrode,
	input  wire        event_human_killed,
	input  wire        event_human_saved,
	input  wire        event_still_trying,
	input  wire        event_player_death,
	input  wire        event_game_start,
	input  wire        event_boot,

	input  wire        uart_ready,
	output wire [ 7:0] uart_out,
	output wire        uart_out_en
);

localparam EVENTS_COUNT = 12;

wire [EVENTS_COUNT-1:0] events_raw = {
	event_nvram_dump,
	event_wave_change,
	event_enforcer_spark,
	event_score_change,
	event_game_over,
	event_grunt_killed_by_electrode,
	event_human_killed,
	event_human_saved,
	event_still_trying,
	event_player_death,
	event_game_start,
	event_boot
};

reg   [7:0] fifo_wr_data;
reg         fifo_wr_en;
wire  [7:0] fifo_rd_data;
wire        fifo_rd_en;
wire        fifo_full;
wire        fifo_empty;
/*
fifo #(
   .DEPTH_WIDTH(10),
   .DATA_WIDTH(8)
) events_fifo(
	.rst(rst),
	.clk(clk),
	.wr_data_i(events_fifo_wr_data),
	.wr_en_i(events_fifo_wr_en),
	.rd_data_o(events_fifo_rd_data),
	.rd_en_i(events_fifo_rd_en),
	.full_o(events_fifo_full),
	.empty_o(events_fifo_empty)
);
*/
fifo_sync_ram #(
	.DEPTH(1024),
	.WIDTH(8)
) fifo(
	.wr_data(fifo_wr_data),
	.wr_ena(fifo_wr_en),
	.wr_full(fifo_full),
	.rd_data(fifo_rd_data),
	.rd_ena(fifo_rd_en),
	.rd_empty(fifo_empty),
	.clk(clk),
	.rst(rst)
);

assign uart_out = fifo_rd_data;
assign fifo_rd_en = !fifo_empty && uart_ready;
assign uart_out_en = !fifo_empty && uart_ready;

reg  [EVENTS_COUNT-1:0] events_new;
reg  [EVENTS_COUNT-1:0] events_old;
wire [EVENTS_COUNT-1:0] events_changes = events_old ^ events_new;	// 1 where dip switch state changed.
wire [EVENTS_COUNT-1:0] events_set = events_changes & events_new;	// 1 where dip switch state changed and NEW state is 1.
wire [EVENTS_COUNT-1:0] events_clr = events_changes & events_old;	// 1 where dip switch state changed and OLD state is 1.

reg  [EVENTS_COUNT-1:0] events_sticky;
reg  [EVENTS_COUNT-1:0] events_reset;

reg [3:0] event_byte_count;

reg [2:0] event_state;
localparam EVENT_STATE_IDLE = 3'd0,
           EVENT_STATE_SCORE_CHANGED = 3'd1,
           EVENT_STATE_WAVE_CHANGE = 3'd2,
           EVENT_STATE_NVRAM_DUMP = 3'd3,
           EVENT_STATE_RESET = 3'd7
           ;

always @(posedge clk) begin
	if(rst) begin
		events_new <= 12'h000;
		events_old <= 12'h000;
		events_sticky <= 12'h000;
		events_reset <= 12'h000;
		fifo_wr_data <= 8'h00;
		fifo_wr_en <= 1'b0;
		event_byte_count <= 0;
		event_state <= EVENT_STATE_IDLE;
	end else begin
		events_new <= events_raw;
		events_old <= events_new;
		events_sticky <= (events_sticky | events_set) & (~events_reset);

		// Defaults
		events_reset <= 0;
		fifo_wr_data <= 8'h69;
		fifo_wr_en <= 1'b0;
		event_byte_count <= 0;
		event_state <= EVENT_STATE_IDLE;

		case(event_state)
		EVENT_STATE_IDLE: begin
			casez(events_sticky)
			12'b1???_????_????: begin	// Event: NVRAM Dump
				fifo_wr_data <= 8'hfb;
				fifo_wr_en <= 1'b1;
				event_state <= EVENT_STATE_NVRAM_DUMP;
				events_reset <= 12'b0000_0000_0000;
			end

			12'b01??_????_????: begin	// Event: Wave Change
				fifo_wr_data <= 8'hfa;
				fifo_wr_en <= 1'b1;
				event_state <= EVENT_STATE_WAVE_CHANGE;
				events_reset <= 12'b0000_0000_0000;
			end

			12'b001?_????_????: begin	// Event: Enforcer Spark
				fifo_wr_data <= 8'hf9;
				fifo_wr_en <= 1'b1;
				event_state <= EVENT_STATE_RESET;
				events_reset <= 12'b0010_0000_0000;
			end

			12'b0001_????_????: begin	// Event: Score Changed
				fifo_wr_data <= 8'hf8;
				fifo_wr_en <= 1'b1;
				event_state <= EVENT_STATE_SCORE_CHANGED;
				events_reset <= 12'b0000_0000_0000;
			end

			12'b0000_1???_????: begin	// Event: Game Over
				fifo_wr_data <= 8'hf7;
				fifo_wr_en <= 1'b1;
				event_state <= EVENT_STATE_RESET;
				events_reset <= 12'b0000_1000_0000;
			end

			12'b0000_01??_????: begin	// Event: Grunt Killed by Electrode
				fifo_wr_data <= 8'hf6;
				fifo_wr_en <= 1'b1;
				event_state <= EVENT_STATE_RESET;
				events_reset <= 12'b0000_0100_0000;
			end

			12'b0000_001?_????: begin	// Event: Human Killed
				fifo_wr_data <= 8'hf5;
				fifo_wr_en <= 1'b1;
				event_state <= EVENT_STATE_RESET;
				events_reset <= 12'b0000_0010_0000;
			end

			12'b0000_0001_????: begin	// Event: Human Saved
				fifo_wr_data <= 8'hf4;
				fifo_wr_en <= 1'b1;
				event_state <= EVENT_STATE_RESET;
				events_reset <= 12'b0000_0001_0000;
			end

			12'b0000_0000_1???: begin	// Event: Still Trying
				fifo_wr_data <= 8'hf3;
				fifo_wr_en <= 1'b1;
				event_state <= EVENT_STATE_RESET;
				events_reset <= 12'b0000_0000_1000;
			end

			12'b0000_0000_01??: begin	// Event: Player Death
				fifo_wr_data <= 8'hf2;
				fifo_wr_en <= 1'b1;
				event_state <= EVENT_STATE_RESET;
				events_reset <= 12'b0000_0000_0100;
			end

			12'b0000_0000_001?: begin	// Event: Game Start
				fifo_wr_data <= 8'hf1;
				fifo_wr_en <= 1'b1;
				event_state <= EVENT_STATE_RESET;
				events_reset <= 12'b0000_0000_0010;
			end

			12'b0000_0000_0001: begin	// Event: Boot
				fifo_wr_data <= 8'hf0;
				fifo_wr_en <= 1'b1;
				event_state <= EVENT_STATE_RESET;
				events_reset <= 12'b0000_0000_0001;
			end

			default: begin
				fifo_wr_data <= 8'haa;
				fifo_wr_en <= 1'b0;
				event_state  <= EVENT_STATE_IDLE;
				events_reset <= 12'b0000_0000_0000;
			end

			endcase
		end

		EVENT_STATE_SCORE_CHANGED: begin
			case(event_byte_count)
			0: fifo_wr_data <= score_p1[31:24];
			1: fifo_wr_data <= score_p1[23:16];
			2: fifo_wr_data <= score_p1[15: 8];
			3: fifo_wr_data <= score_p1[ 7: 0];
			endcase

			fifo_wr_en <= 1'b1;

			if(event_byte_count == 3) begin
				event_state  <= EVENT_STATE_RESET;
				events_reset <= 12'b0001_0000_0000;
			end else begin
				event_state  <= EVENT_STATE_SCORE_CHANGED;
				events_reset <= 12'b0;
			end

			event_byte_count <= event_byte_count + 1;
		end

		EVENT_STATE_WAVE_CHANGE: begin
			fifo_wr_data <= wave_p1;
			fifo_wr_en <= 1'b1;
			event_state <= EVENT_STATE_RESET;
			events_reset <= 12'b0100_0000_0000;
		end

		EVENT_STATE_NVRAM_DUMP: begin
			case(event_byte_count)
			0: fifo_wr_data <= score_p1[31:24];
			1: fifo_wr_data <= score_p1[23:16];
			2: fifo_wr_data <= score_p1[15: 8];
			3: fifo_wr_data <= score_p1[ 7: 0];
			4: fifo_wr_data <= initials[23:16];
			5: fifo_wr_data <= initials[15: 8];
			6: fifo_wr_data <= initials[ 7: 0];
			endcase

			fifo_wr_en <= 1'b1;

			if(event_byte_count == 6) begin
				event_state  <= EVENT_STATE_RESET;
				events_reset <= 12'b1000_0000_0000;
			end else begin
				event_state  <= EVENT_STATE_NVRAM_DUMP;
				events_reset <= 12'b0;
			end

			event_byte_count <= event_byte_count + 1;
		end

		EVENT_STATE_RESET: begin
			fifo_wr_data <= 8'h77;
			fifo_wr_en <= 1'b0;
			event_state  <= EVENT_STATE_IDLE;
			events_reset <= 12'b0000_0000_0000;
		end

		default: begin
			fifo_wr_data <= 8'h55;
			fifo_wr_en <= 1'b0;
			event_state  <= EVENT_STATE_IDLE;
			events_reset <= 12'b0000_0000_0000;
		end

		endcase
	end
end

endmodule
