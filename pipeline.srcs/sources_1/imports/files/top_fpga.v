`timescale 1ns / 1ps

module top_fpga #(
    parameter IMEMSIZE = 4096,
    parameter DMEMSIZE = 4096
)(
    input  wire clk,
    input  wire reset,
    output [15:0] led
);

wire exception;

////////////////////////////////////////////////////////////
// Slow clock generator (clock divider)
////////////////////////////////////////////////////////////
reg [25:0] clk_cnt;
reg        slow_clk;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        clk_cnt  <= 26'd0;
        slow_clk <= 1'b0;
    end else begin
        if (clk_cnt == 26'd49_999_999) begin
            clk_cnt  <= 26'd0;
            slow_clk <= ~slow_clk;
        end else begin
            clk_cnt <= clk_cnt + 1'b1;
        end
    end
end
reg reset_sync;
always @(posedge slow_clk or posedge reset) begin
    if (reset)
        reset_sync <= 1'b0;   // instantly asserts when button pressed
    else
        reset_sync <= 1'b1;   // only deasserts on a slow_clk edge
end
////////////////////////////////////////////////////////////
// PIPE ↔ MEMORY WIRES
////////////////////////////////////////////////////////////
wire [31:0] inst_mem_read_data;
wire        inst_mem_is_valid;
wire [31:0] dmem_read_data;
wire        dmem_write_valid;
wire        dmem_read_valid;
wire [31:0] pc_out_wire;
wire [31:0] inst_mem_address;
wire        dmem_read_ready;
wire [31:0] dmem_read_address;
wire        dmem_write_ready;
wire [31:0] dmem_write_address;
wire [31:0] dmem_write_data;
wire [ 3:0] dmem_write_byte;

assign inst_mem_is_valid = 1'b1;
assign dmem_write_valid  = 1'b1;
assign dmem_read_valid   = 1'b1;
assign led               = pc_out_wire[15:0];

////////////////////////////////////////////////////////////
// PIPELINE CPU
////////////////////////////////////////////////////////////
pipe pipe_u (
    .clk                    (slow_clk),
    .reset                  (reset_sync),
    .stall                  (1'b0),
    .exception              (exception),
    .inst_mem_is_valid      (inst_mem_is_valid),
    .inst_mem_read_data     (inst_mem_read_data),
    .dmem_read_data_temp    (dmem_read_data),
    .dmem_write_valid       (dmem_write_valid),
    .dmem_read_valid        (dmem_read_valid),
    .pc_out                 (pc_out_wire),
    .inst_mem_address_out   (inst_mem_address),
    .dmem_read_ready_out    (dmem_read_ready),
    .dmem_read_address_out  (dmem_read_address),
    .dmem_write_ready_out   (dmem_write_ready),
    .dmem_write_address_out (dmem_write_address),
    .dmem_write_data_out    (dmem_write_data),
    .dmem_write_byte_out    (dmem_write_byte)
);

////////////////////////////////////////////////////////////
// INSTRUCTION MEMORY
////////////////////////////////////////////////////////////
instr_mem IMEM (
    .clk   (clk),
    .pc    (inst_mem_address),
    .instr (inst_mem_read_data)
);

////////////////////////////////////////////////////////////
// DATA MEMORY
////////////////////////////////////////////////////////////
data_mem DMEM (
    .clk   (clk),
    .re    (dmem_read_ready),
    .raddr (dmem_read_address),
    .rdata (dmem_read_data),
    .we    (dmem_write_ready),
    .waddr (dmem_write_address),
    .wdata (dmem_write_data),
    .wstrb (dmem_write_byte)
);

endmodule