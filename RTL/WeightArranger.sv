module WeightArranger #(parameter N = 4) (

input wire clk,
input wire reset_n,
input wire weight_ctr,
input wire weight_en,
input wire [8*N*N-1 : 0] weight_in,
output reg [N-1:0][7:0] weight_out

);

reg [($clog2(N)) : 0] count;
reg [8*N*N-1 : 0] weight;



always @(posedge clk) begin
    if(!reset_n) begin
        count <= 0;
        weight <= 0;
        for (int i = N-1; i >= 0; i=i-1) begin
            weight_out[i] <= 0;
        end
    end else begin
        if(weight_en) begin
            weight <= weight_in;
        end else if(weight_ctr) begin
            if(count < N) begin
                // TODO: reverse order of weights and make it iterate over all N channels
                for(int j = N-1; j >= 0; j--) begin
                    weight_out[j] <= (weight >> ((N * j + (N - 1 - count)) << 3));
                end
                // weight_out <= (weight >> (N * count * 8)) & {(N){1'b1}};
                count <= count + 1;
                
            end else begin
                count <= 0;
                for(int j = N-1; j >= 0; j--) begin
                    weight_out[j] <= 0;
                end
            end
        end else begin
            count <= 0;
            for (int i = N-1; i >= 0; i=i-1) begin
                weight_out[i] <= 0;
            end
        end
    end
end



    
endmodule
