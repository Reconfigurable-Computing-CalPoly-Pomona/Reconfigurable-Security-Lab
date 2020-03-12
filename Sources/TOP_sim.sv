`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2020 04:31:06 PM
// Design Name: 
// Module Name: TOP_sim
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


module TOP_sim();
    logic clk, rst, TAG, done;
    logic [15:0] SW;
    logic [6:0] Seg;
    logic [7:0] An;
    
    top_mod uut(clk,rst,done,TAG,SW,Seg,An);

    
    always begin
        clk = 1'b0;
        #(5);
        clk = 1'b1;
        #(5);
    end
    
    initial begin
        SW = 16'b0000000000000000;
        rst = 1'b1;
        #(10);
        rst = 1'b0;
        #(100)
        wait(done);
        #20000000
        rst = 1'b1;
        #(10);
        rst = 1'b0;
        #(100)
        wait(done);
    end
endmodule
