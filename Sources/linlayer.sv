`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2019 08:07:09 PM
// Design Name: 
// Module Name: linlayer
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


module linlayer #(parameter CWORDS64 = 9) (
    input logic [CWORDS64*64-1:0] c,
    output logic [CWORDS64*64-1:0] cout,
    input logic clk, reset,
    output logic done
    
);
    localparam [5:0] lut0 [8:0] = {6'd19,6'd61,6'd1,6'd10, 6'd7,6'd31,6'd53, 6'd9,6'd43};
    localparam [5:0] lut1 [8:0] = {6'd28,6'd38,6'd6,6'd17, 6'd40,6'd26,6'd58, 6'd46,6'd50};
    
    logic [3:0] i;
    logic [5:0] r0, r1;
    logic [63:0] w, rot1, rot2;
    logic [CWORDS64*64-1:0] cout_reg;
    
    assign cout = cout_reg;
    assign done = (i >= CWORDS64) ? 1:0;
    //register block for iterator
    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            i <= 0;
        else if (i >= CWORDS64) i <= i;
        else i <= i + 1;
    end
    
    //block for r0 and r1
    assign r0 = lut0[i];
    assign r1 = lut1[i];
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) cout_reg <= 0;
        else if (i >= CWORDS64) cout_reg <= cout_reg;
        else cout_reg[(i*64) +: 64] <= w ^ rot1 ^ rot2;
    end
    
    
    selec_t #(.INPUT_WIDTH(576), .OUT_WIDTH(64)) selC (
        .inputVal(c),
        .reset(reset),
        .index(i),
        .out1(w)
    );
    
    BiRotR first (
        .in(w),
        .shift(r0),
        .out(rot1)   
    );
    
    BiRotR second (
        .in(w),
        .shift(r1),
        .out(rot2)   
    );
    
    
    
endmodule
