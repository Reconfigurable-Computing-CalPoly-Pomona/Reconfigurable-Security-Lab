`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2019 09:49:00 PM
// Design Name: 
// Module Name: Gascon_Core_Round
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


module Gascon_Core_Round #(parameter CWIDTH = 320, parameter ROUND_COUNT = 16)(
    input logic [CWIDTH-1:0] c,
    output logic [CWIDTH-1:0] cout,
    input logic [ROUND_COUNT-1:0] round,
    input logic reset,
    input logic clk,
    output logic done
    );
    
    integer mask=4'hf;
    localparam CWORDS64 = CWIDTH/64;
    localparam MID = (CWORDS64-1)/2;
    localparam c64 = 64;
    logic [c64-1:0] c_reg;
//    logic [CWIDTH-1:0] c_reg_select;
    logic [CWIDTH-1:0] c_reg_int;
    logic [CWIDTH-1:0] c_reg_sbox;
    logic [c64-1:0] shift_reg; 
    logic linlayer_en;
    
    
    
    always_comb
    begin
        if (~reset) begin
            c_reg_int = c;
            shift_reg=((mask - round) << 4);
            shift_reg = shift_reg | round;
            c_reg_int[MID*64 +: 64] = shift_reg^c_reg;
        end
    end
    
    select #(.INPUT_WIDTH(CWIDTH), .OUT_WIDTH(64)) select1 (
        .inputVal(c),
        .index(MID),
        .out(c_reg),
        .reset(reset)
    );
    
   
    sbox #(.CWIDTH(CWIDTH)) sBOX (
        .c(c_reg_int),
        .cout(c_reg_sbox),
        .reset(reset),
        .clk(clk),
        .doneOut(linlayer_en)
    );
    
    linlayer #(.CWORDS64(CWORDS64)) LINLAYER_DUDE (
        .c(c_reg_sbox),
        .cout(cout),
        .clk(clk), 
        .reset(reset | ~linlayer_en),
        .done(done)
    );
endmodule
