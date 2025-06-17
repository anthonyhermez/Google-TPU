`include "tpu_sequences.sv"

module tb_tpu;

reg clk;
reg reset_n;
reg s_update;
reg s_in;
wire s_out;

tpu #( .N(N),
       .K(K) ) TPU (
       .s_clk(clk),
       .s_rst_n(reset_n),
       .s_update(s_update),
       .s_in(s_in),
       .s_out(s_out)
);

task assert_reg_file(tpu_sequence test);
    for(int i = 0; i < K; i++) begin
        assert(TPU.REG_FILE.reg_file[i] == test.golden_reg_file[i])
        else begin
            $error(1, "REG_FILE MISMATCH.");
            $display("reg_file[%d] Expected: %h, Actual: %h.", i,
             test.golden_reg_file[i], TPU.REG_FILE.reg_file[i]);
        end
    end
endtask

initial begin

automatic tpu_basic basic_test = new();
// automatic tpu_random random_test = new();

clk = 0;
basic_test.run();
assert_reg_file(basic_test);

// repeat(10) begin
//     random_test.run(); // approximately 53,190 cycles to run
//     assert_reg_file(random_test);
//     random_test.randomize();
// end
$finish;

end

always begin
    reset_n <= fpga.s_rst_n;
    s_update <= fpga.s_update;
    s_in <= fpga.s_in;
    #5 clk <= ~clk;
end

//always_comb begin
//    reset_n = fpga.s_rst_n;
//    s_update = fpga.s_update;
//    s_in = fpga.s_in;
//end

endmodule
