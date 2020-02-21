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
    logic clk, startE,startD, rstE, rstD, TAG, doneE, doneD, failure;
    logic [447:0] K;
    logic [127:0] S, A, NONCE, P, Pd, C;
    
    Encrypt sogcon(
        .clk(clk),
        .start(startE),
        .rst(rstE),
        .TAG(TAG),
        .done(doneE),
        .K(K),
        .S(S),
        .A(A),
        .NONCE(NONCE),
        .P(P),
        .C(C)
    );
    
    Decrypt nocgos(
        .clk(clk),
        .start(startD),
        .rst(doneE),
        .TAG(TAG),
        .done(doneD),
        .K(K),
        .S(S),
        .A(A),
        .NONCE(NONCE),
        .P(Pd),
        .C(C),
        .failure(failure)
    );
    
    always begin
        clk = 1'b0;
        #(5);
        clk = 1'b1;
        #(5);
    end
    
    initial begin
        rstE = 1'b1;
        #(10);
        rstE = 1'b0;
        startE = 1'b1;
    end
    
    initial begin
        rstD = 1'b1;
        K = 128'h75686577667569686875666f656969;
        S = 128'h726f6265727420697320636f6f6c2021;
        NONCE = 128'h64646f6e277420726561642074686973;
        A = 128'h64646f6e277420726561642074686973;
        P = 128'h646e2774206465637279707420746873;
        wait(doneE);
        startD = 1'b1;
        rstD = 1'b0;
        wait(doneD);
    end
endmodule
