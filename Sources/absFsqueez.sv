`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2020 04:29:55 PM
// Design Name: 
// Module Name: absFsqueez
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


module absFsqueez#(parameter CWIDTH = 320, parameter RWIDTH = 192, parameter XWIDTH = 128,
                parameter BWIDTH = 32, parameter NUMBLOCKS = 4, parameter REMAINWIDTH = 20, parameter ROUND_COUNT = 4) 
    (
        input logic [CWIDTH-1:0] c,
        input logic [RWIDTH-1:0] r,
        input logic [XWIDTH-1:0] x,
        input logic [(BWIDTH*NUMBLOCKS)-1:0] blocks,
        input logic finalize, clk, reset, en,
        input logic [1:0] domain,
        input logic [ROUND_COUNT-1:0] rounds,
        input logic [REMAINWIDTH-1:0] remaining,
        input logic AoF,
        input logic Squeez,
        output logic [CWIDTH-1:0] cout,
        output logic [RWIDTH-1:0] rout,
        output logic [XWIDTH-1:0] xout,
        output logic done
    );
    
    localparam IWIDTH = 128;
    localparam B = (BWIDTH*NUMBLOCKS)/IWIDTH;
    
    typedef enum {RESET, READ_IN, START, WAITF, RESTART, DONEFOR, LASTF, DONE, SSTART, REMAINCHECK, REMAIN2WIDTH, BCONCATINATE, REMAININGZERO, GWAIT} state_type;
    state_type curr_state, next_state;
    //AbsF
    logic fogdone, count_valid, increment, fog_reset, fog_en, padded, FoG;
    logic read_input;
    logic [3:0] f_ds;
    logic [IWIDTH-1:0] fog_dataIn, lastBlock;
    logic [CWIDTH-1:0] cReg, cRegNext, fog_cout, fog_cin;
    logic [RWIDTH-1:0] rReg, rRegNext, fog_rout, fog_rin;
    logic [XWIDTH-1:0] xReg, xRegNext, fog_xout, fog_xin;
    logic [(BWIDTH*NUMBLOCKS)-1:0] blocksReg; //holds input data 
    logic [$clog2(B-1):0] i;
    
    logic [1:0] domainReg;
    logic finalizeReg;
    logic [ROUND_COUNT-1:0] roundsReg;
    //squeez
    logic [REMAINWIDTH-1:0] remainReg,remainRegNext;
    logic [RWIDTH-1:0] len,lenNext;
    logic [CWIDTH-1:0] bReg,bRegNext;
    
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
        if (reset) 
            curr_state <= RESET;
        else curr_state <= next_state;
    end
    
    //len Block Register
    always_ff @(posedge clk)
        if (reset) len <= 0;
        else len <= lenNext;
        
    //remainReg Block Register
    always_ff @(posedge clk)
        if (reset) remainReg <= 0;
        else remainReg <= remainRegNext;
    
    //bReg Block Register
    always_ff @ (posedge clk)
        if (reset) bReg <= 0;
        else bReg <= bRegNext;
    
    assign read_input = (curr_state == READ_IN | curr_state == SSTART) ? 1:0;
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
        fog_cin = cReg;
        fog_xin = xReg;
        fog_rin = rReg;
        fog_dataIn = blocksReg[(i*IWIDTH) +: IWIDTH];
        fog_reset = 0;
        fog_en = 0;
        next_state = curr_state;
        
        case (curr_state)
            RESET: begin
                increment = 1'b0;
                done = 1'b0;
                if (en) begin
                    if (Squeez)
                        next_state = SSTART;
                    else
                        next_state = READ_IN;
                end
                else next_state = RESET;
            end
            
            READ_IN: begin
                cRegNext = c;   //read all inputs from wires at this point
                rRegNext = r;
                xRegNext = x;
                FoG = 1'b0; //F
                //blocks register automatically inputs the block stream from wires to itself in this state
                //input registers for rounds, finalize, and domain also do this automatically
                next_state = RESTART;
            end

            RESTART: begin //we reset F in this state
                fog_reset = 1'b1; //reset F here so that it has fresh registers
                fog_en = 1'b0; //dont enable it yet
                if (B > 1) next_state = START; //this checks if there is more than 1 input block, if there is, jump to START to do for loop
                else next_state = DONEFOR;  //otherwise skip the for loop
//                increment = 1'b0;
            end
            
            START: begin //here F is enabled and the for loop iterates  
                f_ds = 0;
                fog_dataIn = blocksReg[(i*IWIDTH) +: IWIDTH];
                fog_en = 1'b1; //enable after asserting the input
                increment = 1'b0; //dont up the counter
                next_state = WAITF;
            end
            
            WAITF: begin
                fog_en = 1'b1; //keep F enabled
                if (fogdone) begin
                    increment = 1'b0;
                    cRegNext = fog_cout; //write outputs of F into local registers
                    xRegNext = fog_xout;
                    rRegNext = fog_rout;
                    if (AoF == 1'b1) begin
                        next_state = DONE;
                    end
                    else if (count_valid) begin //do we still need to increment?
                        increment = 1'b1; //if yes, raise the increment flag high
                        next_state = RESTART; //go to RESTART block so that F can be reset and restarted
                    end
                    else next_state = DONEFOR;  //else we are done iterating through the for loop
                end
                else begin //if f is not done
                    fog_reset = 1'b0;
                    next_state = WAITF; //wait here and rerun
                end
            end
            
            DONEFOR: begin //here we need to run F one more time since the for loop is done
                fog_en = 1'b0; //dont enable F yet
                increment = 1'b0; //counter shouldnt increment
                
                f_ds = {domainReg,finalizeReg,padded}; //set the domain separator input to this, use registered inputs, not wires
                fog_dataIn = lastBlock; //if B==1 this is the first block/only block in the input stream
                fog_reset = 1'b1; //reset F here
                next_state = LASTF; 
            end
            
            LASTF: begin //this state waits for F to finish for the last time
                fog_reset = 1'b0;
                f_ds = {domainReg,finalizeReg,padded}; //set the domain separator input to this, use registered inputs, not wires
                fog_en = 1'b1; //KEEP f enabled so it runs all the way
                increment = 1'b0;
                if (fogdone) begin
                    cRegNext = fog_cout; //store outputs of F into local registers
                    xRegNext = fog_xout;
                    rRegNext = fog_rout;
                    next_state = DONE;
                end
                else begin
                    next_state = LASTF;
                end
                
            end
        //Squeez States            
            SSTART: begin
                if (!finalize && !reset) begin
                    bRegNext = r[0];
                    next_state = DONE;
                end
                else begin
                    FoG = 1'b1; //G
                    lenNext = RWIDTH; //1
                    remainRegNext=remaining;
                    next_state = REMAINCHECK;
                    bRegNext = 0;
                    rRegNext = r;    //take in initial r value 
                    cRegNext = c; //take in C;
                    fog_reset = 1'b1;
                    fog_en = 1'b0;
                end
            end
            
            REMAINCHECK: 
            begin
//                            Ggo = 1'b0
                lenNext = len;
                if(remainReg > 0)//2
                begin
                    next_state = REMAIN2WIDTH;
                end
                else
                    next_state = DONE;
            end
            
            REMAIN2WIDTH: begin
                lenNext = len;
                if (remainReg < RWIDTH)//3
                    begin
                        lenNext = remainReg;//4
                    end
                    next_state = BCONCATINATE; 
            end
            
            BCONCATINATE: begin
                bRegNext = bReg | (rReg << (CWIDTH-remainReg));
                remainRegNext = remainReg-len; 
                next_state = REMAININGZERO;
                fog_reset = 1'b1;
                fog_en = 1'b0;
            end
            
            REMAININGZERO: begin
                if (remainReg > 0)//9
                begin
                    fog_reset = 1'b1;
                    fog_en = 1'b0;
                    fog_cin = cReg;
                    next_state = GWAIT;
                end
                else
                begin
                    next_state = REMAINCHECK;
                end
            end
            
            GWAIT: begin
                fog_reset = 1'b0;
                fog_en = 1'b1;
                if (fogdone) begin //10 
                    next_state = REMAINCHECK;
                    cRegNext = fog_cout;
                    rRegNext = fog_rout;
                end
                else next_state = GWAIT;  
            end
            
            DONE: begin
                fog_reset = 1'b0;
                if (Squeez) begin
                    cout = bReg;
                    rout = 0;
                end
                else begin 
                    cout = cReg; //output values of registers into wires
                    rout = rReg;
                end
                xout = xReg;
                
                done =  1'b1; //raise done flag
                next_state = DONE; //stay here
            end
            
            default: begin
                next_state = curr_state; //hold current stage     
            end
   
        endcase
    
    end
    
    
    
    FoG #(.XWORDS32(XWIDTH/32), .DS_WIDTH(4), .ROUND_COUNT(ROUND_COUNT),.RWIDTH(RWIDTH)) fog (
        .clk(clk),
        .reset(reset | fog_reset),
        .en(fog_en),
        .c(fog_cin),
        .x(fog_xin),
        .FoG(FoG),
        .xout(fog_xout),
        .rout(fog_rout),
        .cout(fog_cout),
        .i(fog_dataIn),
        .rounds(roundsReg), 
        .ds(f_ds),
        .done(fogdone)
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

