
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
                input  logic clk, reset, big,
                output logic seldone, Gdone,
                input  logic [CWIDTH-1:0] c, // capacity
                output logic [CWIDTH-1:0] Bdata, //output data
                input  logic [RWIDTH-1:0] r, // state I think
                input  logic [REMAINWIDTH-1:0] remaining,
                input  logic [ROUND_COUNT-1:0] rounds,
                output logic squeezDone
                );
                logic [CWIDTH-1:0] cReg, g_cin, coReg;
                logic Ggo;
                logic [REMAINWIDTH-1:0] remainReg;
                logic [RWIDTH-1:0] rReg;
                logic [RWIDTH-1:0] roReg;
                logic [CWIDTH-1:0] roSReg;
                logic [CWIDTH-1:0] roSSReg;
                logic [RWIDTH-1:0] len;
                logic [CWIDTH-1:0] bReg;
                typedef enum {START, REMAINCHECK, BCONCATINATE, REMAIN2WIDTH, SELWAIT, REMAININGZERO, GWAIT, DONE} state_type;
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
                    g_cin = g_cin;
                    Ggo = Ggo;
                    squeezDone = squeezDone;
                    cReg = cReg;
                    Bdata = Bdata;
                    
                case (curr_state)
                         START:
                            begin
                                if (!big && !reset) begin
                                    bReg = r[0];
                                    next_state = DONE;
                                end 
                                len = RWIDTH; //1
                                remainReg=remaining; 
                                if (reset) next_state = START;
                                else next_state = REMAINCHECK;
                                bReg = 0;
                                roSSReg = r;    //take in initial r value 
                                cReg = c; //take in C;
                                Ggo = 1'b0;
                                squeezDone = 1'b0;
                                
                            end
                        REMAINCHECK: 
                            begin
//                            Ggo = 1'b0;
                            if(remainReg > 0)//2
                                next_state = REMAIN2WIDTH;
                            else
                                next_state = DONE;
                            end
                        REMAIN2WIDTH: 
                            begin
                            if (remainReg < RWIDTH)//3
                                begin
                                    len = remainReg;//4
                                end
                                next_state = BCONCATINATE; 
                            end
                        BCONCATINATE: begin
                            bReg = bReg | (roSSReg << (CWIDTH-remainReg));
                            remainReg = remainReg-len; 
                            next_state = REMAININGZERO; 
                        end
                        REMAININGZERO:  
                        begin
                            if (remainReg > 0)//9
                            begin
                                Ggo = 1'b0;
                                g_cin = cReg;
                                next_state = GWAIT;
                            end
                            else
                                next_state = REMAINCHECK;
                        end
//                        SELWAIT:    
//                            begin
//                            if (selgo==1)
//                            begin
//                                roSSReg <= roSReg;
//                                selgo = 1'b1; 
//                                next_state = BCONCATINATE;
//                            end
//                            else
//                                selgo = 1'b1;
//                            end
                        GWAIT:
                            begin
                                Ggo = 1'b1;
                                if (Gdone == 1) begin //10 
                                    next_state = REMAINCHECK;
                                    cReg = coReg;
                                    roSSReg = roReg;
                                end
                                else next_state = GWAIT;  
                            end
                        DONE:
                            begin
                            Bdata = bReg;
                            squeezDone = 1'b1;
                            end
                endcase


            end
    G #(.CWIDTH(CWIDTH), .RWIDTH(RWIDTH), .ROUND_COUNT(ROUND_COUNT)) g (
        .c(g_cin),
        .rout(roReg),
        .cout(coReg),
        .clk(clk),
        .reset(reset|(~Ggo)),
        .done(Gdone),
        .rounds(rounds)
    );
    
//    select #(.INPUT_WIDTH(RWIDTH), .OUT_WIDTH(CWIDTH)) select1 (
//        .inputVal(sel_input),
//        .index(0),
//        .out(roSReg),
//        .reset(reset | (~selgo))
//    );
endmodule
