`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2019 02:13:58 PM
// Design Name: 
// Module Name: Mix128
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


module Mix128 #(parameter CWIDTH = 127, parameter XWORDS32 = 2, parameter DS_WIDTH = 128) (
    input logic [CWIDTH-1:0] c,
    input logic [XWORDS32*32-1:0] x,
    input logic [127:0] i,
    input logic [DS_WIDTH-1:0] ds,
    output logic [CWIDTH-1:0] cout,
    input logic clk, reset, en,
    output logic done
    );
    
    localparam NUMER = 132;
    localparam CWORDS64 = CWIDTH/64;
    localparam IDX_WIDTH = $clog2(XWORDS32);
    localparam DWIDTH = CWORDS64*IDX_WIDTH;
    localparam MIXROUNDS = (NUMER)/DWIDTH;
    
    logic [(DS_WIDTH+128)-1:0] i_value;
    logic [$clog2(MIXROUNDS) - 1:0] j;
    logic [DWIDTH-1:0] selOut, d;
    logic [CWIDTH-1:0] cReg, mixOut, gasOut, cRegNext;
    logic doneFor, mixDone, gasDone, mixReset, gasReset, increment, gas_en, mix_en;
    
    
    typedef enum {RESET, INIT,START, WAITMIX, WAITGAS, DONEFOR, LAST, DONE} stateType;
    stateType curr_state, next_state;
    
    assign doneFor = (j >= MIXROUNDS-1) ? 1'b1:1'b0;
    assign i_value = {ds,i};
//    assign cout = (done) ? cReg : 0;
    
    
    //Counter Logic
    always_ff @ (posedge clk)
        if (reset) j <= 0;
        else if (doneFor) j <= j;
        else if (increment) j <= j + 1;
        else j <= j;
    
    //Register for Holding Coutput between iterations and modules  
    always_ff @ (posedge clk)
        if (reset) cReg <= 0;
        else cReg <= cRegNext;
      
    //State Register Block  
    always_ff @ (posedge clk)
        if (reset) curr_state <= RESET;
        else curr_state <= next_state;
        
    //Next State Logic
    always_comb
    begin
//        increment = 1'b0;
        case(curr_state) 
            RESET:
                if (en) next_state = INIT;
                else next_state = RESET;
                
            INIT:
                next_state = START;
            
            START: next_state = WAITMIX;
            
            WAITMIX: 
                if (mixDone) next_state = WAITGAS;
                else next_state = WAITMIX;
                
            WAITGAS:
                if (gasDone) begin
                    if ((j + 1) >= MIXROUNDS-1) //if J incremented again would it be done?
                    //if so, jump to doneFor and increment one more time since Sel uses MIXROUNDS-1 for index
                        next_state = DONEFOR;
//                        increment = 1'b1;

                    else    //otherwise, keep iterating thru the for loop and jump to start
                        next_state = START;
//                        increment = 1'b1;
                    
                end
                else next_state = WAITGAS;  //if gas isnt done stay in this state
                
            DONEFOR:
                next_state = LAST;
                
            LAST:
                if (mixDone) next_state = DONE;  
                else next_state = LAST;
            
            DONE:
                next_state = DONE;   
                
            default:
            next_state = RESET;
        endcase  
    end
    
    //Logic based on Curr-State    
    always_comb begin
        //default values for combinational signals
        gas_en = 0;
        done = 0;
        mix_en = 0;
        cRegNext = cReg;
        mixReset = 0;
        gasReset = 0;
        increment = 0;
        
        case(curr_state) 
            RESET: 
            begin
                //statements not really necessary(default), all flip flops will reset here
                //this state will hold until enable pulse is detected
                gas_en = 0;
                mix_en = 0;
                mixReset = 0;
                increment = 0;
            end
            
            INIT: begin
                //enable pulse detected, so register the c input into cReg
                cRegNext = c;
                increment = 0;  //dont start incrementing counter yet
            end
            
            START:
            begin
                //this state is when the loop reruns, both modules are reset and then enabled 
                //in the following states
                mixReset = 1'b1;
                gasReset = 1'b1;
                cRegNext = cReg; //current cReg is maintained
                done = 1'b0;
                increment = 0;
            end
            
            WAITMIX: 
            begin
                //mix is enabled here and run
                mix_en = 1;
                done = 1'b0;
                if (mixDone) cRegNext = mixOut; //if mix is finished, then load its output into Creg
                else cRegNext = cReg;           //otherwise, maintain value of Creg
            end
                
            WAITGAS:
            begin
                //now gascon runs, so we enable it and wait for it to finish
                gas_en = 1;
                done = 1'b0;
                if (gasDone) begin
                    cRegNext = gasOut; //if gas is finished, load output into cReg
                    increment = 1'b1; //we now increment the counter for START or LAST state
                end
                else cRegNext = cReg;           //otherwise, maintain value of creg
            end
            
            DONEFOR:
            begin
                //the for loop is finished
                cRegNext = cReg; //maintain value of cReg
                mixReset = 1'b1; //reset mix because its going to be used one more time
                mix_en = 0; //disable so that it doesnt start before next state
            end
            
            LAST:
            begin
                mixReset = 1'b0; //turn off reset
                mix_en = 1; //enable mix to start

                if (mixDone) cRegNext = mixOut; //if mix is done then load output into cReg
                else cRegNext = cReg; //otherwise hold cReg
            end
                
            DONE: 
            begin
                cout = cReg;
                cRegNext = cReg;
                done = 1'b1;
            end
                  
            default: begin//the default is the reset state
                gas_en = 0;
                mix_en = 0;
                mixReset = 0;
                increment = 0;
            end
        endcase 
    end //end always_comb
        
        //    always_comb begin
    //        if (j == 0) cReg = c;
        
//        if (!doneFor) begin
//            done = 1'b0;
//            manReset = 1'b0;
//            dReg = selOut;
            
//            while (!mixDone) continue;
//            cReg = mixOut;
//            while (!gasDone) continue;
//            cReg = gasOut;
//        end
        
//        else begin
//            selIndex = MIXROUNDS - 1;
//            dReg = selOut;    
//            manReset = 1'b1;
//            while (!mixDone) continue;
//            cout = mixOut;
//            done = 1'b1;
//        end
//    end
    
//    selec_t #(.INPUT_WIDTH(256), .OUT_WIDTH(DWIDTH)) select1 (
//        .inputVal(iReg),
//        .index(j),
//        .out1(selOut),
//        .reset(reset)
//    );
    
    //Comb Block that replaces select
    assign d = selOut;
    always_comb begin
        if (reset) selOut = 0;
        else selOut = i_value[(j*DWIDTH) +: DWIDTH];
        
    
    end
    
    mixsx32 #(.CWORDS64(CWORDS64), .XWORDS32(XWORDS32)) mix32 (
        .clk(clk),
        .reset(reset | mixReset),
        .en(mix_en),
        .c(cReg),
        .x(x),
        .d(d),
        .cout(mixOut),
        .done(mixDone)
    );
    
    Gascon_Core_Round #(.CWIDTH(CWIDTH), .ROUND_COUNT(1)) gascon (
        .c(cReg),
        .clk(clk),
        .reset(gasReset | reset),
        .round(1'b0),
        .cout(gasOut),
        .done(gasDone),
        .en(gas_en)
    );
    
    
endmodule
