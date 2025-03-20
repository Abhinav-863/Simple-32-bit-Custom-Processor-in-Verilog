# Simple-32-bit-Custom-Processor-in-Verilog
This repository contains the Verilog implementation of a simple 32-bit processor. The design follows the Harvard architecture, with separate instruction and data memory. The processor supports arithmetic, logical, memory, and jump operations.

# Features
1. 32-bit instruction format with support for immediate values
2. Harvard architecture with separate instruction and data memory
3. 32 general-purpose registers (GPR)
4. Instruction set including arithmetic, logical, memory, and jump instructions
5. Pipeline state machine for instruction execution
6. Testbench for simulation and verification

# Instruction Format
Each instruction consists of 32 bits, divided as follows:

Bits	Field	Description
31-27	opr_type	Operation type (opcode)
26-22	dest_reg	Destination register
21-17	src1_reg	Source register 1
16	imm_mode	Immediate mode (1 = immediate)
15-11	src2_reg	Source register 2
15-0	imm	Immediate value (if enabled)

# Supported Instructions
# Arithmetic Operations
1. MOVSGPR - Move special register to GPR
2. MOV - Move data between registers or from immediate
3. ADD - Addition
4. SUB - Subtraction
5. MUL - Multiplication

# Logical Operations
1. ROR - OR operation
2. RAND - AND operation
3. RXOR - XOR operation
4. RXNOR - XNOR operation
5. RNAND - NAND operation
6. RNOR - NOR operation
7. RNOT - NOT operation

# Memory Operations
1. STORE_REG - Store register value to memory
2. STORE_INPUT - Store input buffer value to memory
3. LOAD_REG - Load memory value into register
4. LOAD_OUTPUT - Load memory value into output buffer

# Jump Operations
1. JUMP - Unconditional jump
2. JUMP_CARRY - Jump if carry flag is set
3. JUMP_NO_CARRY - Jump if carry flag is clear
4. JUMP_ZERO - Jump if zero flag is set
5. JUMP_NO_ZERO - Jump if zero flag is clear
6. JUMP_SIGN - Jump if sign flag is set
7. JUMP_NO_SIGN - Jump if sign flag is clear
8. JUMP_OVERFLOW - Jump if overflow flag is set
9. JUMP_NO_OVERFLOW - Jump if overflow flag is clear

# Special Instructions
1. HALT - Stop processor execution
