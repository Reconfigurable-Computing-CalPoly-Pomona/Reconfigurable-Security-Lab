
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
                input  logic clk, reset, big, en,
                output logic seldone, Gdone,
                input  logic [CWIDTH-1:0] c, // capacity
                output logic [CWIDTH-1:0] Bdata, //output data
                input  logic [RWIDTH-1:0] r, // state I think
                input  logic [REMAINWIDTH-1:0] remaining,
                input  logic [ROUND_COUNT-1:0] rounds,
                output logic squeezDone
                );
                logic [CWIDTH-1:0] cReg, g_cin, coReg, cRegNext, g_cinNext;
                logic Ggo,Bsave;
                logic [REMAINWIDTH-1:0] remainReg;//remainRegNext;
                logic [RWIDTH-1:0] rReg;
                logic [RWIDTH-1:0] roReg;
                logic [CWIDTH-1:0] roSReg;
                logic [CWIDTH-1:0] roSSReg;
                logic [RWIDTH-1:0] len;
                logic [CWIDTH-1:0] bReg,bRegNext;
                typedef enum {RESET, START, REMAINCHECK, BCONCATINATE, REMAIN2WIDTH, SELWAIT, REMAININGZERO, GWAIT, DONE} state_type;
                state_type curr_state, next_state;

                //State Register Block  
                always_ff @ (posedge clk)
                    if (reset) curr_state <= RESET;
                    else curr_state <= next_state;
        
                //cReg Block Register
                always_ff @ (posedge clk)
                    if (reset) cReg <= 0;
                    else cReg <= cRegNext;
                    
                //g_cin Block Register
                 always_ff @ (posedge clk)
                    if (reset) g_cin <= 0;
                    else g_cin <= g_cinNext;
                
                //bReg Block Register
                always_ff @ (posedge clk)
                    if (reset) bReg <= 0;
                    else bReg <= bRegNext;
                
                //remainReg Block Register
                always_ff @(posedge clk)
                    if (reset) remainReg <= 0;
                    else if (curr_state == START) remainReg <= remaining;
                    else if (curr_state == BCONCATINATE) remainReg <= remainReg - len;
                    else remainReg <= remainReg;
                
                //bData Block Register
                always_ff @(posedge clk)
                    if (squeezDone) Bdata <= 0;
                    else Bdata <= bReg;
                
                //Case for FSM
                always_comb begin
                    g_cinNext = g_cin;
                    Ggo = 1'b0;
                    squeezDone = 1'b0;
                    cRegNext = cReg;
                    next_state = curr_state;
                    Bsave = 1'b0;
                    case (curr_state)
                         RESET:
                            begin
                                g_cinNext = 0;
                                Ggo = 1'b0;
                                squeezDone = 1'b0;
                                cRegNext = 0;
                                bRegNext = 0;
                                Bsave = 1'b0;
                                roSSReg = 0;
                                //remainRegNext = 0;
                                if (en) next_state = START;
                                else next_state = RESET;                            
                            end
                         START:
                            begin
                                if (!big && !reset) begin
                                    bRegNext = r[0];
                                    next_state = DONE;
                                end 
                                len = RWIDTH; //1
                                //remainRegNext=remaining; 
                                if (reset) next_state = START;
                                else next_state = REMAINCHECK;
                                bRegNext = 0;
                                roSSReg = r;    //take in initial r value 
                                cRegNext = c; //take in C;
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
                            bRegNext = bReg | (roSSReg << (CWIDTH-remainReg));
                            //remainRegNext = remainReg-len; 
                            next_state = REMAININGZERO; 
                        end
                        REMAININGZERO:  
                        begin
                            if (remainReg > 0)//9
                            begin
                                Ggo = 1'b0;
                                g_cinNext = cReg;
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
                                    cRegNext = coReg;
                                    roSSReg = roReg;
                                end
                                else next_state = GWAIT;  
                            end
                        DONE:
                            begin
                            Ggo = 1'b0;
                            squeezDone = 1'b1;
                            next_state = DONE;
                            end
                        default: begin
                            g_cinNext = g_cin;
                            Ggo = 1'b0;
                            squeezDone = 1'b0;
                            cRegNext = cReg;
                            Bsave = 1'b0;
                        end
                endcase
            end
    G #(.CWIDTH(CWIDTH), .RWIDTH(RWIDTH), .ROUND_COUNT(ROUND_COUNT)) g (
        .c(g_cin),
        .rout(roReg),
        .cout(coReg),
        .clk(clk),
        .reset(reset|(~Ggo)),
        .en(Ggo),
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
