module BitwiseOrN #(parameter N = 4) (
    input logic [7:0] in_values [N],
    output logic [7:0] out_result
);
    integer i;
    always_comb begin
        out_result = 8'b0;
        for (i = 0; i < N; i = i + 1) begin
            out_result = out_result | in_values[i];
        end
    end
endmodule

