`timescale 1ns / 1ps

module padding #(parameter IWIDTH = 64, parameter BWIDTH = 32) (
        input logic [BWIDTH-1:0] blockIn,
        output logic [IWIDTH-1:0] blockOut,
        output logic padded
    );

    always_comb begin
        blockOut = blockIn;
//        padded = 1'b0;
        blockOut[IWIDTH-1] = 1'b1;
        padded = 1'b1;
//        if ($high(block) < IWIDTH) begin
//            padded = 1'b1;
//            blockOut = {{IWIDTH-2{1'b0}},block};
//            blockOut[IWIDTH-1] = 1'b1;
            
        
    end



endmodule