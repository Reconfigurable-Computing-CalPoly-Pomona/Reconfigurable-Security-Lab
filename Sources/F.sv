`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2019 04:05:58 PM
// Design Name: 
// Module Name: F
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


module F #(parameter CWIDTH = 320, parameter XWORDS32 = 9, parameter DS_WIDTH = 4,
            parameter RWIDTH = 32, parameter ROUND_COUNT = 10, parameter IWIDTH = 128) (
    input logic clk, reset,
    input logic [CWIDTH-1:0] c,
    input logic [XWORDS32*32-1:0] x,
    input logic [IWIDTH-1:0] i,
    input logic [DS_WIDTH-1:0] ds,
    input logic [ROUND_COUNT-1:0] rounds,
    output logic [CWIDTH-1:0] cout,
    output logic [XWORDS32*32-1:0] xout,
    output logic [RWIDTH-1:0] rout,
    output logic done
    );
    
    logic [CWIDTH-1:0] cReg;
    logic mixDone;
    
    assign xout = x;
    
    Mix128 #(.CWIDTH(CWIDTH), .XWORDS32(XWORDS32), .DS_WIDTH(DS_WIDTH)) mix (
        .c(c),
        .i(i),
        .x(x),
        .ds(ds),
        .clk(clk),
        .reset(reset),
        .done(mixDone),
        .cout(cReg)
    );
    
    G #(.CWIDTH(CWIDTH), .RWIDTH(RWIDTH), .ROUND_COUNT(ROUND_COUNT)) g (
        .c(cReg),
        .rout(rout),
        .cout(cout),
        .clk(clk),
        .reset(reset | ~mixDone),
        .done(done),
        .rounds(rounds)
    );
endmodule
