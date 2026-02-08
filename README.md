# RISC-V Processor

A 5-stage pipelined 32-bit RISC-V processor implemented in VHDL, featuring full ASIC design flow support including synthesis, placement, and routing.

![RISC-V](https://img.shields.io/badge/ISA-RISC--V-blue)
![VHDL](https://img.shields.io/badge/Language-VHDL-orange)
![45nm](https://img.shields.io/badge/Technology-45nm-green)

## Overview

This project implements a subset of the RV32I base integer instruction set. The processor uses a classic 5-stage pipeline architecture designed for educational purposes and ASIC implementation.

### Key Features

- **32-bit RISC-V architecture** (RV32I base integer instruction set)
- **5-stage pipeline**: Fetch → Decode → Execute → Memory → Write Back
- **32 general-purpose registers** (x0-x31, with x0 hardwired to zero)
- **Full ALU** supporting arithmetic, logical, shift, and comparison operations
- **Branch and jump instructions** with target address calculation
- **Memory interface** for instruction and data memory access
- **DFT support** (Design for Testability) with scan chain

### Specifications

| Parameter | Value |
|-----------|-------|
| Data Width | 32 bits |
| Register File | 32 x 32-bit registers |
| Memory Address Width | 9 bits |
| Reset Vector | 0x00000000 |
| Cell Count | ~1,861 cells |
| Total Area | ~7,815 µm² (45nm) |

## Architecture

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌────────────┐
│  FETCH  │───▶│ DECODE  │───▶│ EXECUTE │───▶│ MEMORY  │───▶│ WRITE BACK │
│         │    │         │    │         │    │ ACCESS  │    │            │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └────────────┘
     │              │              │              │               │
  Instruction   Register       ALU Ops        Load/Store      Register
   Fetch         File          Branch          Memory          Write
```

### Pipeline Stages

1. **Fetch (IF)**: Fetches instruction from memory, manages program counter
2. **Decode (ID)**: Decodes instruction, reads register file, generates immediate values
3. **Execute (EX)**: Performs ALU operations, calculates branch targets
4. **Memory Access (MEM)**: Handles load/store operations with data memory
5. **Write Back (WB)**: Writes results back to register file

### Supported Instructions

| Category | Instructions |
|----------|-------------|
| Arithmetic | ADD, SUB, ADDI |
| Logical | AND, OR, XOR, ANDI, ORI, XORI |
| Shift | SLL, SRL, SRA, SLLI, SRLI, SRAI |
| Compare | SLT, SLTU, SLTI, SLTIU |
| Branch | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| Jump | JAL, JALR |
| Memory | LW, SW |
| Upper Immediate | LUI, AUIPC |

## Project Structure

```
RISCV-Processor/
├── sources/                    # VHDL source files
│   ├── riscv_core.vhd         # Top-level processor core
│   ├── riscv_pkg.vhd          # Package with constants and components
│   ├── fetch.vhd              # Instruction fetch stage
│   ├── decode.vhd             # Instruction decode stage
│   ├── execute.vhd            # Execute stage
│   ├── memory_access.vhd      # Memory access stage
│   ├── write_back.vhd         # Write back stage
│   ├── riscv_alu.vhd          # Arithmetic Logic Unit
│   ├── riscv_rf.vhd           # Register File
│   ├── riscv_pc.vhd           # Program Counter
│   ├── riscv_adder.vhd        # Parameterized adder
│   └── tb_*.vhd               # Testbenches
├── simulation/                 # Simulation files
│   ├── *.S                    # RISC-V assembly test programs
│   ├── *.mem                  # Memory initialization files
│   └── sim_*.tcl              # Simulation scripts
├── implementation/            # ASIC implementation
│   ├── syn/                   # Synthesis outputs
│   │   ├── base_netlist/      # Synthesized netlists
│   │   └── base_reports/      # Synthesis reports
│   └── pnr/                   # Place and route outputs
│       ├── base_netlist/      # P&R netlists
│       └── base_reports/      # Timing and DRC reports
├── constraints/               # Design constraints
└── asm/                       # Assembly tools
```

## Getting Started

### Prerequisites

- **Simulation**: ModelSim or QuestaSim
- **Synthesis**: Cadence Genus
- **Place & Route**: Cadence Innovus
- **Technology**: GPDK045 (45nm)

### Simulation

1. Open the simulation project in ModelSim:
   ```tcl
   vsim -do sim_beh.tcl
   ```

2. Run a test program (e.g., Fibonacci):
   ```tcl
   # Load memory with test program
   mem load -i riscv_fibo.mem /tb_riscv_core/imem
   run -all
   ```

### Synthesis

Run synthesis using Genus:
```bash
genus -f genus.cmd1
```

### Place and Route

After synthesis, run place and route with Innovus:
```bash
innovus -init innovus_setup.tcl
```

## Test Programs

The `simulation/` directory contains example RISC-V assembly programs:

- **riscv_basic.S**: Basic instruction tests
- **riscv_fibo.S**: Fibonacci sequence calculation (tests up to F(20) = 6765)

## Results

### Synthesis Results (45nm GPDK)
- **Cell Count**: 1,861 cells
- **Total Area**: 7,815.14 µm²
- **Operating Conditions**: 0.9V, 125°C (worst case)

## License

This project is available for educational and personal use.

## Acknowledgments

- RISC-V Foundation for the open ISA specification
- Cadence for the GPDK045 educational PDK
