`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2019 12:00:12 AM
// Design Name: 
// Module Name: absorb
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


module absorb #(parameter CWIDTH = 320, parameter RWIDTH = 32, parameter XWIDTH = 64,
                parameter BWIDTH = 32, parameter NUMBLOCKS = 4) 
    (
        input logic [CWIDTH-1:0] c,
        input logic [RWIDTH-1:0] r,
        input logic [XWIDTH-1:0] x,
        input logic [(BWIDTH*NUMBLOCKS)-1:0] blocks,
        input logic finalize, clk, reset,
        input logic [1:0] domain,
        output logic [CWIDTH-1:0] cout,
        output logic [RWIDTH-1:0] rout,
        output logic [XWIDTH-1:0] xout,
        output logic done
    );
    
    localparam IWIDTH = 128;
    localparam B = (BWIDTH*NUMBLOCKS)/IWIDTH;
    
    typedef enum {INITIALIZE, START, WAITF, DONEFOR, FORF, DONE} state_type;
    state_type curr_state, next_state;
    
    logic fdone, func_en, count_valid, increment, f_reset, padded;
    logic [3:0] f_ds;
    logic [IWIDTH-1:0] f_dataIn, lastBlock;
    logic [CWIDTH-1:0] cReg, f_cout, f_cin;
    logic [RWIDTH-1:0] rReg, f_rout, f_rin;
    logic [XWIDTH-1:0] xReg, f_xout, f_xin;
    logic [$clog2(B-1):0] i;
    
    
    assign func_en = (B>0) ? 1:0;
    assign count_valid = (i < B-1) ? 1:0;
    

    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) i <= 0;
        else if (increment) i <= i + 1;
        else if (count_valid) i <= i + 1;
        else i <= i;
    end
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) curr_state <= INITIALIZE;
        else curr_state <= next_state;
    end
    
    always_comb begin
        f_ds = 0;
        increment = 1'b0;
        done = 1'b0;
        cReg = cReg;
        rReg = rReg;
        xReg = xReg;
        cout = cout;
        xout = xout;
        rout = rout;
        f_cin = f_cin;
        f_xin = f_xin;
        f_rin = f_rin;
        f_dataIn = f_dataIn;
        
        case (curr_state)
            INITIALIZE: begin
                f_cin = c;
                f_xin = x;
                f_rin = r;
                cReg = 0;
                xReg = 0;
                rReg = 0;
                f_reset = 1'b1;
                cout = 0;
                xout = 0;
                rout = 0;
                next_state = START;
            end
            
            START: begin
                f_reset = 1'b1;
                f_cin = f_cin;
                f_dataIn = blocks[i*IWIDTH +: IWIDTH];
                f_reset = 1'b0;
                next_state = WAITF;
            end
            
            WAITF: begin
                if (fdone) begin
                    cReg = f_cout;
                    xReg = f_xout;
                    f_reset = 1'b0;
                    increment = 1'b1;
                    if (count_valid) next_state = START;
                    else next_state = DONEFOR;   
                end
                else begin
                    cReg = cReg;
                    f_dataIn = f_dataIn;
                    f_reset = 1'b0;
                end
            end
            
            DONEFOR: begin
                f_reset = 1'b0;
                cReg = f_cout;
                xReg = f_xout;
                rReg = f_rout;
                f_cin = cReg;
                f_xin = xReg;
                f_rin = rReg;
                f_ds = {domain,finalize,padded};
                f_dataIn = lastBlock;
                f_reset = 1'b1;
                next_state = FORF;
            end
            
            FORF: begin
                f_reset = 1'b0;
                if (fdone) begin
                    cReg = f_cout;
                    xReg = f_xout;
                    next_state = DONE;
                    cout = cReg;
                    xout = xReg;
                    rout = rReg;
                end
                else begin
                    cReg = cReg;
                    xReg = xReg;
                    next_state = FORF;
                end
                
            end
            
            DONE: begin
                f_reset = 1'b0;
                cout = cout;
                xout = xout;
                next_state = DONE;
            end
   
   
       

        endcase
    
    end
    
    
    
    F #(.XWORDS32(XWIDTH/32), .DS_WIDTH(2), .ROUND_COUNT(128)) f (
        .clk(clk),
        .reset(reset | f_reset),
        .c(f_cin),
        .x(f_xin),
        .xout(f_xout),
        .rout(f_rout),
        .cout(f_cout),
        .i(f_dataIn),
        .rounds(7), //how are number of rounds calculated again? design parameter?
        .ds(f_ds),
        .done(fdone)
    );
    
    padding  #(.IWIDTH(IWIDTH), .BWIDTH(BWIDTH)) pad (
        .block(blocks[(B-1)*BWIDTH +: BWIDTH]),
        .blockOut(lastBlock),
        .padded(padded)
    );
endmodule
