`ifndef TPU_SEQUENCES_SV
`define TPU_SEQUENCES_SV

`include "matrix_helper.sv"
`include "fpga_helper.sv"

FPGA fpga; // global FPGA object for all files to use

class tpu_sequence;
    logic [(8*N*N)-1:0] golden_reg_file[K];
    
    task run();
        $fatal(1, "No sequence to run.");
    endtask
    
    function update_golden_reg_file();
        $fatal(1, "No golden model specified.");
    endfunction
endclass

// In this test:
// A --> Register 1, B --> Register 2, C --> Register 3
// D --> Register 4, E --> Register 5, F --> Register 6
class tpu_basic extends tpu_sequence;
    Matrix A, B, C, D, E, F, Zero;
    task run();
        Zero = new(.data_size(ZEROS));
        Zero.randomize();
        
        A = new(.data_size(COUNT)); // use this to test LW and LS instructions
        A.randomize();
        
        B = new(.data_size(COUNT)); // use this to test LW and LS instructions
        B.randomize();
        
        E = new(.data_size(COUNT)); // use this to test LW and LS instructions
        E.randomize();
        
        $display("\t Matrix A");
        printMatrix_hex(.matrix(A));
        
        $display("\t Matrix B");
        printMatrix_hex(.matrix(B));
        
        C = MatrixMultiply(.A(A), .B(B)); // .A() is weights, .B() is systolic. C=AB (in matrix form)
        $display("\t Matrix C");
        printMatrix_hex(.matrix(C));
        
        D = MatrixMultiply(.A(A), .B(E)); // D=AE (in matrix form)
        $display("\t Matrix D");
        printMatrix_hex(.matrix(D));
        
        $display("\t Matrix E");
        printMatrix_hex(.matrix(E));
        
        F = MatrixMultiply(.A(C), .B(D)); // F=CD (in matrix form)
        $display("\t Matrix F");
        printMatrix_hex(.matrix(F));
        
        fpga = new();
        fpga.reset_tpu();
        // #8; // delay necessary for post synthesis simulation
        
        // Test begins here
        fpga.send_instruction(RHW_op, 1, A); // Read in matrix A and place it in Register 1
        fpga.send_instruction(LW_op, 1, Zero); // Load Register 1 as Weights into the Systolic Array
        
        fpga.send_instruction(RHW_op, 2, B); // Read in matrix B and place it in Register 2
        fpga.send_instruction(LS_op, 2, Zero); // Load Register 2 into SystolicArrange
        
        // C = AB
        fpga.send_instruction(MM_op, 3, Zero); // Multiply matrices and store the result in Register 3
        fpga.send_instruction(WHM_op, 3, Zero); // Write Register 3 (Matrix C) to the Scan Chain
        
        fpga.send_instruction(RHW_op, 5, E); // Read in matrix E and place it in Register 5
        fpga.send_instruction(LS_op, 5, Zero); // Load Register 5 into SystolicArrange
        
        // D = AE
        fpga.send_instruction(MM_op, 4, Zero); // Multiply matrices and store the result in Register 4
        fpga.send_instruction(WHM_op, 4, Zero); // Write Register 4 (Matrix D) to the Scan Chain
        
        fpga.send_instruction(LW_op, 3, Zero); // Load Register 3 (Matrix C) as Weights into the Systolic Array
        fpga.send_instruction(LS_op, 4, Zero); // Load Register 4 (Matrix D) into SystolicArrange
        
        // F = CD
        fpga.send_instruction(MM_op, 6, Zero); // Multiply matrices and store the result in Register 6
        fpga.send_instruction(WHM_op, 6, Zero); // Write Register 6 (Matrix F) to the Scan Chain
        #100;
        
        update_golden_reg_file();
        
    endtask
    
    function update_golden_reg_file();
        for(int i = 0; i < K; i++) begin
            case(i)
            1: golden_reg_file[i] = arrange_vector(A);
            2: golden_reg_file[i] = arrange_vector(B);
            3: golden_reg_file[i] = arrange_vector(C);
            4: golden_reg_file[i] = arrange_vector(D);
            5: golden_reg_file[i] = arrange_vector(E);
            6: golden_reg_file[i] = arrange_vector(F);
            default: golden_reg_file[i] = {(8*N*N){1'bx}};
            endcase
        end
    endfunction
endclass

class tpu_random extends tpu_sequence;
    Matrix A, B, C, D, E, F, G, H, Zero;
    task run();
        Zero = new(.data_size(ZEROS));
        Zero.randomize();
        
        A = new(.data_size(FULL_NUM)); // use this to test LW and LS instructions
        A.randomize();
        
        B = new(.data_size(FULL_NUM)); // use this to test LW and LS instructions
        B.randomize();
        
        C = new(.data_size(FULL_NUM)); // use this to test LW and LS instructions
        C.randomize();
        
        D = new(.data_size(FULL_NUM)); // use this to test LW and LS instructions
        D.randomize();
        
        E = new(.data_size(FULL_NUM)); // use this to test LW and LS instructions
        E.randomize();
        
        F = new(.data_size(FULL_NUM)); // use this to test LW and LS instructions
        F.randomize();
        
        G = new(.data_size(FULL_NUM)); // use this to test LW and LS instructions
        G.randomize();
        
        H = new(.data_size(FULL_NUM)); // use this to test LW and LS instructions
        H.randomize();
        
        $display("\t Original Matrix A");
        printMatrix_hex(.matrix(A));
        
        $display("\t Original Matrix B");
        printMatrix_hex(.matrix(B));
        
        $display("\t Original Matrix C");
        printMatrix_hex(.matrix(C));
        
        $display("\t Original Matrix D");
        printMatrix_hex(.matrix(D));
        
        $display("\t Original Matrix E");
        printMatrix_hex(.matrix(E));
        
        $display("\t Original Matrix F");
        printMatrix_hex(.matrix(F));
        
        $display("\t Original Matrix G");
        printMatrix_hex(.matrix(G));
        
        $display("\t Original Matrix H");
        printMatrix_hex(.matrix(H));
        
        fpga = new();
        fpga.reset_tpu();
        
        // Test begins here
        #3; // delay necessary for post synthesis simulation
        // Load all randomized matrices into TPU before performing multiplications
        fpga.send_instruction(RHW_op, 0, A);
        fpga.send_instruction(RHW_op, 1, B);
        fpga.send_instruction(RHW_op, 2, C);
        fpga.send_instruction(RHW_op, 3, D);
        fpga.send_instruction(RHW_op, 4, E);
        fpga.send_instruction(RHW_op, 5, F);
        fpga.send_instruction(RHW_op, 6, G);
        fpga.send_instruction(RHW_op, 7, H);
        
        // Perform the following multiplications (result = weight*systolic)
        // A=AB
        // B=AB
        // C=AB
        // D=CC
        // E=DD
        // F=AC
        // G=DE
        // H=FC
        
        // A=AB
        fpga.send_instruction(LW_op, 0, Zero); 
        fpga.send_instruction(LS_op, 1, Zero); 
        fpga.send_instruction(MM_op, 0, Zero); 
        fpga.send_instruction(WHM_op, 0, Zero); 
        
        // B=AB
        fpga.send_instruction(LW_op, 0, Zero); 
        // fpga.send_instruction(LS_op, 1, Zero); 
        fpga.send_instruction(MM_op, 1, Zero); 
        fpga.send_instruction(WHM_op, 1, Zero); 
                
        // C=AB
        // fpga.send_instruction(LW_op, 0, Zero); 
        fpga.send_instruction(LS_op, 1, Zero);
        fpga.send_instruction(MM_op, 2, Zero); 
        fpga.send_instruction(WHM_op, 2, Zero); 
        
        // D=CC
        fpga.send_instruction(LW_op, 2, Zero); 
        fpga.send_instruction(LS_op, 2, Zero);
        fpga.send_instruction(MM_op, 3, Zero); 
        fpga.send_instruction(WHM_op, 3, Zero); 
        
        // E=DD
        fpga.send_instruction(LW_op, 3, Zero); 
        fpga.send_instruction(LS_op, 3, Zero);
        fpga.send_instruction(MM_op, 4, Zero); 
        fpga.send_instruction(WHM_op, 4, Zero); 
        
        // F=AC
        fpga.send_instruction(LW_op, 0, Zero); 
        fpga.send_instruction(LS_op, 2, Zero);
        fpga.send_instruction(MM_op, 5, Zero); 
        fpga.send_instruction(WHM_op, 5, Zero); 
        
        // G=DE
        fpga.send_instruction(LW_op, 3, Zero); 
        fpga.send_instruction(LS_op, 4, Zero);
        fpga.send_instruction(MM_op, 6, Zero); 
        fpga.send_instruction(WHM_op, 6, Zero); 
        
        // H=FC
        fpga.send_instruction(LW_op, 5, Zero); 
        fpga.send_instruction(LS_op, 2, Zero);
        fpga.send_instruction(MM_op, 7, Zero); 
        fpga.send_instruction(WHM_op, 7, Zero); 
        
        #100;
        
        // Golden model calculations
        A = MatrixMultiply(.A(A), .B(B));
        B = MatrixMultiply(.A(A), .B(B));
        C = MatrixMultiply(.A(A), .B(B));
        D = MatrixMultiply(.A(C), .B(C));
        E = MatrixMultiply(.A(D), .B(D));
        F = MatrixMultiply(.A(A), .B(C));
        G = MatrixMultiply(.A(D), .B(E));
        H = MatrixMultiply(.A(F), .B(C));
        update_golden_reg_file();
        
        $display("\t Final Matrix A");
        printMatrix_hex(.matrix(A));
        
        $display("\t Final Matrix B");
        printMatrix_hex(.matrix(B));
        
        $display("\t Final Matrix C");
        printMatrix_hex(.matrix(C));
        
        $display("\t Final Matrix D");
        printMatrix_hex(.matrix(D));
        
        $display("\t Final Matrix E");
        printMatrix_hex(.matrix(E));
        
        $display("\t Final Matrix F");
        printMatrix_hex(.matrix(F));
        
        $display("\t Final Matrix G");
        printMatrix_hex(.matrix(G));
        
        $display("\t Final Matrix H");
        printMatrix_hex(.matrix(H));
        
    endtask
    
    function update_golden_reg_file();
        for(int i = 0; i < K; i++) begin
            case(i)
            0: golden_reg_file[i] = arrange_vector(A);
            1: golden_reg_file[i] = arrange_vector(B);
            2: golden_reg_file[i] = arrange_vector(C);
            3: golden_reg_file[i] = arrange_vector(D);
            4: golden_reg_file[i] = arrange_vector(E);
            5: golden_reg_file[i] = arrange_vector(F);
            6: golden_reg_file[i] = arrange_vector(G);
            7: golden_reg_file[i] = arrange_vector(H);
            default: golden_reg_file[i] = {(8*N*N){1'bx}};
            endcase
        end
    endfunction
endclass

`endif