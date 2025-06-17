module tpu #(parameter N = 4, parameter K = 8) (
    // I/O interface
    input logic s_clk,             // Clock signal
    input logic s_rst_n,           // Scan chain reset, low active, can reuse the AES RSTn signal
    input logic s_update,          // Update signal
    input logic s_in,              // Serial chain input
    output logic s_out             // Scan chain output
);

// Wires
wire [8*N*N-1 : 0] sc_data;
wire [2 + $clog2(K) : 0] sc_instruction;
wire [N-1:0][7:0] matrix_result;
wire [N-1:0][7:0] systolic_out;
wire [N-1:0][7:0] weight_out;
wire [$clog2(K)-1 : 0] instr_reg;
wire [8*N*N-1 : 0] arranged_result;
wire [8*N*N-1 : 0] read_data;
wire [11:0] control_signals;

// Control signals (12 total)
wire weight_ctr, systolic_ctr, FMA_ctr;
wire write_en; 
wire start_arranging;
// To bus
wire result_en, data_in, reg_out;
// From bus
wire weight_en, systolic_en, data_out, reg_in;

// Bus instatntiation
tri [8*N*N-1 : 0] bus;

// Drives the bus/tristate buffers
assign bus = (result_en) ? (arranged_result) : {(8*N*N){1'bz}};
assign bus = (data_in) ? (sc_data) : {(8*N*N){1'bz}};
assign bus = (reg_out) ? (read_data) : {(8*N*N){1'bz}};

//assign bus = result_en ? arranged_result :
//             data_in   ? sc_data        :
//             reg_out   ? read_data      :
//             {(8*N*N){1'bz}};

// Connect control signals to Control Block
// See microcode Excel spreadsheet for mapping specifications.
assign start_arranging =    control_signals[0];
assign result_en =          control_signals[1];
assign FMA_ctr =            control_signals[2];
assign systolic_ctr =       control_signals[3];
assign systolic_en =        control_signals[4];
assign weight_ctr =         control_signals[5];
assign weight_en =          control_signals[6];
assign write_en =           control_signals[7];
assign reg_in =             control_signals[8];
assign reg_out =            control_signals[9];
assign data_in =            control_signals[10];
assign data_out =           control_signals[11];

// Module Instantiations
scan_chain #( .N(N),
              .K(K) ) scan_chain (
              // I/O interface
              .s_clk(s_clk),             // Clock signal
              .s_rst_n(s_rst_n),           // Scan chain reset, low active, can reuse the AES RSTn signal
              .s_update(s_update),          // Update signal
              .s_in(s_in),              // Serial chain input
              .s_out(s_out),            // Scan chain output
              // Interface to TPU
              .data(sc_data), // Scan Chain to BUS
              .result(bus), // BUS to Scan Chain
              .instruction(sc_instruction), // Scan Chain to BUS
              .data_out(data_out)
);

sram_reg_file #( .N(N),   
                 .K(K) ) REG_FILE (
                 .clk(s_clk),             
                 .write_enable(write_en),    
                 .write_address(instr_reg),
                 .write_data(bus),  // from bus
                 .read_address(instr_reg), 
                 .reg_in(reg_in),
                 .read_data(read_data)  // drives bus
                 
);

SystolicArranger #( .N(N) ) SystolicBuffer (
                    .clk(s_clk),
                    .reset_n(s_rst_n),
                    .systolic_ctr(systolic_ctr),
                    .systolic_en(systolic_en),
                    .systolic_in(bus), // from bus
                    .systolic_out(systolic_out)
);
                    
WeightArranger #( .N(N) ) WeightBuffer (
                  .clk(s_clk),
                  .reset_n(s_rst_n),
                  .weight_ctr(weight_ctr),
                  .weight_en(weight_en),
                  .weight_in(bus), // from bus
                  .weight_out(weight_out)
);
                  
MatrixArray #( .N(N) ) MMU (
               .clk(s_clk),
               .reset_n(s_rst_n),
               .weight_ctr(weight_ctr),
               .systolic_ctr(systolic_ctr),
               .FMA_ctr(FMA_ctr), 
               .systolic_input(systolic_out),
               .weight_input(weight_out),
               .result(matrix_result)
);

ResultArranger #( .N(N) ) ResultBuffer (
                  .clk(s_clk),
                  .reset_n(s_rst_n),
                  .start_arranging(start_arranging),
                  .in_data(matrix_result),
                  .out_data(arranged_result) // drives bus
);

control #( .N(N), 
           .K(K)) Control (
           .clk(s_clk),
           .rst_n(s_rst_n),
           .s_update(s_update),
           .instruction(sc_instruction),
           .control_signals(control_signals),
           .instr_reg(instr_reg)  
);

endmodule
