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
    input logic reset,
    input logic clk,
    output logic doneOut
);

    localparam CWORDS64 = CWIDTH/64;
    localparam MID = (CWORDS64-1)/2;
    
    logic [$clog2(MID*2):0] d;
    logic [$clog2(CWORDS64)-1:0] s;
    logic [$clog2(CWORDS64)-1:0] index1, index2;
    logic [63:0] out1, out2, cRegNext, tRegNext;
    logic [CWIDTH-1:0] cSel2, cSel1;
    logic [CWIDTH-1:0] cReg, tReg;
    logic loop1, loop2, loop3, loop4, done, doneTrig;
    integer i, i2, i3, i4;
    logic [CWORDS64-1:0] cRegIndex, tRegIndex;
   
    //Counter Logic 
    always_ff @ (posedge clk, posedge reset)
        if (reset) begin i <= 0; end
        else if (i > MID) begin i <= i; end
        else begin i <= i + 1; end
        
    always_ff @ (posedge clk, posedge reset)
        if (reset) i2 <= 0;
        else if (loop1 && i2 < CWORDS64) i2 <= i2 + 1;
        else i2 <= i2;
    
    always_ff @(posedge clk, posedge reset)
        if (reset) i3 <= 0;
        else if (loop1 && loop2 && i3 < CWORDS64) i3 <= i3+1;
        else i3 <= i3;
        
     always_ff @(posedge clk, posedge reset)
       if (reset) i4 <= 0;
       else if (loop1 && loop2 && loop3 && i4 <= MID) i4 <= i4+1;
       else i4 <= i4;
    
    //Loop Finished Logic
    assign loop1 = (i > MID) ? 1'b1 : 1'b0;
    assign loop2 = (i2 >= CWORDS64) ? 1'b1 : 1'b0;
    assign loop3 = (i3 >= CWORDS64) ? 1'b1 : 1'b0;
    assign loop4 = (i4 > MID) ? 1'b1 : 1'b0;
    
    //Output Register Logic    
    always_ff @ (posedge clk, posedge reset)
        if (reset) cReg <= 0;
        else if ((~loop1) || (~loop3 && loop2) || (~loop4 && loop3)) cReg[cRegIndex*64 +: 64] <= cRegNext;
        else cReg <= cReg;
        
    always_ff @ (posedge clk, posedge reset)
        if (reset) tReg <= 0;
        else if ((~loop2 && loop1) || (~loop4 && loop3) || (loop4 && ~done)) tReg[tRegIndex*64 +: 64] <= tRegNext;
        else tReg <= tReg;
            
    always_comb begin
        if (~loop1) begin
            d = 2*i;
            cRegIndex = d;
            s = (CWORDS64 + d - 1) % CWORDS64;
            cSel1 = c;
            index1 = d; //sel1
            //sel2
            cSel2 = c;
            index2 = s;
            cRegNext = out1 ^ out2;     
        end
        
        else if (~loop2) begin
            tRegIndex = i2;
            s = (i2+1) % CWORDS64;  
            cSel1 = cReg;
            index1 = s;
            cSel2 = cReg;
            index2 = i2;  
            tRegNext = (~out2) & out1;
        end
        
        else if (~loop3) begin
            cRegIndex = i3;
            s = (i3+1) % CWORDS64;
            cSel1 = cReg;
            index1 = i3;
            cSel2 = tReg;
            index2 = s;    
            cRegNext = out1 ^ out2;
        end
        
       else if (~loop4) begin
            s = 2*i4;
            d = (s+1) % CWORDS64;
            cRegIndex = d;
            cSel1 = cReg;
            index1 = d;
            cSel2 = cReg;
            index2 = s;
            cRegNext = out1 ^ out2;   
       end 
       
       else 
           if (!done) begin
               tRegIndex = MID;
               cSel1 = tReg;
               index1 = MID;
               tRegNext = ~out1;
               doneTrig = 1;
           end
       

               
    end //end always_comb
    
    always_ff @(posedge clk, posedge reset)
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
    
    selec_t #(.INPUT_WIDTH(CWIDTH), .OUT_WIDTH(64)) select1 (
        .inputVal(cSel1),
        .index(index1),
        .out1(out1),
        .reset(reset)
    );
    
    selec_t #(.INPUT_WIDTH(CWIDTH), .OUT_WIDTH(64)) select2 (
        .inputVal(cSel2),
        .index(index2),
        .out1(out2),
        .reset(reset)
    );
endmodule
