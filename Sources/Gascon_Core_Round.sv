`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2019 09:49:00 PM
// Design Name: 
// Module Name: Gascon_Core_Round
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


module Gascon_Core_Round #(parameter CWIDTH = 320, parameter ROUND_COUNT = 16)(
    input logic [CWIDTH-1:0] c,
    output logic [CWIDTH-1:0] cout,
    input logic [ROUND_COUNT-1:0] round,
    input logic reset, en,
    input logic clk,
    output logic done
    );
    
    integer mask=4'hf;
    localparam CWORDS64 = CWIDTH/64;
    localparam MID = (CWORDS64-1)/2;
    localparam c64 = 64;
    logic [c64-1:0] c_reg;
//    logic [CWIDTH-1:0] c_reg_select;
    logic [CWIDTH-1:0] c_reg_int, c_reg_input, c_reg_out;
    logic [CWIDTH-1:0] c_reg_sbox, lin_cout;
    logic [c64-1:0] shift_reg; 
    logic linlayer_en;
    logic linlayer_reset, lin_done;
    logic read_input, hold_reg;
    logic sbox_en;
//    logic reset, r_pipe;
    
    typedef enum {RESET, INIT, RUN, STALL, WRITE_OUT, DONE} state_type;
    state_type curr_state, next_state;
    
//    //Block for Synchronously Exiting the Reset Stage to Avoid Metastability
//    always_ff @(posedge clk, posedge resetRaw) begin
//        if (resetRaw) 
//            {reset, r_pipe} <= 2'b11;
//        else 
//            {reset, r_pipe} <= {r_pipe, 1'b0};
//    end
    
    //State Register Block
    always_ff @(posedge clk) begin
        if (reset) curr_state <= RESET;
        else curr_state <= next_state;
    end
    
    assign read_input = (curr_state == INIT) ? 1:0;
    always_ff @ (posedge clk) begin
        if (reset) c_reg_input <= 0;
        else if (read_input) c_reg_input <= c;
        else c_reg_input <= c_reg_input;
    end
    
    //register block for holding output of gascon
    assign hold_reg = (curr_state != WRITE_OUT) ? 1:0;
    always_ff @ (posedge clk) begin
        if (reset) c_reg_out <= 0;
        else if (hold_reg) c_reg_out <= c_reg_out;
        else c_reg_out <= lin_cout;
    end
    
    always_comb begin
        if (!reset) begin
            shift_reg=((mask - round) << 4);
            shift_reg = shift_reg | round;
        end
        else shift_reg = 0;
    end
    
    always_comb begin
        if (reset) begin
            c_reg_int = 0;
        end
        else begin
            c_reg_int = c_reg_input;
            c_reg_int[MID*64 +: 64] = shift_reg^c_reg_int[MID*64 +: 64];
        end
    end
    
    always_comb
    begin
//        shift_reg = shift_reg;
        done = 0;
        case (curr_state) 
            RESET: begin
                done = 0;
                cout = 0;
                sbox_en = 0;
                if (en) next_state = INIT;
                else next_state = RESET;
            end
            
            INIT: begin
                next_state = RUN;//just wait for c_Reg_input to be populated 
                cout = 0;
                sbox_en = 0;
            end
            
            RUN: begin
                next_state = STALL;
                cout = 0;
                sbox_en = 0;
            end
            
            STALL: begin
                sbox_en = 1'b1;
                if (lin_done) next_state = WRITE_OUT;
                else next_state = STALL;
                cout = 0;
                //just sit here and wait for lower modules to complete computation 
            end
        
            WRITE_OUT: begin
                sbox_en = 1'b1;
                //in this stage, cout_reg will take in the output of linlayer
                next_state = DONE;
                cout = 0;
                
            end
            
            DONE: begin
                sbox_en = 1'b1;
                //write output in register to output wire and raise the done flag
                cout = c_reg_out;
                done = 1'b1;
                next_state = DONE;
            end
            
            default: begin
                sbox_en = 0;
                next_state = RESET;
                cout = 0;
            end
            
        
        endcase
    end
    
//    selec_t #(.INPUT_WIDTH(CWIDTH), .OUT_WIDTH(64)) select1 (
//        .inputVal(c),
//        .index(MID),
//        .out1(c_reg),
//        .reset(reset)
//    );
    
    //Block to replace select module
//    always_comb begin
//        c_reg = c_reg;
        
//        if (!reset) c_reg = c[MID*64 +: 64];
//        else c_reg = 0;
//    end

 
    sboxV2 #(.CWIDTH(CWIDTH)) sBOX (
        .c(c_reg_int),
        .cout(c_reg_sbox),
        .reset(reset | ~sbox_en),
        .clk(clk),
        .doneOut(linlayer_en),
        .en(sbox_en)
    );
    
//    assign linlayer_reset = reset | ~linlayer_en;
    
    linlayer #(.CWORDS64(CWORDS64)) LINLAYER_DUDE (
        .c(c_reg_sbox),
        .cout(lin_cout),
        .clk(clk), 
        .reset(reset),
        .en(linlayer_en),
        .done(lin_done)
    );
    
//    ila_gascon_internal ila_gascon(
//        .clk(clk),
//        .probe0(c),
//        .probe1(cout),
//        .probe2(reset),
//        .probe3(done),
//        .probe4(c_reg_input),
//        .probe5(c_reg_int),
//        .probe6(c_reg_sbox),
//        .probe7(shift_reg),
//        .probe8(lin_done),
//        .probe9(lin_cout),
//        .probe10(c_reg_out),
//        .probe11(curr_state)
//    );


endmodule
