`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2019 08:07:09 PM
// Design Name: 
// Module Name: linlayer
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


module linlayer #(parameter CWORDS64 = 9) (
    input logic [CWORDS64*64-1:0] c,
    output logic [CWORDS64*64-1:0] cout,
    input logic clk, reset, en,
    output logic done
    
);
    localparam [5:0] lut0 [0:8] = {6'd19,6'd61,6'd1,6'd10, 6'd7,6'd31,6'd53, 6'd9,6'd43};
    localparam [5:0] lut1 [0:8] = {6'd28,6'd38,6'd6,6'd17, 6'd40,6'd26,6'd58, 6'd46,6'd50};
    
    typedef enum {RESET, INIT, RUN, DONE} state_type;
    state_type curr_state, next_state;
    
    logic [3:0] i;
    logic [5:0] r0, r1;
    logic [63:0] w, rot1, rot2, cout_reg_next;
    logic [CWORDS64*64-1:0] cout_reg, cin_reg;
    logic wReady;
    logic i_or_cRegHold, readInput;
    
    
//    ila_linlayer_low ila_lin_low(
//        .clk(clk),
//        .probe0(w),
//        .probe1(rot1),
//        .probe2(rot2),
//        .probe3(i),
//        .probe4(r0),
//        .probe5(r1),
//        .probe6(cout_reg),
//        .probe7(cin_reg),
//        .probe8(c)
//    );
    
//    assign cout = cout_reg;
//    assign done = (i >= CWORDS64) ? 1:0;
    
    
    assign i_or_cRegHold = (i >= CWORDS64 || (curr_state != RUN)) ? 1 : 0;
    
    //register block for iterator
    always_ff @(posedge clk) begin
        if (reset)
            i <= 0;
        else if (i_or_cRegHold) i <= i;
        else if (curr_state == RUN) i <= i + 1;
        else i <= i;
    end
    
    //Register Block for State Register
    always_ff @(posedge clk) begin
        if (reset) curr_state <= RESET;
        else curr_state <= next_state;
    end
    
    //block for r0 and r1
    assign r0 = lut0[i];
    assign r1 = lut1[i];
    
    
    assign cout_reg_next = w ^ rot1 ^ rot2;
    //Register Block for Writing to Output Register
    always_ff @(posedge clk) begin
        if (reset) cout_reg <= 0;
        else if (i_or_cRegHold) cout_reg <= cout_reg;
        else cout_reg[(i*64) +: 64] <= cout_reg_next;
    end
    
    assign readInput = (curr_state == INIT) ? 1:0;
    //Register Block for Reading input to a register
    always_ff @(posedge clk) begin
        if (reset) cin_reg <= 0;
        else if (readInput) cin_reg <= c;
        else cin_reg <= cin_reg;
    end

    //Next State Logic
    always_comb begin
//        next_state = next_state;
        
        case (curr_state) 
            RESET: begin
                if (en) next_state = INIT;
                else next_state = RESET;
            end
            
            INIT: next_state = RUN;
           
            RUN: begin
                if (i >= CWORDS64) next_state = DONE;  
                else next_state = RUN;
            end
            
            DONE: next_state = DONE;
            
            default: next_state = RESET;
        endcase
    end
    
//    assign cout = cout_reg;
    //Combinational State Logic
    always_comb begin
        done = 0;
        cout = 0;
        
        case (curr_state)
            RESET: begin
                w = 0;
                cout = 0;
                done = 0;
            end
            
            INIT: begin
                w=0;//just stall, we are just waiting for input wire to propagate to cin_Reg
            end
            
            RUN: begin
                //read words from our input register, not the raw input wire
                if (i >= CWORDS64) w = 0;
                else w = cin_reg[(i*64) +: 64]; 
                
            end
            
            DONE: begin
                //output value of output register to output wire cout
//                cout = cout_reg;
                w=0;
                done = 1'b1;
                cout = cout_reg;
            end
            
            default: begin
                w = 0;
            end
        endcase
    end
    

//    selec_t #(.INPUT_WIDTH(576), .OUT_WIDTH(64)) selC (
//        .inputVal(c),
//        .reset(reset),
//        .index(i),
//        .out1(w)
//    );
    
    BiRotR first (
        .in(w),
        .shift(r0),
        .out(rot1),
        .reset(reset) 
    );
    
    BiRotR second (
        .in(w),
        .shift(r1),
        .out(rot2),
        .reset(reset)
    );
    
    
    
endmodule
