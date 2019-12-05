`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2019 02:43:44 PM
// Design Name: 
// Module Name: double_shifter_fullPara_top
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/27/2019 09:16:46 PM
// Design Name: 
// Module Name: doubleShifter16_top
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


module double_shifter_fullPara_top #(parameter N = 3)
    (
        input logic [2**N-1:0] a,
        input logic [N-1:0] amt,
        input logic lr,
        output logic [2**N-1:0] y
    );
    
    logic [2**N-1:0] rightOut, leftOut;
    
    shifter_para #(.N(N)) rightShifter 
    (
        .a(a),
        .amt(amt),
        .y(rightOut)
    );
    
    leftShifter_para #(.N(N)) leftShifter 
    (
        .a(a),
        .amt(amt),
        .y(leftOut)
    );
    
    
    mux_2x1 #(.N(2**N)) mux1 
    (
        .a(leftOut),
        .b(rightOut),
        .sel(lr),
        .y(y)
    );
endmodule

