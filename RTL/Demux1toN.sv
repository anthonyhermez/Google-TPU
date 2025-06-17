module Demux1toN #(
    parameter N = 8  // Number of output lines
)(
    input  logic [7:0] data_in,                 // 8-bit input data
    input  logic [$clog2(N)-1:0] select,       // Select signal (log2(N) bits)
    output logic [7:0] data_out [N]            // N 8-bit output lines
);
    integer i;
    always_comb begin
        for (i = 0; i < N; i = i + 1) begin
            data_out[i] = 8'b0; // Default all outputs to 0
        end
        data_out[select] = data_in; // Route input to the selected output
    end
endmodule
