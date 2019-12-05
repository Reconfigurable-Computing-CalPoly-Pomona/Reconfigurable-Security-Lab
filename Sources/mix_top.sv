`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2019 11:19:02 PM
// Design Name: 
// Module Name: mix_top
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


//module mix_top #(parameter CWORDS64 = 4, parameter XWORDS32 = 2)(
//    input logic clk,
//    input logic reset,
//    input logic [CWORDS64*$clog2(XWORDS32)-1:0] d //input data,
//    );
//    //d = 4'b1000; x = 16; c = 128'h32746732647326473264164736253645;
//    logic [CWORDS64*64-1:0] c =128'h32746732647326473264164736253645; //secret data
//    logic [XWORDS32*32-1:0] x = 16; //secret data constrained,
//    logic [CWORDS64*64-1:0] cout;
    
    
//    mixsx32 #(.CWORDS64(CWORDS64), .XWORDS32(XWORDS32)) mixUUT (.*);
    
    module mix_top #(parameter CWORDS64 = 4, parameter XWORDS32 = 2) (
        input logic clk,
        input logic reset,
        output logic tx,
        input  logic rx 
    );
    
    typedef enum {RESET,BAUD_SETUP, IDLE, SEND_OUT} state_type;
    state_type curr_state, next_state;
    
    localparam NUM_BYTES =  (CWORDS64*8);
    
    logic [CWORDS64*64-1:0] c = 128'h32746732647326473264164736253645;
    logic [XWORDS32*32-1:0] x = 16; //secret data constrained,
    logic [$clog2(XWORDS32)*CWORDS64 - 1:0] d = 4'b1001;
    logic [CWORDS64*64-1:0] cout;
    logic read;
    logic write;
    logic [4:0] addr;
    logic [31:0] wr_data;
    logic [31:0] rd_data;
    logic data_rdy, mix_en;
    logic byte_countEn;
    logic [$clog2(NUM_BYTES):0] count; 
    
    mixsx32 #(.CWORDS64(CWORDS64), .XWORDS32(XWORDS32)) mixUUT (.*, .reset(reset | ~mix_en));
    
    chu_uart uart(
        .clk(clk),
        .reset(reset),
        .cs(1'b1),
        .tx(tx),
        .rx(rx),
        .addr(addr),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .read(read),
        .write(write)
    );
    
    mod_m_counter #(.N(NUM_BYTES)) byteCounter (
        .clk(clk),
        .reset(reset),
        .enable(byte_countEn),
        .count(count)
    );
    
    //FF for State:
    always_ff @(posedge clk, posedge reset)
        if (reset)
            curr_state <= RESET;
        else
            curr_state <= next_state;
            
    //Next State Logic:
    always_comb begin
        case (curr_state)
            RESET: begin 
                next_state = BAUD_SETUP;
                write = 1'b0;
                read = 1'b0;
                mix_en = 1'b0;
                byte_countEn = 1'b0;
            end
            
            BAUD_SETUP: begin
                mix_en = 1'b1; //start mix function
                addr = 2'b01; //writing to dvsr register for baudrate
                wr_data = 651; //for 9600 baudrate
                write = 1'b1;
                next_state = IDLE;     
                byte_countEn = 1'b0;
            end
            
            IDLE: begin //waiting for output to arrive from mix
                write = 1'b0;
                read = 1'b0;
                mix_en = 1'b1;
                if (data_rdy) next_state = SEND_OUT;
                else next_state = IDLE;
                byte_countEn = 1'b0;
            end
            
            SEND_OUT: begin
                //sending output through uart, must send NUM_BYTES, so start a counter here
                //check if can transmit
                mix_en = 1'b1;
                if (count >= NUM_BYTES) begin
                    next_state = SEND_OUT; //sit in this state after done for now
                    byte_countEn = 1'b0;
                    write = 1'b0;
                end
                
                else if (rd_data[9]) begin //if tx is full
                    byte_countEn = 1'b0; //disable byte_counter
                    next_state = SEND_OUT; //wait till next cycle to see if tx is ready
                    write = 1'b0;
                end
                
                else begin//tx is ready and we still need to send output
                    byte_countEn = 1'b1; //enable byte_counter
                    addr = 2'b10; //to write to uart
                    wr_data = cout[(count*8) +: 8];   
                    write = 1'b1;
                end
                
                
            end
        
        endcase
    end
            
    
    
    
endmodule
