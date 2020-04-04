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


module absorb #(parameter CWIDTH = 320, parameter RWIDTH = 192, parameter XWIDTH = 128,
                parameter BWIDTH = 32, parameter NUMBLOCKS = 4, parameter ROUND_COUNT = 4) 
    (
        input logic [CWIDTH-1:0] c,
        input logic [RWIDTH-1:0] r,
        input logic [XWIDTH-1:0] x,
        input logic [(BWIDTH*NUMBLOCKS)-1:0] blocks,
        input logic finalize, clk, reset, en,
        input logic [1:0] domain,
        input logic [ROUND_COUNT-1:0] rounds,
        output logic [CWIDTH-1:0] cout,
        output logic [RWIDTH-1:0] rout,
        output logic [XWIDTH-1:0] xout,
        output logic done
    );
    
    localparam IWIDTH = 128;
    localparam B = (BWIDTH*NUMBLOCKS)/IWIDTH;
    
    typedef enum {RESET, READ_IN, START, WAITF, RESTART, DONEFOR, LASTF, DONE} state_type;
    state_type curr_state, next_state;
    
    logic fdone, count_valid, increment, f_reset, f_en, padded;
    logic read_input;
    logic [3:0] f_ds;
    logic [IWIDTH-1:0] f_dataIn, lastBlock;
    logic [CWIDTH-1:0] cReg, cRegNext, f_cout, f_cin;
    logic [RWIDTH-1:0] rReg, rRegNext, f_rout, f_rin;
    logic [XWIDTH-1:0] xReg, xRegNext, f_xout, f_xin;
    logic [(BWIDTH*NUMBLOCKS)-1:0] blocksReg; //holds input data 
    logic [$clog2(B-1):0] i;
    
    logic [1:0] domainReg;
    logic finalizeReg;
    logic [ROUND_COUNT-1:0] roundsReg;
    
    
    assign count_valid = ((i+1) < B-1) ? 1:0;
  
    //Counter Register block
    always_ff @(posedge clk) begin
        if (reset) i <= 0;
        else if (increment) i <= i + 1;
        else i <= i;
    end
    
    //cRegister block
    always_ff @(posedge clk) begin
        if (reset) cReg <= 0;
        else cReg <= cRegNext;
    end
    
    //R register block
    always_ff @(posedge clk) begin
        if (reset) rReg <= 0;
        else rReg <= rRegNext;
    end
    
    //xRegister Block
    always_ff @(posedge clk) begin
        if (reset) xReg <= 0;
        else xReg <= xRegNext;
    end
    
    //Current State Register Block
    always_ff @(posedge clk) begin
        if (reset) curr_state <= RESET;
        else curr_state <= next_state;
    end
    
    assign read_input = (curr_state == READ_IN) ? 1:0;
    //Input Blocks Register
    always_ff @ (posedge clk) begin
        if (reset) blocksReg <=0;
        else if (read_input) blocksReg <= blocks;
        else blocksReg <= blocksReg;
    end
    
    //Input Registers for domain, finalize, and rounds inputs
    always_ff @ (posedge clk) begin
        if (reset) begin
            domainReg <= 0;
            finalizeReg <= 0;
            roundsReg <= 0;
        end
        
        else if (read_input) begin
            domainReg <= domain;
            finalizeReg <= finalize;
            roundsReg <= rounds;
        end
        
        else begin 
            domainReg <= domainReg;
            finalizeReg <= finalizeReg;
            roundsReg <= roundsReg;
        end
    
    end
    
    always_comb begin
        //default values for signals to avoid latching
        f_ds = 0;
        increment = 1'b0;
        done = 1'b0;
        cRegNext = cReg;
        rRegNext = rReg;
        xRegNext = xReg;
        cout = 0;
        xout = 0;
        rout = 0;
        f_cin = cReg;
        f_xin = xReg;
        f_rin = rReg;
        f_dataIn = blocksReg[(i*IWIDTH) +: IWIDTH];
        f_reset = 0;
        f_en = 0;
        next_state = curr_state;
        
        case (curr_state)
            RESET: begin
                increment = 1'b0;
                done = 1'b0;
                if (en) next_state = READ_IN;
                else next_state = RESET;
            end
            
            READ_IN: begin
                cRegNext = c;   //read all inputs from wires at this point
                rRegNext = r;
                xRegNext = x;
                //blocks register automatically inputs the block stream from wires to itself in this state
                //input registers for rounds, finalize, and domain also do this automatically
                next_state = RESTART;
            end

            RESTART: begin //we reset F in this state
                f_reset = 1'b1; //reset F here so that it has fresh registers
                f_en = 1'b0; //dont enable it yet
                if (B > 1) next_state = START; //this checks if there is more than 1 input block, if there is, jump to START to do for loop
                else next_state = DONEFOR;  //otherwise skip the for loop
//                increment = 1'b0;
            end
            
            START: begin //here F is enabled and the for loop iterates  
                f_ds = 0;
                f_dataIn = blocksReg[(i*IWIDTH) +: IWIDTH];
                f_en = 1'b1; //enable after asserting the input
                increment = 1'b0; //dont up the counter
                next_state = WAITF;
            end
            
            WAITF: begin
                f_en = 1'b1; //keep F enabled
                if (fdone) begin
                    increment = 1'b0;
                    cRegNext = f_cout; //write outputs of F into local registers
                    xRegNext = f_xout;
                    rRegNext = f_rout;
                    
                    if (count_valid) begin //do we still need to increment?
                        increment = 1'b1; //if yes, raise the increment flag high
                        next_state = RESTART; //go to RESTART block so that F can be reset and restarted
                    end
                    else next_state = DONEFOR;  //else we are done iterating through the for loop
                end
                else begin //if f is not done
                    f_reset = 1'b0;
                    next_state = WAITF; //wait here and rerun
                end
            end
            
            DONEFOR: begin //here we need to run F one more time since the for loop is done
                f_en = 1'b0; //dont enable F yet
                increment = 1'b0; //counter shouldnt increment
                
                f_ds = {domainReg,finalizeReg,padded}; //set the domain separator input to this, use registered inputs, not wires
                f_dataIn = lastBlock; //if B==1 this is the first block/only block in the input stream
                f_reset = 1'b1; //reset F here
                next_state = LASTF; 
            end
            
            LASTF: begin //this state waits for F to finish for the last time
                f_reset = 1'b0;
                f_ds = {domainReg,finalizeReg,padded}; //set the domain separator input to this, use registered inputs, not wires
                f_en = 1'b1; //KEEP f enabled so it runs all the way
                increment = 1'b0;
                if (fdone) begin
                    cRegNext = f_cout; //store outputs of F into local registers
                    xRegNext = f_xout;
                    rRegNext = f_rout;
                    next_state = DONE;
                end
                else begin
                    next_state = LASTF;
                end
                
            end
            
            DONE: begin
                f_reset = 1'b0;
                cout = cReg; //output values of registers into wires
                xout = xReg;
                rout = rReg;
                done =  1'b1; //raise done flag
                next_state = DONE; //stay here
            end
            
            default: begin
                next_state = curr_state; //hold current stage     
            end
   
       

        endcase
    
    end
    
    
    
    F #(.XWORDS32(XWIDTH/32), .DS_WIDTH(4), .ROUND_COUNT(ROUND_COUNT),.RWIDTH(RWIDTH)) f (
        .clk(clk),
        .reset(reset | f_reset),
        .en(f_en),
        .c(f_cin),
        .x(f_xin),
        .xout(f_xout),
        .rout(f_rout),
        .cout(f_cout),
        .i(f_dataIn),
        .rounds(roundsReg), 
        .ds(f_ds),
        .done(fdone)
    );
    
    //replaces padding block
    always_comb begin
        lastBlock = blocksReg[(B-1)*IWIDTH +: IWIDTH];
        padded = 1'b0;
    end
//    padding2  #(.IWIDTH(IWIDTH), .BWIDTH(BWIDTH)) pad (
//        .blockIn(blocks[(B-1)*BWIDTH +: BWIDTH]),
//        .blockOut(lastBlock),
//        .padded(padded)
//    );
endmodule
