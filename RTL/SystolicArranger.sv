module SystolicArranger #(parameter N = 4) (

input wire clk,
input wire reset_n,
input wire systolic_ctr,
input wire systolic_en,
input wire [8*N*N-1 : 0] systolic_in,
output wire [N-1:0][7:0] systolic_out

);

reg [8*N*N-1 : 0] systolic;
reg [($clog2(2*N-1)) : 0] count;
reg [N-1:0][N-1:0] counter;
reg [N-1:0] counter_mask = 1;

always @(posedge clk) begin
    if(!reset_n) begin
        count <= 0;
        for (int i = N-1; i >= 0; i=i-1) begin
            counter[i] <= 0;
            // systolic_out[i] <= 8'h0;
        end
        systolic <= 0;
    end else begin
        if(systolic_en) begin
            systolic <= systolic_in;
        end else if(systolic_ctr) begin
//            if(count == 0) begin
//                systolic <= systolic_in;
//            end
            if(count < (2*N-1)) begin

                // update the onehot mux select lines
                for (int i = N-1; i >= 1; i=i-1) begin
                    counter[i] = counter[i-1];
                end
                counter[0] <= (count == 0) ? (8'h1) : (counter[0] << 1);
                count <= count + 1;
            end else begin
                count <= 0;
                for (int i = N-1; i >= 0; i=i-1) begin
                    counter[i] <= 0;
                end
            end
        end else begin
            count <= 0;
            // systolic <= 0;
            for (int i = N-1; i >= 0; i=i-1) begin
                counter[i] <= 0;
            end
        end
    end
end

genvar k, j;
generate
    
    wire [N-1:0][N-1:0][7:0] mux_in;
    wire [7:0] mux_out [N][N];
    // wire [7:0] val [N]; 
    
    for (k = 0; k <= N-1; k=k+1) begin
        for (j = 0; j <= N-1; j=j+1) begin
            assign mux_in[k][j] = (count == 0) ? (systolic_in[ ((k*N+j)<<3)+7 : ((k*N+j)<<3) ]) : (systolic[ ((k*N+j)<<3)+7 : ((k*N+j)<<3) ]);
            assign mux_out[k][j] = ((counter[k] >> j) & counter_mask) ? (mux_in[k][j]) : (8'h0);
        end
        
        BitwiseOrN #(N) OR_N (
            .in_values(mux_out[k]),
            .out_result(systolic_out[k])
        );
        
    end
    
endgenerate 

endmodule
