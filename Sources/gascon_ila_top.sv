`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2020 10:39:12 PM
// Design Name: 
// Module Name: gascon_ila_top
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


module gascon_ila_top #(parameter CWIDTH = 320, parameter ROUND_COUNT = 1) (
    input logic clk, reset,
    input logic [15:0] SW,
    output logic [15:0] led
    );
    
    logic [CWIDTH-1:0] c;
    logic [CWIDTH-1:0] cout;
    logic [ROUND_COUNT-1:0] round;
    logic done;
   
   
   assign round = 0;
   
   always_comb begin
        c[319:16] = 304'h2072616665642021206e616d652069732072616665642021206e616d65206973207261666564;
        c[15:0] = SW;
        led[15] = done;
        led[14:0] = cout[319:305];
   end

   Gascon_Core_Round #(.CWIDTH(CWIDTH), .ROUND_COUNT(1)) gascon (
            .clk(clk),
            .c(c),
            .cout(cout),
            .round(round),
            .reset(reset),
            .done(done)    
   );

endmodule
