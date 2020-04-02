`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2019 04:46:03 PM
// Design Name: 
// Module Name: G
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


module G #(parameter CWIDTH = 320, parameter RWIDTH = 32, parameter ROUND_COUNT = 10) (
    input logic clk, reset, en,
    input logic [CWIDTH-1:0] c,
    input logic [ROUND_COUNT-1:0] rounds,
    output logic [CWIDTH-1:0] cout, //cout is c
    output logic [RWIDTH-1:0] rout, //rout = newstate
    output logic done
    );
    
    logic [CWIDTH-1:0] cReg, cRegNext, gasOut;
    logic [RWIDTH-1:0] rReg, rRegNext, acc_out;
    logic gas_done, increment, gas_reset, gas_en, acc_done, acc_en;
    logic [ROUND_COUNT-1:0] j;
    
    typedef enum {RESET, INIT, WAITGAS, WAITACCUMULATE, RESTART_LOOP, DONE} state_type;
    state_type curr_state, next_state;
    
//    always_ff @ (posedge clk, posedge reset)
//        if (reset) rRegA <= 0;
//        else rRegA <= rReg;
    
    //Counter Register Block
    always_ff @ (posedge clk)
        if (reset) j <= 0;
        else if (j >= rounds) j <= j;
        else if (increment) j <= j + 1;
        else j <= j;
      
    //State Register Block  
    always_ff @ (posedge clk)
        if (reset) curr_state <= RESET;
        else curr_state <= next_state;
    
    //CReg Register Block, holds C output between interations
    always_ff @ (posedge clk)
        if (reset) cReg <= 0;
        else cReg <= cRegNext;
    
    //RReg register block, holds R output from accumulate between interactions
    always_ff @ (posedge clk)
        if (reset) rReg <= 0;
        else rReg <= rRegNext;
    
    //State Combinational Logic
    always_comb begin
        cout = 0;
        done = 1'b0;
        increment = 1'b0;
        cRegNext = cReg;
        rRegNext = rReg;
        rout = 0;
        next_state = curr_state;
        gas_reset = 0;
        gas_en = 0;
        acc_en = 0;
        
        case (curr_state)
            RESET: begin
                //in this state, all registers have just been reset
                //all lower level modules have been reset too
                cout = 0;
                done = 1'b0;
                increment = 1'b0;
                cRegNext = 0;
                rRegNext = 0;
                rout = 0;
                acc_en = 0; //both modules disabled as of right now
                gas_en = 0; //both modules disabled as of right now
                
                if (en) next_state = INIT; //if module is enabled, go to init state and read cin
                else next_state = RESET;
            end
            
            INIT: begin
                rRegNext = 0;
                cRegNext = c; //read input value on wire into our local register
                gas_reset = 1'b0;
                acc_en = 1'b0;
                next_state = WAITGAS;
            end
            
//            START: begin //start state 
//                rRegNext = rReg;
//                gas_reset = 1'b1;
//                acc_en = 1'b0;
//                next_state = WAITGAS;
//            end
             
            WAITGAS: begin
                //here we start gas
                acc_en = 1'b0;
                gas_en = 1'b1;
                if (gas_done) 
                begin
                    cRegNext = gasOut; //if gas is done, read its output into our cRegister
                    next_state = WAITACCUMULATE;
                end
                else next_state = WAITGAS;    
            end
            
            WAITACCUMULATE: begin
                //here we run accumulate
                gas_reset = 1'b0;
                acc_en = 1'b1;
                if (acc_done) begin
                    rRegNext = acc_out; //if acc is done, read its rOutput into our rRegister
                    acc_en = 1'b0; //the fix, acc_en low makes sure new rReg value doesnt cause recalculation in accumulate
                    next_state = RESTART_LOOP;
                end
                else next_state = WAITACCUMULATE;   //otherwise wait till its done, check next clock cycle 
            end
            
            RESTART_LOOP: begin
                rRegNext = rReg; //maintain value of both registers
                cRegNext = cReg;
                if ((j+1) >= rounds) begin //check if the for loop is done (if we increment again, will it be over max value?)
                    gas_reset = 1'b0;
                    acc_en = 1'b0;
                    next_state = DONE;
                    increment = 1'b1; //we increment here so that the counter itself holds its value indefinitely
                                        //it will check if it has reached its max value
                end
                else begin //if the counter isnt done, we need to increment and restart the loop again
                    gas_reset = 1'b1;
                    acc_en = 1'b0;
                    increment = 1'b1; //increment so that on the next iteration the counter is updated
                    next_state = WAITGAS;
                end
            end
            
            DONE: begin
                gas_reset = 1'b0;
                gas_en = 0;
                acc_en = 1'b0;
                cout = cReg; //write values of registers to output wires
                rout = rReg;
                done = 1'b1;     //raise done flag
                next_state = DONE; //stay in this state indefinitely
            end    
            
            default: begin
                cout = 0;
                done = 1'b0;
                increment = 1'b0;
                cRegNext = cReg;
                rRegNext = rReg;
                rout = 0;
                next_state = curr_state;
            end
        
        endcase
    
    end    
    
    
//    assign increment = acc_done;
    
    Accumulate #(.StateSize(RWIDTH), .CapacitySize(CWIDTH)) accumulate (
        .clk(clk),
        .state(rReg),
        .capacity(cReg),
        .start(acc_en),
        .done(acc_done),
        .newState(acc_out)
    );
    
    Gascon_Core_Round #(.CWIDTH(CWIDTH), .ROUND_COUNT(ROUND_COUNT)) gascon (
        .clk(clk),
        .c(cReg),
        .cout(gasOut),
        .round(j),
        .reset(reset | gas_reset),
        .en(gas_en),
        .done(gas_done)    
    );
endmodule
