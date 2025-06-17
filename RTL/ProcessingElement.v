module ProcessingElement(
input wire clk,
input wire reset_n,
input wire signed_num,
input wire weight_ctr, systolic_ctr, FMA_ctr,
input wire [7:0] FMA_input, systolic_input, weight_input,
output wire [7:0] systolic_fwd, weight_fwd,
output wire [7:0] FMA_result
);

reg [7:0] weight;
reg [7:0] systolic;
reg [7:0] add;

assign systolic_fwd = systolic;
assign weight_fwd = weight;

FMA_8bit FMA(.a(add),
             .b(systolic),
             .c(weight),
             .signed_num(signed_num),
             .result(FMA_result));

always @(posedge clk) begin
    if(!reset_n) begin
        weight <= 8'b0;
        systolic <= 8'b0;
        add <= 8'b0;
    end else begin
        if(weight_ctr)
            weight <= weight_input;
        if(systolic_ctr)
            systolic <= systolic_input;
        if(FMA_ctr)
            add <= FMA_input;
    end
end

endmodule
