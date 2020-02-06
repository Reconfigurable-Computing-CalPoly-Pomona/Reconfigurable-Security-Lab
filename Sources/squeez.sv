
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2019 04:05:58 PM
// Design Name: 
// Module Name: squeez
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


module squeez #(parameter CWIDTH = 320,
                parameter RWIDTH = 32, 
                parameter DATA_SIZE = 32,
                parameter REMAINWIDTH = 20,
                parameter ROUND_COUNT = 10)
                (
                input  logic clk, reset, 
                output logic seldone, Gdone,
                input  logic [CWIDTH-1:0] c, // capacity
                output logic [CWIDTH-1:0] Bdata, //output data
                input  logic [RWIDTH-1:0] r, // state I think
                input  logic [REMAINWIDTH-1:0] remaining,
                input  logic [ROUND_COUNT-1:0] rounds
                output logic squeezDone; 
                );
                logic [CWIDTH-1:0] cReg;
                logic selgo, Ggo;
                logic [REMAINWIDTH-1:0] remainReg;
                logic [RWIDTH-1:0] rReg;
                logic [RWIDTH-1:0] roReg;
                logic [CWIDTH-1:0] roSReg;
                logic [RWIDTH-1:0] roSSReg;
                logic [CWIDTH-1:0] coGReg;
                logic [RWIDTH-1:0] len;
                logic [CWIDTH-1:0] bReg;
                 typedef enum {START, REMAINCHECK, BCONCATINATE, REMAIN2WIDTH, SELWAIT, REMAININGZERO, GWAIT, END} state_type;
                 state_type curr_state, next_state, prev_state;
    

                //FF for State:
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


                //Case for FSM
                always_comb begin
                case (curr_state)
                         START:
                            begin
                                len <= RWIDTH; //1
                                remainReg=remaining; 
                                next_state = REMAINCHECK;
                                 
                            end
                        REMAINCHECK: 
                            begin
                            if(remaining > 0)//2
                                next_state = REMAIN2WIDTH;
                            else
                                next_state = END;
                            end
                        REMAIN2WIDTH: 
                            begin
                            if (remaining < RWIDTH)//3
                                begin
                                len <= remaining;//4
                                selgo <= 1; 
                                next_state = SELWAIT;
                                end
                            else
                                next_state = BCONCATINATE; 
                                end
                        BCONCATINATE:   
                            begin
                            if (prev_state == SELWAIT)
                            begin
                            bReg = {roSSREG[lenReg,0],bReg[CWIDTH-1:lenReg]}
                            end
                            else
                            begin
                                bReg = {roSSREG,bReg[CWIDTH-1:remainReg]}
                            end 

                            remainReg = remainReg-len; //8
                            next_state = REMAININGZERO; 
                            end
                        REMAININGZERO:  
                            begin
                            if (remaining > 0)//9
                            begin
                                Ggo = 1'b1;
                                next_state = GWAIT;
                            end
                            else
                                next_state = REMAINCHECK;
                            end
                        SELWAIT:    
                            begin
                            if (selgo==1)
                            begin
                                roSSREG <= roSReg
                                selgo = 0'b1; 
                                next_state = BCONCATINATE;
                            end
                            else
                                selgo = 1'b1;
                            end
                        GWAIT:
                            begin
                            if (Gdone ==1) //10
                                next_state = REMAINCHECK;
                                cReg = coGReg;
                            else
                                next_state = GWAIT;
                            end
                        END:
                            begin
                            Bdata <= bReg;
                            squeezDone <= 1'b1;
                            end
                endcase


            end
G #(.CWIDTH(CWIDTH), .RWIDTH(RWIDTH), .ROUND_COUNT(ROUND_COUNT)) g (
        .c(cReg),
        .rout(roReg),
        .cout(coReg),
        .clk(clk),
        .reset(reset||!Ggo),
        .done(Gdone),
        .rounds(rounds)
    );
  select #(.INPUT_WIDTH(CWIDTH), .OUT_WIDTH(64)) select1 (
        .inputVal(cReg),
        .index(len),
        .out(roSReg),
        .reset(reset)
    );
endmodule
