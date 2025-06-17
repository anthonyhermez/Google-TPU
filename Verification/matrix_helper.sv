`ifndef MATRIX_HELPER_SV
`define MATRIX_HELPER_SV

parameter N = 4;
parameter K = 8;
parameter size_of_inst = 3 + $clog2(K);
parameter size_of_data = 8*N*N;

 // TODO: fix constraints
typedef enum logic [2:0] {SMALL_NUM, LARGE_NUM, FULL_NUM, ZEROS, CHECKER_PAT, COUNT} DATA_SIZE;

typedef enum logic [2:0] {RHW_op, LW_op, LS_op, MM_op, WHM_op} opcode_t;

class input_q;
    bit [7:0] input_q[N][$];
    
endclass

class Matrix;
  rand bit [7:0] 	array[N][N];
  DATA_SIZE data_size;
  constraint  small_nums {
    foreach(array[i,j]) {
        array[i][j] >= 1;
        array[i][j] <= 5;
    }
  }
  constraint  large_nums {
    foreach(array[i,j]) {
        array[i][j] >= 240;
        array[i][j] <= 255;
    }
  }
  constraint  full_range {
    foreach(array[i,j]) {
        array[i][j] >= 0;
        array[i][j] <= 255;
    }
  }
  constraint zeros {
      foreach (array[i, j]) {
           array[i][j] == 8'h0;
      }
  }
  constraint  pattern_checker {
    foreach(array[i,j]) {
        array[i][j] == 8'h55;
    }
  }
  constraint  counting {
    foreach(array[i,j]) {
        array[i][j] == (i+1);
    }
  }
  
  function void disable_all_modes();
    small_nums.constraint_mode(0);
    large_nums.constraint_mode(0);
    full_range.constraint_mode(0);
    zeros.constraint_mode(0);
    pattern_checker.constraint_mode(0);
    counting.constraint_mode(0);
  endfunction
  
  function void enable_mode(DATA_SIZE mode);
    disable_all_modes();
    case (mode)
	SMALL_NUM : begin
	   $display ("SMALL_NUM");
	   small_nums.constraint_mode(1);
	end
	LARGE_NUM : begin
	   large_nums.constraint_mode(1);
	end
	FULL_NUM : begin
	   full_range.constraint_mode(1);
	end
	ZEROS : begin
	   $display ("ZEROS");
	   zeros.constraint_mode(1);
	end
	COUNT: begin
	   counting.constraint_mode(1);
	end
	CHECKER_PAT : begin
	   pattern_checker.constraint_mode(1);
	end
	
    endcase
  endfunction
                 
  function new (DATA_SIZE data_size);
    this.data_size = data_size;
    this.enable_mode(this.data_size);
    $display("modes: %0d, %0d, %0d, %0d, %0d, %0d",small_nums.constraint_mode(),large_nums.constraint_mode(),full_range.constraint_mode(),zeros.constraint_mode(),pattern_checker.constraint_mode(),counting.constraint_mode());
    this.randomize();
  endfunction
endclass

function reg [(size_of_inst + size_of_data - 1):0] reversed (reg [(size_of_inst + size_of_data - 1):0] input_vector);
    int i;
    for (i = 0; i < (size_of_inst + size_of_data); i++) begin
        reversed[i] = input_vector[(size_of_inst + size_of_data)-1-i];
    end
endfunction

function Matrix MatrixMultiply(Matrix A, Matrix B);
    MatrixMultiply = new(.data_size(ZEROS));
    for (int i = 0; i < N; i++) begin
        for (int j = 0; j < N; j++) begin
            MatrixMultiply.array[i][j] = 0;
            for (int k = 0; k < N; k++) begin
                MatrixMultiply.array[i][j] += A.array[i][k] * B.array[k][j];
            end
        end
    end
endfunction

function printMatrix(Matrix matrix);
    foreach(matrix.array[i,j]) $display("\t array[%0d][%0d] = %0d",i,j,matrix.array[i][j]);
endfunction

function printMatrix_hex(Matrix matrix);
    foreach(matrix.array[i,j]) $display("\t array[%0d][%0d] = 0x%0h",i,j,matrix.array[i][j]);
endfunction

function input_q systolic_arrange(Matrix matrix);
    systolic_arrange = new();
    foreach(systolic_arrange.input_q[i]) begin
        for(int j = 0; j < i; j++) begin
            systolic_arrange.input_q[i].push_back(8'h00);
        end
        for(int j = 0; j < N; j++) begin
            systolic_arrange.input_q[i].push_back(matrix.array[i][j]);
        end
        for(int j = 0; j < (N-i-1); j++) begin
            systolic_arrange.input_q[i].push_back(8'h00);
        end
        systolic_arrange.input_q[i].push_back(8'h00); // push one extra zero to help with testing
    end
endfunction

function input_q weight_arrange(Matrix matrix);
    weight_arrange = new();
    foreach(weight_arrange.input_q[i]) begin
        for(int j = N-1; j >= 0; j--) begin
            weight_arrange.input_q[i].push_back(matrix.array[i][j]);
        end
    end
endfunction

function printQueues(input_q array_of_queues);
    foreach(array_of_queues.input_q[i]) $display("array_of_queues[%0d] = %p", i, array_of_queues.input_q[i]);
endfunction

function reg [8*N*N-1 : 0] arrange_vector(Matrix matrix);
    for(int i = 0; i < N; i++) begin
        for(int j = 0; j < N; j++) begin
            // $display("\t mask[%0d][%0d] = %0h",i,j,~(8'hFF << (i*N+j)*8));
            arrange_vector = (arrange_vector & ~(8'hFF << (i*N+j)*8)) | (matrix.array[i][j] << (i*N+j)*8); // [ ((i*N+j) + 7) : (i*N+j) ]
        end
    end
endfunction

function print_vectorized_matrix(reg [8*N*N-1 : 0] systolic_in);
    for(int i = 0; i < N; i++) begin
        for(int j = 0; j < N; j++) begin
            $display("\t systolic_in[%0d : %0d] = %0d",((i*N+j)*8 + 7),(i*N+j)*8,(systolic_in >> ((i*N+j)*8)) & 8'hFF);
        end
    end
endfunction
`endif