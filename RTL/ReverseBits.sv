module ReverseBits #(parameter N = 8) (
    input  wire [N-1:0] in,
    output wire [N-1:0] out
);    
    generate
        genvar j;
        for (j = 0; j < N; j = j + 1) begin : reverse_loop
            assign out[j] = in[N-1-j];
        end
    endgenerate
    
endmodule
