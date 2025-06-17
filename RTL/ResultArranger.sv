module ResultArranger #(parameter N = 4) (

input wire clk,
input wire reset_n,
input wire start_arranging,
input wire [N-1:0][7:0] in_data,

output wire [8*N*N-1 : 0] out_data
);

reg [8*N*N-1 : 0] result;
reg [ $clog2(2*N) : 0 ] count;
wire [8*N*N-1 : 0] merged;

assign out_data = result;

always @(posedge clk) begin
    if(!reset_n) begin
        result <= 0;
        count <= 0;
    end else begin
        if(start_arranging) begin
            if(count < (2*N)) begin
                result <= result | merged;
                count <= count + 1;
            end 
        end else begin
            result <= 0;
            count <= 0;
        end 
    end
end

genvar k;
generate
    
    wire [7:0] dmux_out [N][N];
    wire [7:0] dmux_out_or [N];
    
    for (k = 0; k <= N-1; k=k+1) begin
        wire [$clog2(N)-1:0] select = count - k;
        Demux1toN #(N) DEMUX_N (
            .data_in(in_data[k]),        // Single input data
            .select(select), // -1       // Select signal (log2(N) bits)
            .data_out(dmux_out[N - 1 - k])      // N output lines
        );
        BitwiseOrN #(N) OR_N (
            .in_values(dmux_out[N - 1 - k]),
            .out_result(dmux_out_or[k])
        );
        
        assign merged[ (((N*(k+1)) << 3) - 1):((N*k) << 3) ] = dmux_out_or[k] << ((count - k - 1) << 3);
    end
    
endgenerate 

endmodule
