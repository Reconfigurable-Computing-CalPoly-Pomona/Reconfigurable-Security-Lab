`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2019 08:32:25 PM
// Design Name: 
// Module Name: BiRotR
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


module BiRotR(
    input logic [63:0] in,
    input logic [$clog2(64)-1:0] shift,
    output logic [63:0] out
);

    logic [31:0] i0, i1, t;
    logic [5:0] shift2;
    logic [31:0] a1,a2;
    logic [4:0] amt1, amt2;
//    logic lr1, lr2;
    logic [31:0] y1, y2;
        
    always_comb begin
        shift2 = shift/2;
        i0 =  in[31:0];
        i1 = in[63:32];
        
        if (shift & 1) begin
            a1 = i1;
            amt1 = shift2;
            t = y1;
            
            a2 = i0;
            amt2 = ((shift2+1) % 32);
            i1 = y2;
            i0 = t;            
        end
        
        else begin
            a1 = i0;
            amt1 = shift2;
            i0 = y1;
            
            a2 = i1;
            amt2 = (shift2);
            i1 = y2;
        end
        
        out = {i1,i0};        
    end
    
    double_shifter_fullPara_top #(.N(5)) shifter1 (
        .a(a1),
        .amt(amt1),
        .lr(1'b1),
        .y(y1)
    );
    
    double_shifter_fullPara_top #(.N(5)) shifter2 (
        .a(a2),
        .amt(amt2),
        .lr(1'b1),
        .y(y2)
    );
    

    
endmodule
