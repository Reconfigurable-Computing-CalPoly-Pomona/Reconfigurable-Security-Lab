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
    input logic clk, reset,
    output logic done
    );
    
    localparam CWORDS64 = CWIDTH/64;
    localparam IDX_WIDTH = $clog2(XWORDS32);
    localparam DWIDTH = CWORDS64*IDX_WIDTH;
    localparam MIXROUNDS = (128+4)/DWIDTH;
    
    logic [255:0] iReg;
    logic [$clog2(256/DWIDTH) - 1:0] j;
    logic [DWIDTH-1:0] selOut, dReg;
    logic [CWIDTH-1:0] cReg, mixOut, gasOut;
    logic doneFor, mixDone, gasDone, mixReset, gasReset, increment;
    
    
    typedef enum {FIRST,START,WAITMIX,WAITGAS,DONEFOR, LAST, DONE} stateType;
    stateType curr_state, next_state;
    
    assign doneFor = (j >= MIXROUNDS-1) ? 1'b1:1'b0;
    assign iReg = {ds,i};
    assign cout = (done) ? cReg : 0;
    
    
    //Counter Logic
    always_ff @ (posedge clk, posedge reset)
        if (reset) j <= 0;
        else if (doneFor) j <= j;
        else if (increment) j <= j + 1;
        else j <= j;
      
    //State Register Block  
    always_ff @ (posedge clk, posedge reset)
        if (reset) curr_state <= FIRST;
        else curr_state <= next_state;
        
    //Next State Logic
    always_comb
    begin
        increment = 1'b0;
        case(curr_state) 
            FIRST:
                next_state = START;
            START:
                next_state = WAITMIX;
            
            WAITMIX: 
                if (mixDone) next_state = WAITGAS;
                else next_state = WAITMIX;
                
            WAITGAS:
                if (gasDone) 
                begin
                    if ((j + 1) >= MIXROUNDS-1) //if J incremented again would it be done?
                    begin   //if so, jump to doneFor and increment one more time since Sel uses MIXROUNDS-1 for index
                        next_state = DONEFOR;
                        increment = 1'b1;
                    end
                    else    //otherwise, keep iterating thru the for loop and jump to start
                    begin 
                        next_state = START;
                        increment = 1'b1;
                    end
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
            next_state = FIRST;
        endcase  
    end
    
    //Logic based on Curr-State    
    always_comb
        case(curr_state) 
            FIRST: 
            begin
                mixReset = 1'b1;
                gasReset = 1'b1;
                cReg = c;    
            end
            
            START:
            begin
                mixReset = 1'b1;
                gasReset = 1'b1;
                cReg = cReg;
                dReg = selOut;
                done = 1'b0;
            end
            
            WAITMIX: 
            begin
                mixReset = 1'b0;
                gasReset = 1'b1;
                dReg = dReg;
                done = 1'b0;
                if (mixDone) cReg = mixOut;
                else cReg = cReg;
            end
                
            WAITGAS:
            begin
                gasReset = 1'b0;
                mixReset = 1'b0;
                dReg = dReg;
                done = 1'b0;
                if (gasDone) cReg = gasOut;
                else cReg = cReg;
            end
            
            DONEFOR:
            begin
                cReg = cReg;
                {mixReset, gasReset} = {1'b1,1'b1};
                dReg = selOut;     
            end
            
            LAST:
            begin
                mixReset = 1'b0;
                gasReset = 1'b1;
                done = 1'b0;
                dReg = dReg;
                if (mixDone)
                begin
                    cReg = mixOut;
                    done = 1'b1;
                end 
                else cReg = cReg;      
            end
                
            DONE: 
            begin
                cReg = cReg;
                done = 1'b1;
            end
                  
            default: ;
//            next_state = START;
        endcase 
    
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
    
    selec_t #(.INPUT_WIDTH(256), .OUT_WIDTH(DWIDTH)) select1 (
        .inputVal(iReg),
        .index(j),
        .out1(selOut),
        .reset(reset)
    );
    
    mixsx32 #(.CWORDS64(CWORDS64), .XWORDS32(XWORDS32)) mix32 (
        .clk(clk),
        .reset(reset | mixReset),
        .c(cReg),
        .x(x),
        .d(dReg),
        .cout(mixOut),
        .data_rdy(mixDone)
    );
    
    Gascon_Core_Round #(.CWIDTH(CWIDTH), .ROUND_COUNT(1)) das_dat_gas (
        .c(cReg),
        .clk(clk),
        .reset(gasReset | reset),
        .round(1'b0),
        .cout(gasOut),
        .done(gasDone)
    );
    
    
endmodule
