`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2019 02:45:08 PM
// Design Name: 
// Module Name: sbox
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


module sbox #(parameter CWIDTH = 127) (
    input logic [CWIDTH-1:0] c,
    output logic [CWIDTH-1:0] cout,
    input logic reset, en,
    input logic clk,
    output logic doneOut
);

    localparam CWORDS64 = CWIDTH/64;
    localparam MID = (CWORDS64-1)/2;
    
    logic [$clog2(MID*2):0] d;
    logic [$clog2(CWORDS64)-1:0] s;
    logic [$clog2(CWORDS64)-1:0] index1, index2;
    logic [63:0] out1, out2;
                                
    logic [CWIDTH-1:0] cSel2, cSel1;
    logic [CWIDTH-1:0] cReg, tReg, cRegNext, tRegNext;
    logic loop1, loop2, loop3, loop4, done, doneTrig;
    integer i, i2, i3, i4;
    logic [CWORDS64-1:0] cRegIndex, tRegIndex;
    
    //State Signal declarations
    typedef enum {RESET, INIT, RUN, DONE} state_type;
    state_type curr_state, next_state;
    
    //State Register Logic
    always_ff @ (posedge clk)
        if (reset) curr_state <= RESET;
        else curr_state <= next_state;
   
    //Counter Logic 
    always_ff @ (posedge clk)
        if (reset) i <= 0; 
        else if (i > MID || curr_state != RUN) i <= i; 
        else i <= i + 1; 
        
    always_ff @ (posedge clk)
        if (reset) i2 <= 0;
        else if (loop1 && i2 < CWORDS64) i2 <= i2 + 1;
        else i2 <= i2;
    
    always_ff @(posedge clk)
        if (reset) i3 <= 0;
        else if (loop1 && loop2 && i3 < CWORDS64) i3 <= i3+1;
        else i3 <= i3;
        
     always_ff @(posedge clk)
       if (reset) i4 <= 0;
       else if (loop1 && loop2 && loop3 && i4 <= MID) i4 <= i4+1;
       else i4 <= i4;
       
    
    //Loop Finished Logic
    assign loop1 = (i > MID) ? 1'b1 : 1'b0;
    assign loop2 = (i2 >= CWORDS64) ? 1'b1 : 1'b0;
    assign loop3 = (i3 >= CWORDS64) ? 1'b1 : 1'b0;
    assign loop4 = (i4 > MID) ? 1'b1 : 1'b0;
    
    //Output Register Logic    
    always_ff @ (posedge clk)
        if (reset) cReg <= 0;
        else if ((~loop1) || (~loop3 && loop2) || (~loop4 && loop3)) cReg <= cRegNext;
        else cReg <= cReg;
        
    always_ff @ (posedge clk)
        if (reset) tReg <= 0;
        else if ((~loop2 && loop1) || (~loop4 && loop3) || (loop4 && ~done)) tReg <= tRegNext;
        else tReg <= tReg;
    
    //Next State Combo Logic:
    always_comb begin
        case (curr_state) 
            RESET: 
                if (en) next_state = INIT;
                else next_state = RESET;
            INIT: begin
                next_state = RUN;
            end
            RUN: begin 
                if (!done) next_state = RUN;
                else next_state = DONE;
            end
            DONE: next_state = DONE;
            default: next_state = RESET;
        endcase
    end
    
    //State Combinational Logic:
    always_comb begin
        d = 0;
        s = 0;
        index1 = 0;
        index2 = 0;
        cRegNext = cReg;
        tRegNext = tReg;
        cSel1 = cReg;
        cSel2 = cReg;
        doneTrig = 0;
        cRegIndex = 0;
        tRegIndex = 0;
        
        case (curr_state) 
            RESET: begin
                d = 0;
                s = 0;
                index1 = 0;
                index2 = 0;
                cRegNext = 0;
                tRegNext = 0;
                cSel1 = 0;
                cSel2 = 0;
                doneTrig = 0;
                cRegIndex = 0;
                tRegIndex = 0;
            end
            
            INIT: begin
                //in this stage cRegNext takes in the original input C
                cRegNext = c;
            end
            
            RUN: begin
                if (!loop1) begin
                    d = 2*i;
                    cRegIndex = d;
                    s = (CWORDS64 + d - 1) % CWORDS64;
                    cSel1 = c;
                    index1 = d; //sel1
                    //sel2
                    cSel2 = c;
                    index2 = s;
                    cRegNext = cReg;
                    cRegNext[(cRegIndex*64) +: 64] = out1 ^ out2;     
                end
            
                else if (!loop2) begin
                    tRegIndex = i2;
                    s = (i2+1) % CWORDS64;  
                    cSel1 = cReg;
                    index1 = s;
                    cSel2 = cReg;
                    index2 = i2; 
                    tRegNext = tReg; 
                    tRegNext[(tRegIndex*64) +: 64] = (~out2) & out1;
                end
                
                else if (!loop3) begin
                    cRegIndex = i3;
                    s = (i3+1) % CWORDS64;
                    cSel1 = cReg;
                    index1 = i3;
                    cSel2 = tReg;
                    index2 = s;    
                    cRegNext = cReg;
                    cRegNext[(cRegIndex*64) +: 64] = out1 ^ out2;
                end
                
                else if (!loop4) begin
                    s = 2*i4;
                    d = (s+1) % CWORDS64;
                    cRegIndex = d;
                    cSel1 = cReg;
                    index1 = d;
                    cSel2 = cReg;
                    index2 = s;
                    cRegNext = cReg;
                    cRegNext[(cRegIndex*64) +: 64] = out1 ^ out2;   
                end 
               
                else 
                   if (!done) begin
                       tRegIndex = MID;
                       cSel1 = tReg;
                       index1 = MID;
                       tRegNext = ~out1;
                       doneTrig = 1;
                   end
                end
            DONE: begin
                doneTrig = 1;
            end
            
            default: begin
                d = 0;
                s = 0;
                index1 = 0;
                index2 = 0;
                cRegNext = 0;
                tRegNext = 0;
                cSel1 = 0;
                cSel2 = 0;
                doneTrig = 0;
                cRegIndex = 0;
                tRegIndex = 0;
            end
        endcase
    end //end Combinational State Logic

    
    always_ff @(posedge clk)
        if (reset) done <= 1'b0;
        else if (loop4 && doneTrig) done <= 1'b1;
        else done <= done;
     
    assign doneOut = done;
//    always_comb begin
//            loop1 = 1'b0;
//            cReg = 0;
//        for (i = 0; i <= MID; i++) begin
//            d[i] = 2*i;
//            s[i] = (CWORDS64 + d - 1) % CWORDS64;
//            index1 = d[i]; //sel1
//            //sel2
//            cSel2 = c;
//            index2 = s[i];
//            cReg[d*64 +: 64] = out1 ^ out2;           
//        end
//            loop1 = 1'b1;
        
//    end
    
    
    //output
    assign cout = cReg;
    
//    selec_t #(.INPUT_WIDTH(CWIDTH), .OUT_WIDTH(64)) select1 (
//        .inputVal(cSel1),
//        .index(index1),
//        .out1(out1),
//        .reset(reset)
//    );
    
    //replaces first select
    always_comb begin
       
        if (!reset) out1 = cSel1[64*index1 +: 64];
        else out1 = 0;
    end
    
//    selec_t #(.INPUT_WIDTH(CWIDTH), .OUT_WIDTH(64)) select2 (
//        .inputVal(cSel2),
//        .index(index2),
//        .out1(out2),
//        .reset(reset)
//    );
    
    always_comb begin
       
        if (!reset) out2 = cSel2[64*index2 +: 64];
        else out2 = 0;
    end
    
//    ila_sbox ila_sbox_in(
//        .clk(clk),
//        .probe0(cRegNext),
//        .probe1(tRegNext),
//        .probe2(cReg),
//        .probe3(tReg),
//        .probe4(i),
//        .probe5(i2),
//        .probe6(i3),
//        .probe7(i4),
//        .probe8(cRegIndex),
//        .probe9(tRegIndex),
//        .probe10(out1),
//        .probe11(out2),
//        .probe12(d),
//        .probe13(s),
//        .probe14(loop1),
//        .probe15(loop2),
//        .probe16(loop3),
//        .probe17(loop4)
//    );
    
//    logic [$clog2(MID*2):0] d;
//    logic [$clog2(CWORDS64)-1:0] s;
//    logic [$clog2(CWORDS64)-1:0] index1, index2;
//    logic [63:0] out1, out2, cRegNext, tRegNext;
//    logic [CWIDTH-1:0] cSel2, cSel1;
//    logic [CWIDTH-1:0] cReg, tReg;
//    logic loop1, loop2, loop3, loop4, done, doneTrig;
//    integer i, i2, i3, i4;
//    logic [CWORDS64-1:0] cRegIndex, tRegIndex;

//    input [63 : 0] probe0;
//input [63 : 0] probe1;
//input [319 : 0] probe2;
//input [319 : 0] probe3;
//input [31 : 0] probe4;
//input [31 : 0] probe5;
//input [31 : 0] probe6;
//input [31 : 0] probe7;
//input [4 : 0] probe8;
//input [4 : 0] probe9;
endmodule
