`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2025 12:02:31 PM
// Design Name: 
// Module Name: processor32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//Dividing IR in terms of feilds
`define opr_type IR[31:27] //32 instruction possible
`define dest_reg IR[26:22] //Destination register
`define src1_reg IR[21:17] //Source 1 register
`define imm_mode IR[16]    //Immediate mode selection
`define src2_reg IR[15:11] //Source 2 register
`define imm IR[15:0]       //Immediate value

//Arithematic instructions for opr_type
`define movsgpr 5'b00000 //Moving overflow of multiplication to general register
`define mov 5'b00001 //Move the source registers to GPR
`define add 5'b00010 //Adding the registers
`define sub 5'b00011 //Subtraction of registers
`define mul 5'b00100 //Multilication of registers

//Logical instructions for opr_type
`define ror 5'b00101 //OR operation
`define rand 5'b00110 //AND operation
`define rxor 5'b00111 //XOR operation
`define rxnor 5'b01000 //XNOR operation
`define rnand 5'b01001 //NAND operation
`define rnor 5'b01010 //NOR operation
`define rnot 5'b01011 //NOT operation

//Load and store instructions for data memory
`define store_reg 5'b01100 //Store data from register to data memory
`define store_input 5'b01101 //Load data from input buffer to data memory
`define load_reg 5'b01110 //Load data from program memory to register
`define load_output 5'b01111 //Load data from data memory to output buffer

//Jump instructions
`define jump 5'b10000 //Jump to the address
`define jump_carry 5'b10001 //Jump to the address when carry flag is high
`define jump_no_carry 5'b10010 //Jump to the address when carry flag is low
`define jump_zero 5'b10011 //Jump to the address when zero flag is high
`define jump_no_zero 5'b10100 //Jump to the address when zero flag is low
`define jump_sign 5'b10101 //Jump to the address when sign flag is high
`define jump_no_sign 5'b10110 //Jump to the address when sign flag is low
`define jump_overflow 5'b10111 //Jump to the address when overflow flag is high
`define jump_no_overflow 5'b11000 //Jump to the address when overflow flag is low

//Halt
`define halt 5'b11001 //Halt the program and processors stays in halt state untill reset is not applied

module processor32 #(
    parameter IDLE = 0,
    parameter FETCH_INSTRUCTION = 1,
    parameter DECODE_EXECUTE_INSTRUCTION = 2,
    parameter DELAY_NEXT_INSTRUCTION = 3,
    parameter NEXT_INSTRUCTION = 4,
    parameter SENSE_HALT = 5
)(
    input clk, rst,
    input [15:0] din,
    output reg [15:0] dout
);
    reg [31:0] IR; //Instruction register
    reg [15:0] GPR [31:0]; //Genral purpose register we have taken 32 registers because in destination reg we have choosen 5 bits in IR. 16 bits are for immediate value and that is maximum possible value here
    reg [15:0] SGPR;
    reg [31:0] mul_result;
    reg sign = 0, overflow = 0, zero = 0, carry = 0;
    reg jump_flag = 0;
    reg stop = 0;
    reg [16:0] temp_add;

    //Harvard Architecture
    reg [31:0] instruction_memory [15:0]; //Program memory array
    reg [15:0] data_memory [15:0]; //Data memory array

    task decode_instruction();
        begin //Converted always block ALU block to task block to reduce complexity
            jump_flag = 1'b0;
            stop = 1'b0;
            case(`opr_type)
                `movsgpr: begin
                    GPR[`dest_reg] = SGPR;
                end
                `mov: begin
                    if(`imm_mode) begin
                        GPR[`dest_reg] = `imm;
                    end
                    else begin
                        GPR[`dest_reg] = GPR[`src1_reg];
                    end
                end
                `add: begin
                    if(`imm_mode) begin
                        GPR[`dest_reg] = GPR[`src1_reg] + `imm;
                    end
                    else begin
                        GPR[`dest_reg] = GPR[`src1_reg] + GPR[`src2_reg];
                    end
                end
                `sub: begin
                    if(`imm_mode) begin
                        GPR[`dest_reg] = GPR[`src1_reg] - `imm;
                    end
                    else begin
                        GPR[`dest_reg] = GPR[`src1_reg] - GPR[`src2_reg];
                    end
                end
                `mul: begin
                    if(`imm_mode) begin
                        mul_result = GPR[`src1_reg] * `imm;
                    end
                    else begin
                        mul_result = GPR[`src1_reg] * GPR[`src2_reg];
                    end
                    SGPR = mul_result[31:16];
                    GPR[`dest_reg] = mul_result[15:0];
                end
                `ror: begin
                    if(`imm_mode) begin
                        GPR[`dest_reg] = GPR[`src1_reg] | `imm;
                    end
                    else begin
                        GPR[`dest_reg] = GPR[`src1_reg] | GPR[`src2_reg];
                    end
                end
                `rand: begin
                    if(`imm_mode) begin
                        GPR[`dest_reg] = GPR[`src1_reg] & `imm;
                    end
                    else begin
                        GPR[`dest_reg] = GPR[`src1_reg] & GPR[`src2_reg];
                    end
                end
                `rxor: begin
                    if(`imm_mode) begin
                        GPR[`dest_reg] = GPR[`src1_reg] ^ `imm;
                    end
                    else begin
                        GPR[`dest_reg] = GPR[`src1_reg] ^ GPR[`src2_reg];
                    end
                end
                `rxnor: begin
                    if(`imm_mode) begin
                        GPR[`dest_reg] = ~(GPR[`src1_reg] ^ `imm);
                    end
                    else begin
                        GPR[`dest_reg] = ~(GPR[`src1_reg] ^ GPR[`src2_reg]);
                    end
                end
                `rnand: begin
                    if(`imm_mode) begin
                        GPR[`dest_reg] = ~(GPR[`src1_reg] & `imm);
                    end
                    else begin
                        GPR[`dest_reg] = ~(GPR[`src1_reg] & GPR[`src2_reg]);
                    end
                end
                `rnor: begin
                    if(`imm_mode) begin
                        GPR[`dest_reg] = ~(GPR[`src1_reg] | `imm);
                    end
                    else begin
                        GPR[`dest_reg] = ~(GPR[`src1_reg] | GPR[`src2_reg]);
                    end
                end
                `rnot: begin
                    if(`imm_mode) begin
                        GPR[`dest_reg] = ~(`imm);
                    end
                    else begin
                        GPR[`dest_reg] = ~(GPR[`src1_reg]);
                    end
                end
                `store_reg: begin
                    data_memory[`dest_reg] = GPR[`src1_reg];
                end
                `store_input: begin
                    data_memory[`imm] = din;
                end
                `load_reg: begin
                    GPR[`dest_reg] = data_memory[`imm];
                end
                `load_output: begin
                    dout = data_memory[`imm];
                end
                `jump: begin
                    jump_flag = 1'b1;
                end
                `jump_carry: begin
                    if(carry == 1'b1) begin
                        jump_flag = 1'b1;
                    end
                    else begin
                        jump_flag = 1'b0;
                    end
                end
                `jump_no_carry: begin
                    if(carry == 1'b0) begin
                        jump_flag = 1'b1;
                    end
                    else begin
                        jump_flag = 1'b0;
                    end
                end
                `jump_zero: begin
                    if(zero == 1'b0) begin
                        jump_flag = 1'b1;
                    end
                    else begin
                        jump_flag = 1'b0;
                    end
                end
                `jump_no_zero: begin
                    if(zero == 1'b1) begin
                        jump_flag = 1'b1;
                    end
                    else begin
                        jump_flag = 1'b0;
                    end
                end
                `jump_sign: begin
                    if(sign == 1'b1) begin
                        jump_flag = 1'b1;
                    end
                    else begin
                        jump_flag = 1'b0;
                    end
                end
                `jump_no_sign: begin
                    if(sign == 1'b0) begin
                        jump_flag = 1'b1;
                    end
                    else begin
                        jump_flag = 1'b0;
                    end
                end
                `jump_overflow: begin
                    if(overflow == 1'b1) begin
                        jump_flag = 1'b1;
                    end
                    else begin
                        jump_flag = 1'b0;
                    end
                end
                `jump_no_overflow: begin
                    if(overflow == 1'b0) begin
                        jump_flag = 1'b1;
                    end
                    else begin
                        jump_flag = 1'b0;
                    end
                end
                `halt: begin
                    stop = 1'b1;
                end
            endcase
        end
    endtask

    //For flags
    task decode_condition_flags(); 
        begin
            //Sign flag
            if(`opr_type == `mul) begin
                sign = SGPR[15];
            end
            else begin
                sign = GPR[`dest_reg][15];
            end

            //Carry flag
            if(`opr_type == `add) begin
                if(`imm_mode) begin
                    temp_add = GPR[`src1_reg] + `imm;
                    carry = temp_add[16];
                end
                else begin
                    temp_add = GPR[`src1_reg] + GPR[`src2_reg];
                    carry = temp_add[16];
                end
            end
            else begin
                carry = 1'b0;
            end

            //Zero flag
            if(`opr_type == `mul) begin 
                zero = ~(|(SGPR[15]) | (|(GPR[`dest_reg])));  //zero = ~(|result)
            end
            else begin
                zero = ~(|(GPR[`dest_reg]));
            end

            //Overflow flag
            if(`opr_type == `add) begin
                if(`imm_mode) begin
                    overflow = (~GPR[`src1_reg][15] & ~IR[15] & GPR[`dest_reg][15]) | (GPR[`src1_reg][15] & IR[15] & ~GPR[`dest_reg][15]);
                end
                else begin
                    overflow = (~GPR[`src1_reg][15] & ~GPR[`src2_reg][15] & GPR[`dest_reg][15]) | (GPR[`src1_reg][15] & GPR[`src2_reg][15] & ~GPR[`dest_reg][15]);
                end
            end
            else if (`opr_type == `sub) begin
                if(`imm_mode) begin
                    overflow = (~GPR[`src1_reg][15] & IR[15] & GPR[`dest_reg][15]) | (GPR[`src1_reg][15] & ~IR[15] & ~GPR[`dest_reg][15]);
                end
                else begin
                    overflow = (~GPR[`src1_reg][15] & GPR[`src2_reg][15] & GPR[`dest_reg][15]) | (GPR[`src1_reg][15] & ~GPR[`src2_reg][15] & ~GPR[`dest_reg][15]);
                end
            end
            else begin
                overflow = 1'b0;
            end
        end
    endtask

    //reading instruction
    initial begin
        $readmemb("D:/Xilinx/Vivado_projects/processor32/processor32.srcs/constrs_1/new/instruction_data.mem", instruction_memory); 
    end

    reg [2:0] count; //Used for delay
    integer PC; //Program Counter stores address of next instruction. It acts as address for next instruction

    initial begin
        PC = 0;
        count = 0;
    end

    reg [2:0] state = IDLE, next_state = IDLE; //State machine
    //This always block is used to change the state of FSM and set reset                                
    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    //This block is used to describe flow of FSM
    always @(*) begin
        case(state)
            IDLE: begin
                IR = 32'h0;
                PC = 0;
                next_state = FETCH_INSTRUCTION;
            end
            FETCH_INSTRUCTION: begin
                IR = instruction_memory[PC];
                next_state = DECODE_EXECUTE_INSTRUCTION;
            end
            DECODE_EXECUTE_INSTRUCTION: begin
                decode_instruction();
                decode_condition_flags();
                next_state = NEXT_INSTRUCTION;
            end
            DELAY_NEXT_INSTRUCTION: begin
                if(count < 4) begin
                    next_state = DELAY_NEXT_INSTRUCTION;
                end
                else begin
                    next_state = NEXT_INSTRUCTION;
                end
            end
            NEXT_INSTRUCTION: begin
                next_state = SENSE_HALT;
                if(jump_flag == 1) begin
                    PC = `imm;
                end
                else begin
                    PC = PC + 1;
                end
            end
            SENSE_HALT: begin
                if(stop == 1'b0) begin
                    next_state = FETCH_INSTRUCTION;
                end
                else if (rst == 1'b1) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = SENSE_HALT;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    //This always block is used to count the delay
    always @(posedge clk) begin
        case (state)
            IDLE: begin
                count <= 0;
            end
            FETCH_INSTRUCTION: begin
                count <= 0;
            end
            DECODE_EXECUTE_INSTRUCTION: begin
                count <= 0;
            end
            DELAY_NEXT_INSTRUCTION: begin
                count <= count + 1;
            end
            NEXT_INSTRUCTION: begin
                count <= 0;
            end
            SENSE_HALT: begin
                count <= 0;
            end
            default: begin
                count <= 0;
            end
        endcase
        
    end
        
endmodule