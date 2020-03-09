`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2020 02:43:08 PM
// Design Name: 
// Module Name: top-mod
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


module top_mod(
    input clk, rst,
    output done, tag,
    input[15:0] SW,
    output [6:0] Seg,
    output reg[7:0] An
    );
    
    reg[127:0] K= 128'h75686577667569686875666f656969;
    reg[127:0] S = 128'h726f6265727420697320636f6f6c2021;
    reg[127:0] A = 128'h64646f6e277420726561642074686973;
    reg[127:0] NONCE = 128'h64646f6e277420726561642074686973;
    wire[127:0] P;
    wire[127:0] C;
    reg[20:0] count = 0;
    reg[3:0] toSeg;
    reg resetEnc;
    assign P = {112'h646e277420646563727970742074,SW};
    always@(posedge clk)
    begin
        if(rst == 1'b1)
            resetEnc = 1'b1;
        else
            resetEnc = 1'b0;
        count = count + 1;
        case(count[20:18])
            3'b000: 
            begin
                An = 8'b11111110;
                toSeg = C[4:0];
            end
            3'b001:
            begin
                An = 8'b11111101;
                toSeg = C[8:4];
            end
            3'b010:
            begin
                An = 8'b11111011;
                toSeg = C[12:8];
            end
            3'b011:
            begin
                An = 8'b11110111;
                toSeg = C[16:12];
            end
            3'b100:
            begin
                An = 8'b11101111;
                toSeg = C[20:16];
            end
            3'b101:
            begin
                An = 8'b11011111;
                toSeg = C[24:20];
            end
            3'b110:
            begin
                An = 8'b10111111;
                toSeg = C[28:24];
            end
            3'b111:
            begin
                An = 8'b01111111;
                toSeg = C[32:28];
            end
        endcase
    end
    
    Encrypt enc(count[8],rst,K,S,A,NONCE,P,C,tag,done);
    SevenSeg encoder(toSeg,Seg);
endmodule
