`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2019 04:05:58 PM
// Design Name: 
// Module Name: decrypt
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

//------------------------Module Decleartion-----------------------------------------
module Decrypt #(   parameter KWIDTHMAX = 321,              // secret key size
                    parameter SWIDTH = 32,                  // static data size
                    parameter PTEXT_SIZE = 32,              // plain text data size
                    parameter NONCE_SIZE= 64,               // NONCE data size
                    parameter ADATA_SIZE = 32,              // Associated Data Size
                    parameter CTEXT_SIZE = 32,              // Cipher Text Size
                    parameter CWIDTH = 32,                  // Capacity Size
                    parameter XWIDTH = 32,                  // part of state 
                    parameter IWIDTH = 32                   // 
                    parameter DWIDTH = 2                    // domain width
                )
                (
                //------------------ inputs------------------------------
                input  logic [KWIDTHMAX-1:0]            k,      // secret key
                input  logic [SWIDTH-1:0]               s,      // optional static data
                input  logic [NONCE_SIZE-1:0]           non,    // nonce
                input  logic [ADATA_SIZE-1:0]           a,      // assoicated data
                input  logic [CTEXT_SIZE-1:0]           c,      // optional cipher text
                input  logic                            tag,    //authentication tag
                input  logic                            clk,    // clk
                in
                //------------------outputs-----------------------------------
                output logic [PTEXT_SIZE-1:0]           ptextd, //output data
                output logic squeezDone,                        //Done signal
                output logic failure                            //fail signal
                );
                //------------------internal registers-------------------------
                logic [1:0]         kWidth;                 //kwidth for key setup
                logic               ksGo;                   //Key Setup go
                logic               kDone;                  //Key done signal
                logic               finalize;               // finalize signal
                logic [CWIDTH-1:0]  kCoutR;                 //KeySetups C out register
                logic [XWIDTH-1:0]  kXoutR;                 //KeySetups X out register
                logic [DWIDTH-1:0]  dss,dsd,dsa,dsm         // domain setups
                logic [CWIDTH-1:0]  s,a,m                   // domain values
                //------------------state machine states-----------------------                
                    typedef enum {START, KSWAIT} state_type;
                    //prev next and current state declartions
                state_type curr_state, next_state, prev_state;
                //---------------------FF for State------------------------------
                always_ff @(posedge clk, posedge reset)
                    if (reset)
                    begin
                        curr_state <= START;
                        prev_state <= START;
                    end
                    else
                    begin
                        prev_state <= curr_state;
                        curr_state <= next_state;
                    end
                //---------------------Cases for FSM------------------------------
                always_comb begin
                case (curr_state)
                        START:
                            begin
                                ksGo = 1'b1; // line 1 start
                                dss = 2'b2; // domain set s line 2
                                dsd = 1'b2; // domain set d line 2 
                                dsa = 2'b2; // domain set a line 2 
                                dsm = 3'b2; // domain set m line 2
                                s = (SWIDTH/IWIDTH);
                                a = (ADATA_SIZE/IWIDTH);
                                m = (CWIDTH)
                                next_state <= KSWAIT
                            end
                        KSWAIT:
                            begin
                                if(kDone)
                                    next_state <= STATE;
                                else
                                    next_state <= KSWAIT;
                            end
                        
                                

                //---------------------line 1 module-------------------------------
module ksneq32 #(.KWIDTHMAX(KWIDTHMAX), .CWIDTH.(CWIDTH), .XWIDTH(XWIDTH)) (
                    .k(k),
                    .kWidth(kWidth),
                    .clk(clk),
                    .reset(reset||~ksGo),
                    .cout(kCoutR),
                    .xout(kXoutR),
                    .done(kDone)
);
 
