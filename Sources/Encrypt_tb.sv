`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2020 12:31:20 PM
// Design Name: 
// Module Name: Encrypt_tb
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


module Encrypt_tb();
    
//    localparam iW
    logic clk, start, rst, TAG, done;
    logic [191:0] K;
    logic [127:0] S, A, NONCE, P, C;
    
    Encrypt sogcon(
        .clk(clk),
        .start(start),
        .rst(rst),
        .TAG(TAG),
        .done(done),
        .K(K),
        .S(S),
        .A(A),
        .NONCE(NONCE),
        .P(P),
        .C(C)
    );
    
    always begin
        clk = 1'b0;
        #(5);
        clk = 1'b1;
        #(5);
    end
    
    initial begin
        rst = 1'b1;
        #(10);
        rst = 1'b0;
        start = 1'b1;
    end
    
    initial begin
        K = 192'h68656c6c6f206d79206e616d6520697320736f67636f6e21;
        S = 128'h726f6265727420697320636f6f6c2021;
        NONCE = 128'h646f6e277420726561642074686973;
        A = 128'h646f6e277420726561642074686973;
        P = 128'h6e2774206465637279707420746873;
        wait(done);
    end
endmodule
