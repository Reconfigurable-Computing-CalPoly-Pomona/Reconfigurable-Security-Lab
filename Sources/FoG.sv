`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2020 04:03:08 PM
// Design Name: 
// Module Name: FoG
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


module FoG #(parameter CWIDTH = 320, parameter XWORDS32 = 9, parameter DS_WIDTH = 4,
            parameter RWIDTH = 32, parameter ROUND_COUNT = 10, parameter IWIDTH = 128) (
    input logic clk, reset, en,
    input logic [CWIDTH-1:0] c,
    input logic [XWORDS32*32-1:0] x,
    input logic [IWIDTH-1:0] i,
    input logic [DS_WIDTH-1:0] ds,
    input logic [ROUND_COUNT-1:0] rounds,
    input logic FoG,
    output logic [CWIDTH-1:0] cout,
    output logic [XWORDS32*32-1:0] xout,
    output logic [RWIDTH-1:0] rout,
    output logic done
    );
    
    logic [CWIDTH-1:0] cReg, cMix;
    logic mixDone;
    logic enMix, enG;
    assign xout = x;
    
    always_comb begin
        enMix = 1'b0;
        enG = 1'b0;
        if (en) begin
            if (FoG == 1'b0) begin
                enMix = 1'b1;
            end
            if (mixDone | (FoG == 1'b1 & ~reset)) begin
                enG = 1'b1;
            end
        end
    end
    
    always_comb begin
        if (FoG == 1'b0) begin
            cReg = cMix;
        end
        else begin
            cReg = c;
        end
    end
    
    Mix128 #(.CWIDTH(CWIDTH), .XWORDS32(XWORDS32), .DS_WIDTH(DS_WIDTH)) mix (
        .c(c),
        .i(i),
        .x(x),
        .ds(ds),
        .clk(clk),
        .reset(reset),
        .en(enMix),
        .done(mixDone),
        .cout(cMix)
    );
    
    G #(.CWIDTH(CWIDTH), .RWIDTH(RWIDTH), .ROUND_COUNT(ROUND_COUNT)) g (
        .c(cReg),
        .rout(rout),
        .cout(cout),
        .clk(clk),
        .reset(reset | (~mixDone & ~FoG)),
        .en(enG),
        .done(done),
        .rounds(rounds)
    );
endmodule
