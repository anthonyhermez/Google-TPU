module FMA_8bit(
input wire [7:0] a,
input wire signed [7:0] b, c,
input wire signed_num,
output wire signed [7:0] result
);

// sign-extend summand if signed_num==TRUE
wire [3:0] b_truncated, c_truncated;
assign b_truncated = b[3:0];
assign c_truncated = c[3:0];
// sign-extend summand if signed_num==TRUE
wire signed [8:0] summand = (signed_num & a[7]) ? ({1'b1,a}) : ({1'b0,a});
wire signed [8:0] signed_product = b_truncated * c_truncated;
wire signed [9:0] sum = summand + signed_product;

// NOTE: overflow handling was removed for simplicity reasons
// wire unsigned_overflow = (sum[15:8] != 8'h00);
// wire signed_overflow = (sum[7]) ? (sum[15:8] != 8'hFF) : (unsigned_overflow);
// assign overflow = (signed_num) ? (signed_overflow) : (unsigned_overflow);

assign result = sum[7:0]; // ignores overflow/underflow

endmodule
