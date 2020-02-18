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
    input logic clk, reset,
    input logic [CWIDTH-1:0] c,
    input logic [ROUND_COUNT-1:0] rounds,
    output logic [CWIDTH-1:0] cout, //cout is c
    output logic [RWIDTH-1:0] rout, //rout = newstate
    output logic done
    );
    
    logic [CWIDTH-1:0] cReg, gasOut, gas_cin;
    logic [RWIDTH-1:0] rReg, acc_out;
    logic gas_done, increment, gasReset, acc_done, acc_en;
    logic [ROUND_COUNT-1:0] j;
    
    typedef enum {INITIALIZE, START, WAITGAS, WAITACCUMULATE, RESTART_GAS, DONE} state_type;
    state_type curr_state, next_state;
    
//    always_ff @ (posedge clk, posedge reset)
//        if (reset) rRegA <= 0;
//        else rRegA <= rReg;
    
    //Counter Logic
    always_ff @ (posedge clk, posedge reset)
        if (reset) j <= 0;
        else if (j >= rounds) j <= j;
        else if (increment) j <= j + 1;
        else j <= j;
      
    //State Register Logic  
    always_ff @ (posedge clk, posedge reset)
        if (reset) curr_state <= INITIALIZE;
        else curr_state <= next_state;
    
    //Next_State Logic
    always_comb begin
        cout = 0;
        done = 1'b0;
        increment = 1'b0;
        cReg = cReg;
        rReg = rReg;
        rout = 0;
        gas_cin = gas_cin;
        
        case (curr_state)
            INITIALIZE: begin
                rReg = 0;
                cReg = 0;
                gas_cin = c;
                gasReset = 1'b0;
                acc_en = 1'b0;
                next_state = WAITGAS;
            end
            
            START: begin
                rReg = rReg;
                gasReset = 1'b1;
                acc_en = 1'b0;
                next_state = WAITGAS;
            end
             
            WAITGAS: begin
                gasReset = 1'b0;
                acc_en = 1'b0;
                if (gas_done) 
                begin
                    cReg = gasOut;
                    acc_en = 1'b1;
                    next_state = WAITACCUMULATE;
                end
                else next_state = WAITGAS;    
            end
            
            WAITACCUMULATE: begin
                gasReset = 1'b0;
                acc_en = 1'b1;
                if (acc_done) begin
                    acc_en = 1'b0; //the fix, acc_en low makes sure new rReg value doesnt cause recalculation in accumulate
                    rReg = acc_out;
                    next_state = RESTART_GAS;
                end
                else next_state = WAITACCUMULATE;    
            end
            
            RESTART_GAS: begin
                rReg = rReg;
                if ((j+1) >= rounds) begin
                    gasReset = 1'b0;
                    acc_en = 1'b0;
                    next_state = DONE;
                    increment = 1'b1;
                end
                else begin
                    gasReset = 1'b1;
                    acc_en = 1'b0;
                    next_state = WAITGAS;
                    increment = 1'b1;
                end
            end
            
            DONE: begin
                gasReset = 1'b0;
                acc_en = 1'b0;
                next_state = DONE;
                cout = cReg;
                rout = rReg;
                done = 1'b1;
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
        .c(gas_cin),
        .cout(gasOut),
        .round(j),
        .reset(reset | gasReset),
        .done(gas_done)    
    );
endmodule
