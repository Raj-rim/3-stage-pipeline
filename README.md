This repository contains the design and implementation of a 3-stage pipelined processor based on the RISC-V (RV32I) Instruction Set Architecture. Developed under the guidance of Prof. Lokesh Sidhu, this project focuses on balancing stage logic to optimize clock frequency and instruction throughput.

🚀 Pipeline Architecture
The processor follows a 3-stage partition to minimize the critical path delay:

IF-ID (Instruction Fetch & Decode): Retrieves the instruction from memory using the Program Counter (PC) and decodes the opcode, funct3, and immediate values.

EX (Execute): Executes arithmetic, logical, and shift operations using the ALU. This stage also handles branch target calculations.

MEM-WB (Memory Access & Write-back): Interfaces with data memory for Load/Store operations and commits the final result back to the Register File.

🛠 Technical Features
ISA Support: Implementation of the RV32I base integer set (R, I, S, and SB-type instructions).

Pipeline Registers: Custom-designed registers between the IF-ID/EX and EX/MEM-WB boundaries to maintain state synchronization.

Hazard Handling: * Data Hazards: Implemented forwarding logic to minimize pipeline stalls.

Control Hazards: Integrated flushing mechanisms to maintain architectural integrity during branch mispredictions.

Verilog Implementation: Modular design facilitating easy debugging and synthesis for FPGA platforms.

📂 Repository Structure
Plaintext
├── src/                
│   ├── fetch_decode.v  # IF-ID stage logic
│   ├── execute.v       # EX stage / ALU
│   ├── mem_wb.v        # MEM-WB stage / Register File write-back
│   ├── hazard_unit.v   # Forwarding and Stall logic
│   └── processor.v     # Top-level integration
├── testbench/          # Testbench modules
├── hex/                # Compiled RISC-V assembly test cases
└── README.md           
💻 Simulation & Verification
Prerequisites
A Verilog simulator (e.g., Icarus Verilog, Vivado, or ModelSim).

GTKWave for waveform analysis.

Execution Steps
Bash
# Compile source and testbench
iverilog -o riscv_sim testbench/processor_tb.v src/*.v

# Run simulation
vvp riscv_sim

# View signals in GTKWave
gtkwave dump.vcd
🤝 Acknowledgments
Special thanks to Prof. Lokesh Sidhu for his guidance on architectural trade-offs and pipeline hazard mitigation strategies.
