`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Rafed El-Issa
// 
// Create Date: 01/13/2020 04:49:31 PM
// Design Name: 
// Module Name: ksneq32
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


module ksneq32 #(parameter MINWIDTH_K = 128, parameter KWIDTHMAX = 192, parameter CWIDTH = 128, parameter XWIDTH = 64) (
    input logic [KWIDTHMAX-1:0] k,
    input logic [1:0] kWidth,
    input logic clk,reset,
    output logic [CWIDTH-1:0] cout,
    output logic [XWIDTH-1:0] xout,
    output logic done
);

    localparam XWORDS = XWIDTH/32;
    localparam KWORDS = MINWIDTH_K/32;
    localparam FASTWIDTH = MINWIDTH_K + XWIDTH;
    localparam FULLWIDTH = CWIDTH+XWIDTH;
    
    logic [CWIDTH-1:0] cReg;
    logic iReset, jReset, gasReset;
    logic increment_I, increment_J, special_increment_I;
    logic [$clog2(CWIDTH/32):0] i, prevI;
    logic [$clog2(XWORDS+1):0] j, newJ; 
    
    logic [CWIDTH-1:0] gasCin, gasOut;
    logic gasDone;
    logic match;
    
    enum {MIN = 0,FAST = 1,FULL = 2} kSizes;
    typedef enum {INITIALIZE, FIRST_FOR, SECOND_FOR,REPEAT_GAS, REPEAT_FOR, RESET_I, DONE} state_type;
    state_type curr_state, next_state;
    
    //i counter
    always_ff @(posedge clk, posedge reset, posedge iReset, posedge special_increment_I)
    begin
        if (reset || iReset) i <= 0;
        else if (special_increment_I || increment_I) i <= i + 1;
        else i <= i;
    end
    
    //j counter
    always_ff @(posedge clk, posedge reset, posedge jReset)
    begin
        if (reset || jReset) j <= newJ;
        else if (increment_J) j <= j + 1;
        else j <= j;
    end
    
    //Register for State
    always_ff @(posedge clk, posedge reset)
    begin
        if (reset) curr_state <= INITIALIZE;
        else curr_state <= next_state;
    end
    
    //Combinational State Logic
    always_comb
    begin
        //setting default values
        done = 1'b0;
        cReg = cReg;
//        cReg = 192'h803c003b00095d1000000000000000000012de0000f3bf70;
        xout = xout;
        cout = cout;
        special_increment_I = 1'b0;
        newJ = newJ;
        match = match;
        //prevI = prevI;
        
        case(curr_state)
            INITIALIZE: begin
                match = 0;
                cReg = 0;
                cout = 0;
                xout = 0;
                special_increment_I = 1'b0;
                gasReset = 1'b1;
                newJ = 1;
                //prevI = 0;
                
                if (kWidth == FULL) begin
                    cout = k[CWIDTH-1:0];
                    xout = k[FULLWIDTH-1:CWIDTH];
                    next_state = DONE;
                end
                else begin
                    next_state = FIRST_FOR;
                end
            end
            
            FIRST_FOR: begin
                if (i <= (CWIDTH/32)-1) begin
                   cReg[i*32 +: 32] = k[(i%KWORDS)*32 +: 32]; //if KWORDS is 1, all cReg 32 bit words will be same
                   increment_I = 1'b1;
                   next_state = FIRST_FOR;
                end
                else begin //for loop is finished
                    increment_I = 1'b0;
                    if (kWidth == FAST) begin
                        xout = k[FASTWIDTH-1:MINWIDTH_K];
                        cout = cReg;
                        next_state = DONE;
                    end
                    else begin
                        gasReset = 1'b1;
                        gasCin = cReg;
                        next_state = REPEAT_GAS;
                    end
                end
            end
                
            REPEAT_GAS: begin
                if (gasDone) begin
                    gasReset = 1'b0;
                    cReg = gasOut;
                    iReset = 1'b1;
                    jReset = 1'b1;    
                    match = 0; //reset match variable
                    next_state = REPEAT_FOR;
                end
                else begin
                    gasCin = cReg;   
                    gasReset = 1'b0;
                    next_state = REPEAT_GAS;
                end
                
            end
            
            REPEAT_FOR: begin
                if (j <= XWORDS) begin //if inner for loop is still going
                    if (cReg[i*32 +: 32] == cReg[j*32 +: 32]) match = 1;
                    increment_J = 1'b1;
                    increment_I = 1'b0;
                    jReset = 1'b0;
                    iReset = 1'b0;
                    next_state = REPEAT_FOR;
                end
                
                else begin //inner for loop is finished
                    if (i <= XWORDS-1) begin //if outer for loop not finished yet
                        prevI = i;
                        newJ = i+2;
                        increment_I = 1'b1;
                        increment_J = 1'b0;
//                        if (special_increment_I) begin //if was already incremented  
//                            increment_J = 1'b0;
//                            jReset = 1'b1;
//                        end
//                        else begin
//                            increment_J = 1'b0;
//                            special_increment_I = 1'b1;
//                        end
                        jReset = 1'b0; //dont reset here, because it will rerun combo block before RESET_I state runs
                        next_state = RESET_I;
                        special_increment_I = 1'b0;  
                    end
                    else begin //outer loop is done (0 to XWORDS-1)
                        //check if a repeat is necessary
                        if (~match) begin   //if match == 0, then we are done
                            xout = cReg[XWIDTH-1:0];
                            cReg[XWIDTH-1:0] = k[XWIDTH-1:0];
                            cout = cReg;
                            next_state = DONE;
                        end
                        else begin //we need a new C from gascon, pass in current C
                        gasReset = 1'b1;
                        gasCin = cReg;
                        next_state = REPEAT_GAS;
                        newJ = 1;    
                        end
                    end
                    
                end
            end
            
            RESET_I: begin  //just a buffer stage to let I increment
                if (i == prevI) begin   //if it hasn't incremented yet
                    next_state = RESET_I;
                    increment_J = 1'b0;
                    iReset = 1'b0;
                    iReset = 1'b0;
                    jReset = 1'b0;
                    increment_I = 1'b1;
                end
                else begin  //if it has incremented we can return back to for loop state
                    next_state = REPEAT_FOR;
                    increment_J = 1'b0;
                    increment_I = 1'b0;
                    iReset = 1'b0;
                    jReset = 1'b1;  //we reset J here so that it takes on newJ which was set before
                                    //this also prevents state from being overwritten before RESET_I runs
                end
            end
            
            DONE: begin
                cout = cout;
                xout = xout;
                done = 1'b1;
                next_state = DONE;
            end

        endcase
    end
    
    Gascon_Core_Round #(.CWIDTH(CWIDTH), .ROUND_COUNT(1)) gascon (
            .clk(clk),
            .c(gasCin),
            .cout(gasOut),
            .round(1'b0),
            .reset(reset | gasReset),
            .done(gasDone)    
        );
    
endmodule
