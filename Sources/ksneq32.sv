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


module ksneq32 #(parameter MINWIDTH_K = 128, parameter KWIDTHMAX = 448, parameter CWIDTH = 128, parameter XWIDTH = 64) (
    input logic [KWIDTHMAX-1:0] k,
    input logic [1:0] kWidth,
    input logic clk,reset,en,
    output logic [CWIDTH-1:0] cout,
    output logic [XWIDTH-1:0] xout,
    output logic done
);

    localparam XWORDS = XWIDTH/32;
    localparam KWORDS = MINWIDTH_K/32;
    localparam FASTWIDTH = MINWIDTH_K + XWIDTH;
    localparam FULLWIDTH = CWIDTH+XWIDTH;
    
    logic [KWIDTHMAX-1:0] kReg;
    logic [CWIDTH-1:0] cReg, cRegNext;
    logic [XWIDTH-1:0] xReg, xRegNext;
    logic iReset, jReset, gasReset, gas_en;
    logic increment_I, increment_J;
    logic [$clog2(CWIDTH/32):0] i, prevI;
    logic [$clog2(XWORDS+1):0] j, newJ; 
    
    logic [CWIDTH-1:0] gasCin, gasOut;
    logic gasDone;
    logic match, matchNext;
    logic gasReset_flag;
    
    logic iResetFlag, jResetFlag;
    logic cRegHold, xRegHold;
    logic read_Input;
//    logic reset, r_pipe;
    
    enum {MIN = 0,FAST = 1,FULL = 2} kSizes;
    typedef enum {RESET, INITIALIZE, CHECK_K, FIRST_FOR, SECOND_FOR,REPEAT_GAS, REPEAT_FOR, RESET_I, DONE} state_type;
    state_type curr_state, next_state;
    
    
//    //Block for Synchronously Exiting the Reset Stage to Avoid Metastability
//    always_ff @(posedge clk, posedge resetRaw) begin
//        if (resetRaw) 
//            {reset, r_pipe} <= 2'b11;
//        else 
//            {reset, r_pipe} <= {r_pipe, 1'b0};
//    end
    
    always_ff @(posedge clk) begin
        if (reset) match <= 0;
        else match <= matchNext;
    end
    
    assign iResetFlag = reset || iReset;
    //i counter
    always_ff @(posedge clk)
    begin
        if (iResetFlag) i <= 0;
        else if (increment_I) i <= i + 1;
        else i <= i;
    end
    
    assign jResetFlag = reset || jReset;
    //j counter
//    initial j = 1; //initializing value upon startup/powerup
    always_ff @(posedge clk)
    begin
        if (jResetFlag) j <= i+1;
        else if (increment_J) j <= j + 1;
        else j <= j;
    end
    
    //Register for State
    always_ff @(posedge clk)
    begin
        if (reset) curr_state <= RESET;
        else curr_state <= next_state;
    end
    
//    assign cRegHold = (curr_state == DONE) ? 1:0;
    //Register for C
    always_ff @ (posedge clk)
    begin
        if (reset) cReg <= 0;
        else if (cRegHold) cReg <= cReg;
        else cReg <= cRegNext;
    end
    
    always_ff @ (posedge clk)
    begin
        if (reset) xReg <= 0;
        else if (xRegHold) xReg <= xReg;
        else xReg <= xRegNext;
    end
    
    //Register for Reading input K
    assign read_Input = (curr_state == INITIALIZE) ? 1:0;
    always_ff @ (posedge clk) 
    begin
        if (reset) kReg <= 0;
        else if (read_Input) kReg <= k;
        else kReg <= kReg;
    end
    
    //Combinational State Logic
    always_comb
    begin
        //setting default values
        done = 0;
        xout = 0;
        cout = 0;
        newJ = i+1;
        matchNext = match;
        prevI = i;
        iReset = 0;
        jReset = 0;
        gasCin = cReg;
        gasReset = 0;
        cRegNext = cReg;
        increment_I = 0;
        increment_J = 0;
        cRegHold = 1;
        xRegHold = 1;
        xRegNext = xReg;
        gas_en = 0;

        
        case(curr_state)
            RESET: begin
                cRegHold = 0;
                matchNext = 0;
                cout = 0;
                xout = 0;
                gasReset = 1'b1;
                newJ = 1;
                iReset = 1'b1;
                jReset = 1'b1;
                cRegNext = 0;
                prevI = 0;
                done = 0;
                increment_I = 0;
                increment_J = 0;
                gasCin = 0;
                xRegNext = 0;
                xRegHold = 0;
            end
        
            INITIALIZE: begin
                ; //here we wait for the k input to be written to our input register kReg 
                increment_I = 1'b0;
            end
            
            CHECK_K: begin
                increment_I = 1'b0;
                if (kWidth == FULL) begin
                    xRegHold = 0;
                    cRegHold = 0;
                    cRegNext = kReg[CWIDTH-1:0];
                    xRegNext = kReg[FULLWIDTH-1:CWIDTH];
                end
                else begin
                    cRegNext = 0;
                    xRegNext = 0;
                end
            end
            
            FIRST_FOR: begin
                iReset = 0;
                jReset = 0;
                cRegHold = 0;
                xRegHold = 1;
                if (i <= (CWIDTH/32)-1) begin
                   cRegNext = cReg;
                   cRegNext[i*32 +: 32] = kReg[(i%KWORDS)*32 +: 32]; //if KWORDS is 1, all cReg 32 bit words will be same
                   increment_I = 1'b1;
                end
                else begin //for loop is finished
                    increment_I = 1'b0;
                    if (kWidth == FAST) begin
                        //we are done
                        cRegHold = 1;
                        xRegHold = 0;
                        xRegNext = kReg[FASTWIDTH-1:MINWIDTH_K];
//                        cout = cReg;
                    end
                    else begin
                        //start running gascon if kWidth is minimum
                        cRegHold = 1;
                        xRegHold = 1;
                        gasReset = 1'b1;
                        gasCin = cReg;
                    end
                end
            end
                
            REPEAT_GAS: begin
                gas_en = 1'b1;
                iReset = 1'b1;
                xRegHold = 1;
                if (gasDone) begin
                    cRegHold = 0;
                    gasReset = 1'b0;
                    cRegNext = gasOut;
                    newJ = 1;
                    iReset = 1'b1;
                    jReset = 1'b1;    
                    matchNext = 0; //reset match variable
                    gasCin = gasCin;
                end
                else begin
                    cRegHold = 1;
                    gasCin = cReg;   
                    gasReset = 1'b0;
                end
                
            end
            
            REPEAT_FOR: begin
                jReset = 1'b0;
                iReset = 1'b0;
                cRegHold = 1'b1;
                xRegHold = 1'b1;
                if (j <= XWORDS) begin //if inner for loop is still going
                    if (cReg[i*32 +: 32] == cReg[j*32 +: 32]) matchNext = 1;
                    increment_J = 1'b1;
                    increment_I = 1'b0;
                end
                
                else begin //inner for loop is finished
                    if (i <= XWORDS-1) begin //if outer for loop not finished yet
                        prevI = i;
                        newJ = i+2;
                        increment_I = 1'b1;
                        increment_J = 1'b0;
                        jReset = 1'b0;
//                        if (special_increment_I) begin //if was already incremented  
//                            increment_J = 1'b0;
//                            jReset = 1'b1;
//                        end
//                        else begin
//                            increment_J = 1'b0;
//                            special_increment_I = 1'b1;
//                        end
//                        jReset = 1'b0; //dont reset here, because it will rerun combo block before RESET_I state runs
                    end
                    else begin //outer loop is done (0 to XWORDS-1)
                        //check if a repeat is necessary
                        if (!match) begin   //if match == 0, then we are done
                            cRegHold = 1'b0;
                            xRegHold = 1'b0;
                            xRegNext = cReg[XWIDTH-1:0];
                            cRegNext[XWIDTH-1:0] = kReg[XWIDTH-1:0]; 
                            cRegNext[CWIDTH-1:XWIDTH] = cReg[CWIDTH-1:XWIDTH];//potentially remove this and add later to be blocking
//                            cout = cReg; //we read cReg into cOut at next clock cycle in done state, not here
                        end
                        else begin //we need a new C from gascon, pass in current C
                            cRegHold = 1;
                            xRegHold = 1;
                            gasReset = 1'b1;
                            gasCin = cReg;
                            newJ = 1;    
                        end
                    end
                    
                end
            end
            
            RESET_I: begin  //just a buffer stage to let I increment
                prevI = prevI;
                newJ = newJ;
                cRegHold = 1'b1;
                xRegHold = 1'b1;
                gasCin = gasCin;
//                if (i == prevI) begin   //if it hasn't incremented yet
//                    increment_J = 1'b0;
//                    iReset = 1'b0;
//                    jReset = 1'b0;
//                    increment_I = 1'b1;
//                end
//                else begin  //if it has incremented we can return back to for loop state
                increment_J = 1'b0;
                increment_I = 1'b0;
                iReset = 1'b0;
                jReset = 1'b1;  //we reset J here so that it takes on newJ which was set before
                                //this also prevents state from being overwritten before RESET_I runs
//                end
            end
            
            DONE: begin
                cRegHold = 1'b1;
                xRegHold = 1'b1;
                cout = cReg;
                xout = xReg;
                done = 1'b1;
                increment_J = 1'b0;
                increment_I = 1'b0;
            end

        endcase
    end
    
    //Next State Combo Logic
    always_comb begin
        case (curr_state) 
            RESET: if (en) next_state = INITIALIZE;
                   else next_state = RESET;
            
            INITIALIZE: next_state = CHECK_K;
            
            CHECK_K: 
                if (kWidth == FULL) next_state = DONE;
                else next_state = FIRST_FOR;
            
            FIRST_FOR:        
                if (i <= (CWIDTH/32)-1) next_state = FIRST_FOR;
                
                else begin //for loop is finished
                    if (kWidth == FAST) next_state = DONE;
                    else next_state = REPEAT_GAS;
                end
                
            REPEAT_GAS:
                if (gasDone) next_state = REPEAT_FOR;
                else next_state = REPEAT_GAS;
                
            REPEAT_FOR:
                if (j <= XWORDS) next_state = REPEAT_FOR;
                
                else 
                    //if outer loop not finished
                    if (i <= XWORDS-1) next_state = RESET_I;
                    else 
                        //outer loop is done (0 to XWORDS-1)
                        //check if a repeat is necessary
                        if (!match) next_state = DONE;
                        else next_state = REPEAT_GAS;
            
            RESET_I:
//                if (i == prevI) next_state = RESET_I;    //if it hasn't incremented yet
//                else 
                next_state = REPEAT_FOR;
                
            DONE: next_state = DONE;
            
            default: next_state = RESET;
            
            
        
        endcase
    end //end Next State Logic
        
    assign gasReset_flag = reset | gasReset;
    Gascon_Core_Round #(.CWIDTH(CWIDTH), .ROUND_COUNT(1)) gascon (
        .clk(clk),
        .c(gasCin),
        .cout(gasOut),
        .round(1'b0),
        .reset(gasReset_flag),
        .en(gas_en),
        .done(gasDone)    
    );
    
    logic mR_gasR;
    assign mR_gasR = gasReset_flag;
        
//    ila_ksneq_inside ila_inside_ksneq(
//        .clk(clk),
//        .probe0(kReg),
//        .probe1(cout),
//        .probe2(xout),
//        .probe3(done),
//        .probe4(gasCin),
//        .probe5(gasOut),
//        .probe6(mR_gasR),
//        .probe7(gasDone),
//        .probe8(cReg),
//        .probe9(i),
//        .probe10(j),
//        .probe11(prevI),
//        .probe12(newJ),
//        .probe13(increment_I),
//        .probe14(increment_J),
//        .probe15(iResetFlag),
//        .probe16(jResetFlag),
//        .probe17(curr_state),
//        .probe18(next_state),
//        .probe19(xReg),
//        .probe20(cRegHold),
//        .probe21(xRegHold)
//    );

//    input [191 : 0] probe0;
//    input [319 : 0] probe1;
//    input [127 : 0] probe2;
//    input [0 : 0] probe3;
//    input [319 : 0] probe4;
//    input [319 : 0] probe5;
//    input [0 : 0] probe6;
//    input [0 : 0] probe7;
//    input [319 : 0] probe8;
    
endmodule
