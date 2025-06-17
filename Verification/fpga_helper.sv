`ifndef FPGA_HELPER_SV
`define FPGA_HELPER_SV

`include "matrix_helper.sv"

class FPGA;
    reg s_rst_n = 1;           // Scan chain reset, low active, can reuse the AES RSTn signal
    reg s_update = 0;          // Update signal
    reg s_in = 0;              // Serial chain input
    // reg s_out = 0;             // Scan chain output
    
    task reset_tpu();
        s_rst_n = 0;
        //delay(.clock_cycles(2));
        #12;
        s_rst_n = 1;
    endtask
    
    task send_data(int data, int size);
        reg [(size_of_inst + size_of_data - 1):0] shift_out = data << ((size_of_inst + size_of_data) - size);
        repeat (size) begin
            s_in <= shift_out[(size_of_inst + size_of_data - 1)];
            delay(.clock_cycles(1));
            shift_out = {shift_out[(size_of_inst + size_of_data - 2):0], 1'b0};
        end
        s_update = 1;
    endtask
    
    task send_instruction(opcode_t OPCODE, int reg_num, Matrix mat);
        logic [(size_of_inst + size_of_data - 1):0] instruction;
        instruction = {{OPCODE,reg_num[$clog2(K)-1:0]},arrange_vector(mat)};
        instruction = reversed(instruction);
        case(OPCODE)
        RHW_op: begin // Passing
            // Serially right shift instruction to the Scan Chain
            repeat (size_of_inst + size_of_data) begin
                s_in <= instruction[(size_of_inst + size_of_data - 1)]; // this is the reason we add +1 to the delay
                delay(.clock_cycles(1));
                instruction = {instruction[(size_of_inst + size_of_data - 2):0], 1'b0};
            end
            assert(instruction == '0); // we should shift out all the bits
            s_update = 1;
            // delay the time it takes to execute the instruction in the TPU before beginning the next instruction
            delay(.clock_cycles(2 + 1)); 
            s_update = 0;
        end
        LW_op: begin // Passing
            // Serially right shift instruction to the Scan Chain
            repeat (size_of_inst + size_of_data) begin
                s_in <= instruction[(size_of_inst + size_of_data - 1)]; // this is the reason we add +1 to the delay
                delay(.clock_cycles(1));
                instruction = {instruction[(size_of_inst + size_of_data - 2):0], 1'b0};
            end
            assert(instruction == '0);
            s_update = 1;
            // delay the time it takes to execute the instruction in the TPU before beginning the next instruction
            delay(.clock_cycles(2 + (N + 1) + 1)); 
            s_update = 0;
        end
        LS_op: begin // Passing
            // Serially right shift instruction to the Scan Chain
            repeat (size_of_inst + size_of_data) begin
                s_in <= instruction[(size_of_inst + size_of_data - 1)]; // this is the reason we add +1 to the delay
                delay(.clock_cycles(1));
                instruction = {instruction[(size_of_inst + size_of_data - 2):0], 1'b0};
            end
            assert(instruction == '0);
            s_update = 1;
            // delay the time it takes to execute the instruction in the TPU before beginning the next instruction
            delay(.clock_cycles(2 + 1)); 
            s_update = 0; 
        end
        MM_op: begin // Passing
            // Serially right shift instruction to the Scan Chain
            repeat (size_of_inst + size_of_data) begin
                s_in <= instruction[(size_of_inst + size_of_data - 1)]; // this is the reason we add +1 to the delay
                delay(.clock_cycles(1));
                instruction = {instruction[(size_of_inst + size_of_data - 2):0], 1'b0};
            end
            assert(instruction == '0);
            s_update = 1;
            // delay the time it takes to execute the instruction in the TPU before beginning the next instruction
            delay(.clock_cycles(2 + (N-1) + ((2*N) - 1) + 2 + 1)); 
            s_update = 0;
            
        end
        WHM_op: begin // In Progress
        
            // Serially right shift instruction to the Scan Chain
            repeat (size_of_inst + size_of_data) begin
                s_in <= instruction[(size_of_inst + size_of_data - 1)]; // this is the reason we add +1 to the delay
                delay(.clock_cycles(1));
                instruction = {instruction[(size_of_inst + size_of_data - 2):0], 1'b0};
            end
            assert(instruction == '0);
            s_update = 1;
            // delay the time it takes to execute the instruction in the TPU before beginning the next instruction
            delay(.clock_cycles(3 + 1)); 
            s_update = 0;
            
        end
        default: begin
            $error("Invalid opcode");
        end
        endcase
    endtask
    
    task send_instruction_binary([(size_of_inst + size_of_data - 1):0] instruction);
        // logic [(size_of_inst + size_of_data - 1):0] instruction;
        // instruction = {{OPCODE,reg_num[$clog2(K)-1:0]},arrange_vector(mat)};
        opcode_t OPCODE = instruction[(size_of_inst + size_of_data - 1):(size_of_inst + size_of_data - 3)];
        instruction = reversed(instruction);
        case(OPCODE)
        RHW_op: begin // Passing
            // Serially right shift instruction to the Scan Chain
            repeat (size_of_inst + size_of_data) begin
                s_in <= instruction[(size_of_inst + size_of_data - 1)]; // this is the reason we add +1 to the delay
                delay(.clock_cycles(1));
                instruction = {instruction[(size_of_inst + size_of_data - 2):0], 1'b0};
            end
            assert(instruction == '0); // we should shift out all the bits
            s_update = 1;
            // delay the time it takes to execute the instruction in the TPU before beginning the next instruction
            delay(.clock_cycles(2 + 1)); 
            s_update = 0;
        end
        LW_op: begin // Passing
            // Serially right shift instruction to the Scan Chain
            repeat (size_of_inst + size_of_data) begin
                s_in <= instruction[(size_of_inst + size_of_data - 1)]; // this is the reason we add +1 to the delay
                delay(.clock_cycles(1));
                instruction = {instruction[(size_of_inst + size_of_data - 2):0], 1'b0};
            end
            assert(instruction == '0);
            s_update = 1;
            // delay the time it takes to execute the instruction in the TPU before beginning the next instruction
            delay(.clock_cycles(2 + (N + 1) + 1)); 
            s_update = 0;
        end
        LS_op: begin // Passing
            // Serially right shift instruction to the Scan Chain
            repeat (size_of_inst + size_of_data) begin
                s_in <= instruction[(size_of_inst + size_of_data - 1)]; // this is the reason we add +1 to the delay
                delay(.clock_cycles(1));
                instruction = {instruction[(size_of_inst + size_of_data - 2):0], 1'b0};
            end
            assert(instruction == '0);
            s_update = 1;
            // delay the time it takes to execute the instruction in the TPU before beginning the next instruction
            delay(.clock_cycles(2 + 1)); 
            s_update = 0; 
        end
        MM_op: begin // Passing
            // Serially right shift instruction to the Scan Chain
            repeat (size_of_inst + size_of_data) begin
                s_in <= instruction[(size_of_inst + size_of_data - 1)]; // this is the reason we add +1 to the delay
                delay(.clock_cycles(1));
                instruction = {instruction[(size_of_inst + size_of_data - 2):0], 1'b0};
            end
            assert(instruction == '0);
            s_update = 1;
            // delay the time it takes to execute the instruction in the TPU before beginning the next instruction
            delay(.clock_cycles(2 + (N-1) + ((2*N) - 1) + 2 + 1)); 
            s_update = 0;
            
        end
        WHM_op: begin // In Progress
        
            // Serially right shift instruction to the Scan Chain
            repeat (size_of_inst + size_of_data) begin
                s_in <= instruction[(size_of_inst + size_of_data - 1)]; // this is the reason we add +1 to the delay
                delay(.clock_cycles(1));
                instruction = {instruction[(size_of_inst + size_of_data - 2):0], 1'b0};
            end
            assert(instruction == '0);
            s_update = 1;
            // delay the time it takes to execute the instruction in the TPU before beginning the next instruction
            delay(.clock_cycles(3 + 1)); 
            s_update = 0;
            
        end
        default: begin
            $error("Invalid opcode");
        end
        endcase
    endtask
endclass

task delay(int clock_cycles);    
    repeat (clock_cycles) begin
        #10;
    end
endtask

`endif