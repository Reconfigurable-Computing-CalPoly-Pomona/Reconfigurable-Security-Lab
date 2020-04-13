`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2020 07:14:52 PM
// Design Name: 
// Module Name: Accumulator
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


module ALU(
    input logic[63:0] a, b,
    input logic[1:0] mode,
    output logic[63:0] y
    );
    
    always_comb begin
        case(mode)
            0: y = a ^ b;
            1: y = ~a & b;
            2: y = ~a;
            default: y = 0;
        endcase
    end
endmodule
