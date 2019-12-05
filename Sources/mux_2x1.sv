module mux_2x1 #(parameter N = 8) (

    input logic [N-1:0] a,
    input logic [N-1:0] b,
    input logic sel,
    output logic [N-1:0] y
);
    logic [N-1:0] p0, p1;
    
    always_comb
    begin
        p0 = a & ~{N{sel}};         
        p1 = b & {N{sel}};        
        y = p0 | p1;   
    end
    
    
    
    
endmodule