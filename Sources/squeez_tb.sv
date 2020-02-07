`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/06/2020 06:49:47 PM
// Design Name: 
// Module Name: squeez_tb
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


module squeez_tb();

    localparam CWIDTH = 320;
    localparam RWIDTH = 32;
    localparam DATA_SIZE = 32;
    localparam REMAINWIDTH = 20;
    localparam ROUND_COUNT = 10;
    
    logic clk, reset;
    logic seldone, Gdone;
    logic [CWIDTH-1:0] c; // capacity
    logic [CWIDTH-1:0] Bdata; //output data
    logic [RWIDTH-1:0] r; // state I think
    logic [REMAINWIDTH-1:0] remaining;
    logic [ROUND_COUNT-1:0] rounds;
    logic squeezDone;
    
    squeez #(.CWIDTH(CWIDTH), .RWIDTH(RWIDTH),
        .DATA_SIZE(DATA_SIZE),
        .REMAINWIDTH(REMAINWIDTH),
        .ROUND_COUNT(ROUND_COUNT))
        squeeze_me_daddy
        (.*);
    
    always begin
        clk = 1'b1;
        #(5);
        clk = 1'b0;
        #(5);
    end
    
    initial begin
        reset = 1'b1;
        #(5);
        reset = 1'b0;
    end
    
    initial begin
        c = 320'h000000000000000000012de0000f3bf70803c003b00095d1000000000000000000012de0000f3bf70;
        r = 32'h79657370;   
        rounds = 0;
        remaining = 64;
        wait(squeezDone);
    end
endmodule
