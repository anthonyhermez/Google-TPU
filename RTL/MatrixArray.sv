module MatrixArray #(parameter N = 4) (

input wire clk,
input wire reset_n,
input wire weight_ctr, systolic_ctr, FMA_ctr,
input wire [N-1:0][7:0] systolic_input,
input wire [N-1:0][7:0] weight_input,
output wire [N-1:0][7:0] result

);

genvar i, j;
generate
    
    wire [N-1:0][N-1:0][7:0] systolic_in;
    wire [N-1:0][N-1:0][7:0] systolic_out;
    wire [N-1:0][N-1:0][7:0] weight_in;
    wire [N-1:0][N-1:0][7:0] weight_out;
    wire [N-1:0][N-1:0][7:0] FMA_in;
    wire [N-1:0][N-1:0][7:0] FMA_out;
    
    for (i = 0; i <= N-1; i=i+1) begin
        for (j = 0; j <= N-1; j=j+1) begin
            ProcessingElement PE (
                .clk(clk),
                .reset_n(reset_n),
                .signed_num(1'b0), // If time permits, I will go back and add signed instructions in the ISA
                .weight_ctr(weight_ctr),
                .systolic_ctr(systolic_ctr),
                .FMA_ctr(FMA_ctr),
                .FMA_input(FMA_in[i][j]),
                .systolic_input(systolic_in[i][j]),
                .weight_input(weight_in[i][j]),
                .systolic_fwd(systolic_out[i][j]),
                .weight_fwd(weight_out[i][j]),
                .FMA_result(FMA_out[i][j])
            );
            assign FMA_in[i][j] = ((i == 0) ? (8'h00) : (FMA_out[i-1][j]));
            assign systolic_in[i][j] = ((j == 0) ? (systolic_input[i]) : (systolic_out[i][j-1]));
            assign weight_in[i][j] = ((i == 0) ? (weight_input[j]) : (weight_out[i-1][j]));
            
            assign result[j] = FMA_out[N-1][j];
            
        end
    end
endgenerate

endmodule
