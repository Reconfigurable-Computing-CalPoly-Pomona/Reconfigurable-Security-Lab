`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2019 10:56:25 PM
// Design Name: 
// Module Name: mod_m_counter
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


module mod_m_counter #(parameter N = 10) (
    input logic clk, 
    input logic reset,
    input logic enable, 
    output logic max_tick,
    output logic [$clog2(N):0] count,
    input logic [15:0] delayPeriod);     
    
    
    logic [$clog2(N):0] r_reg, r_next;
    
    always_ff @(posedge clk, posedge reset) begin   //register segment
        if(reset) r_reg <= 0; 
        else if (~enable) r_reg <= r_reg;
        else r_reg <= r_next; 
     end
     
     assign r_next = (r_reg == (N)) ? 0 : r_reg + 1; // [2] next-state logic segment
     
     //[3] output logic segment
     assign max_tick = (r_reg == (N)) ? 1'b1 : 1'b0; 
     
     assign count = r_reg;
     
     
 endmodule
