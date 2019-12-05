`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2019 12:00:12 AM
// Design Name: 
// Module Name: absorb
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


module absorb #(parameter CWIDTH = 320, parameter RWIDTH = 32, parameter XWIDTH = 64,
                parameter BWIDTH = 32, parameter NUMBLOCKS = 4) 
    (
        input logic [CWIDTH-1:0] c,
        input logic [RWIDTH-1:0] r,
        input logic [XWIDTH-1:0] x,
        input logic [(BWIDTH*NUMBLOCKS)-1:0] blocks,
        input logic padded, finalize, clk, reset,
        input logic [1:0] domain,
        output logic [CWIDTH-1:0] cout,
        output logic [RWIDTH-1:0] rout,
        output logic [XWIDTH-1:0] xout 
    );
    
    localparam IWIDTH = 128;
    localparam B = BWIDTH/IWIDTH;
    
    logic fdone, func_en, count_valid, increment;
    logic [127:0] ds;
    logic [127:0] f_ds;
    logic [BWIDTH-1:0] f_dataIn;
    logic [CWIDTH-1:0] cReg, f_cout;
    logic [RWIDTH-1:0] rReg, f_rout;
    logic [$clog2(B-1):0] i;
    
    
    assign func_en = (B>0) ? 1:0;
    assign count_valid = (i < B-1) ? 1:0;
    
    always_latch 
        if (increment) i = i + 1;
    

    always_latch begin
        if (func_en) begin
            if (count_valid) begin
                       
            end  
            
        end
    
    end
    
    
    F #(.XWORDS32(XWIDTH/32), .DS_WIDTH(128), .ROUND_COUNT(128)) (
        .clk(clk),
        .reset(reset),
        .c(c),
        .x(x),
        .xout(xout),
        .rout(f_rout),
        .cout(f_cout),
        .i(f_dataIn),
        .rounds(0), //how are number of rounds calculated again? design parameter?
        .ds(f_ds),
        .done(fdone)

    );
endmodule
