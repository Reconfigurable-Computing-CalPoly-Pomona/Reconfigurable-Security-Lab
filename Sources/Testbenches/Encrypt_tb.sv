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

//////////////////////////////////////////////////////////////////////////////////
//TESTBENCH RESULTS:
// 1) Plaintext passed in: 0ff5ad61b9a09f7a9d9246b0d427ed15
// 2) Ciphertext generated with other inputs: 0ff5ad61b9a09f7a9d9246b0d427ed15
// 3) When decrypting the same plaintext above is regenerated.
//////////////////////////////////////////////////////////////////////////////////

module Encrypt_tb();
    
//    localparam iW
    logic clk, rst, TAG, TAGIN, FAILURE, done, en;
    logic [447:0] K;
    logic [127:0] S, A, NONCE, P, C;
    logic eoc;
    
    Encrypt sogcon(
        .clk(clk),
        .rst(rst),
        .TAG(TAG),
        .done(done),
        .K(K),
        .S(S),
        .A(A),
        .NONCE(NONCE),
        .P(P),
        .C(C),
        .en(en),
        .eoc(eoc),
        .FAILURE(FAILURE),
        .TAGIN(TAGIN)
    );
    
    always begin
        clk = 1'b1;
        #(5);
        clk = 1'b0;
        #(5);
    end
    
    initial begin
        rst = 1'b1;
        #(5);
        rst = 1'b0;
    end

    initial begin
        S = 128'h646f416454534a3932677445756b734c;
        A = 128'h7a5844494c483139656e4265626b5776;
        NONCE = 128'h744d64476b41465555757a666d694f38;
        K = 128'h62427358796268566450626339617544;
        P = 128'h363174644f47387a39616d6c796c6759;
        eoc = 0;

        en = 1'b1;
        wait(done);
        #5;
        P = C;
        en = 0;
        rst = 1'b1;
        TAGIN = TAG;
        eoc = 1;
        #10;
        rst = 1'b0;
        en = 1;
        wait(done);
        #10;
        $finish;
    end
endmodule

//        S = 128'h726f6265727420697320636f6f6c2021;
//        NONCE = 128'h64646f6e277420726561642074686973;
//        A = 128'h64646f6e277420726561642074686973;
//        P = 128'h646e2774206465637279707420746873;
//        S = 128'h7575686577667569686875666f656969;
