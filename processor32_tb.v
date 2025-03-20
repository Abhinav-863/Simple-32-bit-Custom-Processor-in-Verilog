`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2025 12:03:40 PM
// Design Name: 
// Module Name: processor32_tb
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
module processor32_tb ();
    reg clk, rst;
    reg [15:0] din;
    wire [15:0] dout;
    

    processor32 dut(.clk(clk), 
    .rst(rst), 
    .din(din), 
    .dout(dout)
    );

    always #5 clk = ~clk;

    initial begin
        rst = 1'b1;
        clk = 1'b1;
        #5;
        rst = 1'b0;      
        #1000;
        $finish;
    end
endmodule
