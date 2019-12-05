`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2019 10:26:50 PM
// Design Name: 
// Module Name: select
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
/*
Input:
i: multi bit input,
width: number of bits of the output,
index: scaled index

Output:
part: bits from i from (width?index) to width?(index+ 1)-1

*/

/*
function [320-1:0] mixsx32;
    input [320-1:0] c;
    input [128-1:0] x;
    input [10-1:0] d;
    reg [320-1:0] co;
    reg [2-1:0] idx;
    reg [32-1:0] xw;
    integer j;
begin
    co = c;
    for(j=0;j<5;j=j+1) begin
        idx = d[j*2+:2];
        xw = x[idx*32+:32];
        co[j*2*32+:32] = co[j*2*32+:32] ^ xw;
    end
    mixsx32 = co;
end
endfunction
*/


module select #(parameter INPUT_WIDTH = 8, parameter OUT_WIDTH = 4) (
    input logic [INPUT_WIDTH-1:0] inputVal,
    input logic [$clog2(INPUT_WIDTH/OUT_WIDTH) - 1: 0] index,
    output logic [OUT_WIDTH-1:0] out,
    input logic reset
    );
    
    always_comb
    if (reset)
        out = 0;
    else
        out = inputVal[OUT_WIDTH*index +: OUT_WIDTH];    
       

endmodule
//module select (
//    input logic [320-1:0] c,
//    input logic [128-1:0] x,
//    input logic [10-1:0] d,
//    output logic [320-1:0] cout
//    );
    
//    logic [320-1:0] co;
//    logic [2-1:0] idx;
//    logic [32-1:0] xw;
//    integer j;
    
//    always_comb begin
//        cout = c;
//        for(j=0;j<5;j=j+1) begin
//            idx = d[j*2+:2];
//            xw = x[idx*32+:32];
//            co[j*2*32+:32] = co[j*2*32+:32] ^ xw;
//        end
//        cout = co;
//    end
    
    
//endmodule
