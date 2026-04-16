`timescale 1ns / 1ps

module tb_pipeline;

////////////////////////////////////////////////////////////
// CLOCK & RESET
////////////////////////////////////////////////////////////
reg clk;
reg reset;

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 0;
    #100;
    reset = 1;
end

////////////////////////////////////////////////////////////
// PIPE ↔ MEMORY SIGNALS
////////////////////////////////////////////////////////////
wire [31:0] inst_mem_read_data;
wire        inst_mem_is_valid;
wire [31:0] pc_out;
wire [31:0] dmem_read_data;
wire        dmem_write_valid;
wire        dmem_read_valid;
wire [31:0] inst_mem_address;
wire        dmem_read_ready;
wire [31:0] dmem_read_address;
wire        dmem_write_ready;
wire [31:0] dmem_write_address;
wire [31:0] dmem_write_data;
wire [ 3:0] dmem_write_byte;
wire        exception;

assign inst_mem_is_valid = 1'b1;
assign dmem_write_valid  = 1'b1;
assign dmem_read_valid   = 1'b1;

////////////////////////////////////////////////////////////
// DUT : PIPELINE CPU
////////////////////////////////////////////////////////////
pipe DUT (
    .clk                    (clk),
    .reset                  (reset),
    .stall                  (1'b0),
    .exception              (exception),
    .inst_mem_is_valid      (inst_mem_is_valid),
    .inst_mem_read_data     (inst_mem_read_data),
    .pc_out                 (pc_out),
    .dmem_read_data_temp    (dmem_read_data),
    .dmem_write_valid       (dmem_write_valid),
    .dmem_read_valid        (dmem_read_valid),
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

////////////////////////////////////////////////////////////
// SIMULATION TIME
////////////////////////////////////////////////////////////
initial begin
    #20000;
    $finish;
end

endmodule