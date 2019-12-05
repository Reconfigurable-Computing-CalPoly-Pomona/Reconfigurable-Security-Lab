
module mixsx32 #(parameter CWORDS64 = 2, parameter XWORDS32 = 2) (
    input logic clk,
    input logic reset,
    input logic [CWORDS64*64-1:0] c, //secret data
    input logic [XWORDS32*32-1:0] x, //secret data constrained,
    input logic [CWORDS64*$clog2(XWORDS32)-1:0] d, //input data,
    output logic [CWORDS64*64-1:0] cout,
    output logic data_rdy //secret data output,
);
    typedef enum {RESET, START, NORMAL} stateType;
    stateType curr_state, next_state;
   
    localparam SEL2_WIDTH = 32;
    localparam CWIDTH = CWORDS64*64;
    localparam XWIDTH = XWORDS32*32;
    localparam IDX_WIDTH = $clog2(XWORDS32);
    localparam DWIDTH = CWORDS64*IDX_WIDTH;
    
    logic [IDX_WIDTH - 1: 0] idxTemp, idxNext;
    logic [CWORDS64-1:0] [IDX_WIDTH - 1: 0] idxArray;
    logic [CWORDS64-1:0] [SEL2_WIDTH - 1:0] xwArray;
    logic [CWORDS64-1:0] [SEL2_WIDTH - 1:0] xorArray;
    logic [CWORDS64-1:0] [31:0] cArray;
//    logic [CWORDS64*64-1:0] coutArray;//secret data output,
    logic [31:0] xwTemp;
    logic [31:0] cTemp;
    logic [$clog2(CWORDS64):0] i, iNext, i_xw, i_xor;
    
    logic en, xor_en;
    
    assign data_rdy = (i_xor >= CWORDS64) ? 1 : 0;
    
    always_ff @ (posedge clk, posedge reset)
        if (reset) cout <= 0;
        else if (xor_en) cout[(2*i_xor)*32 +: 32] <= xorArray[i_xor];
        else cout <= cout;
    
    //FF for IDX Iterator + Starting States
    always_ff @(posedge clk, posedge reset)
        if (reset) begin
            i <= 0;
            curr_state <= RESET;
//            idxArray <= 0;
        end
        
        else begin
            i <= iNext;
            curr_state <= next_state;
//            idxArray[i] <= idxTemp;     
        end
    
    //Next State Logic: + iterator
    always_comb 
        if (curr_state == RESET && reset) begin
            next_state = RESET;
            iNext = 0;
            idxArray = 0;
        end
        
        else if (curr_state == RESET && ~reset) begin
            next_state = START;
            iNext = 0;
            idxArray = 0;
        end
   
        else if (curr_state == START) begin
            next_state = NORMAL;
            iNext = i + 1;
            idxArray[i] = idxTemp;
        end
        
        else if (curr_state == NORMAL) begin
            next_state = NORMAL;
                if (i < CWORDS64) begin
                    iNext = i + 1;   
                    idxArray[i] = idxTemp;
                end
        end
 /*    
     //combo logic for writing into idxArray
//     always_comb 
////        idxArray = idxArray;
//         if (reset) begin
//            idxArray = 0;
//         end
         
//         else if (curr_state == START) begin
//             idxArray[i] = idxTemp;
//         end
         
//         else if (curr_state == NORMAL) begin
//             idxArray[i] = idxTemp;
//         end
         
//         else idxArray = idxArray; */  
    
    //Logic for Sel2 Counter Enable
    always_comb
        if (reset) en = 1'b0;
        else if ((i > 0) && (i_xw < CWORDS64)) en = 1'b1;
        else if (i_xw >= CWORDS64) en = 1'b0;
        else en = 1'b0;
    
    //Assignmnt for Feeding Output of IDX iteratively to second select
    always_comb
        if(i_xw < CWORDS64) 
        idxNext = idxArray[i_xw];
    
    //Taking Every XW Output from Second Select and Storing in Array
    always_comb
        if (reset) xwArray = 0;
        else if (en) xwArray[i_xw] = xwTemp;
        else xwArray = xwArray;
    
    //For selecting blocks of C on line 4, start in parallel with line 2 and store until xw is ready for xor
    always_comb
        if (reset) cArray = 0;
        else if (curr_state == START || curr_state == NORMAL) 
            if (i < CWORDS64)
                cArray[i] = cTemp;
    
    //Begins XORing xw values with each value stored in cArray from line 4, need a new counter
    always_comb
        if (~reset && i_xw > 0 && i > 0 && i_xor < (CWORDS64)) xor_en = 1'b1; 
        else xor_en = 1'b0;
        
    always_comb
        if (xor_en)
            xorArray[i_xor] = cArray[i_xor] ^ xwArray[i_xor];
        else xorArray = 0;
//            coutArray[(2*i_xor) +: 32] = xorArray[i_xor];
        
    
    select #(.INPUT_WIDTH(DWIDTH), .OUT_WIDTH(IDX_WIDTH)) selectIDX (
        .inputVal(d),
        .index(i),
        .out(idxTemp),
        .reset(reset)
    );
    
    select #(.INPUT_WIDTH(XWIDTH), .OUT_WIDTH(32)) selectXW (
        .inputVal(x),
        .index(idxNext),
        .out(xwTemp),
        .reset(reset)
    );
    
    select #(.INPUT_WIDTH(CWIDTH), .OUT_WIDTH(32)) selectC (
        .inputVal(c),
        .index(2*i),
        .out(cTemp),
        .reset(reset)
    );
    
    mod_m_counter #(.N(CWORDS64)) counter_selXW (
        .clk(clk),
        .reset(reset),
        .count(i_xw),
        .enable(en)
    );
    
    mod_m_counter #(.N(CWORDS64)) counter_XOR (
            .clk(clk),
            .reset(reset),
            .count(i_xor),
            .enable(xor_en)
    );
    

    
//    select_f #(.INPUT_WIDTH(DWIDTH), .OUT_WIDTH(IDX_WIDTH)) select_idx (
//            .inputVal(d),
//            .out(idxArray),
//            .clk,
//            .reset
//    );
    
//    always_comb
//        if (reset) cout = 0;
//        else cout = 0;
    
    


endmodule