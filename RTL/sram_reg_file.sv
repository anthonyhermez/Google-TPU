module sram_reg_file #(
    parameter N = 4,   // Bit width of each register
    parameter K = 8      // Number of registers
)(
    input  logic clk,             // Clock signal
    input  logic write_enable,    // Write enable signal
    input  logic [$clog2(K)-1:0] write_address, // Address for writing
    input  logic [(8*N*N)-1:0] write_data, // Data to be written
    input  logic [$clog2(K)-1:0] read_address, // Read port 1 address
    input  logic reg_in,
    output logic [(8*N*N)-1:0] read_data // Data from read port 1
);
    
    // Register array (SRAM storage)
    logic [(8*N*N)-1:0] reg_file [K];
    
    // Synchronous write operation
    always_ff @(posedge clk) begin
        if (write_enable & reg_in)
            reg_file[write_address] <= write_data;
    end
    
    // Asynchronous read operations
    assign read_data = reg_file[read_address];
        
endmodule
