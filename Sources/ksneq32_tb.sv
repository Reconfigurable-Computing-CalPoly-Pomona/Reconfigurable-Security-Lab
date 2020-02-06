`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2020 09:57:46 PM
// Design Name: 
// Module Name: ksneq32_tb
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


module ksneq32_tb();
   localparam KWIDTHMAX = 256;
   localparam CWIDTH = 192;
   localparam XWIDTH = 64;
   localparam T = 10;
   
   logic [KWIDTHMAX-1:0] k;
   logic [1:0] kWidth;
   logic clk,reset;
   logic [CWIDTH-1:0] cout;
   logic [XWIDTH-1:0] xout;
   logic done;
   
   ksneq32 #(.KWIDTHMAX(KWIDTHMAX), .CWIDTH(CWIDTH), .XWIDTH(XWIDTH)) ks (.*);
   
    always begin
        clk = 1'b1;
        #(T/2);
        clk = 1'b0;
        #(T/2);
    end
      
    initial begin
        reset = 1'b1;
        #(T/2);
        reset = 1'b0;
    end
      
    initial begin
        kWidth = 2'b00;
        k = 192'h68656c6c6f206d79206e616d652069732072616665642021;
        wait(done);
    end
   
endmodule
