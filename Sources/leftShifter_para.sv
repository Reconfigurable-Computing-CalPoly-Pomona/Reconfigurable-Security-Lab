`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2019 01:42:21 PM
// Design Name: 
// Module Name: shifter_para
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


module leftShifter_para #(parameter N = 3)(
   input logic [(2**N)-1:0] a,
   input logic [N-1:0] amt,
   output logic [(2**N)-1:0] y
   );
   
   localparam WIDTH = 2**N;
   logic [WIDTH-1:0] stageArray [0:N];
       
   genvar i;
   assign stageArray[0] = a;

   generate
    for (i = 0; i < N; i = i+1) begin
        assign stageArray[i+1] = amt[i] ? {stageArray[i][0 +: (WIDTH - (2**i))],
        stageArray[i][(WIDTH-1) -: (2**i)]} : stageArray[i];  
    end        
   endgenerate
   
   assign y = stageArray[N];
    
endmodule
