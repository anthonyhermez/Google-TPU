module control #(parameter N = 4, parameter K = 8) (
    input logic clk,
    input logic rst_n,
    input logic s_update,
    input logic [2 + $clog2(K) : 0] instruction,
    output logic [11:0] control_signals,
    output logic [$clog2(K)-1 : 0] instr_reg
);

    typedef enum logic [3:0] {
        Start, Decode, RHM, LW, LW_Wait, LS, LS_Wait, Result_Wait, MM_Result, WHM
    } state_t;
    
    typedef enum logic [2:0] {
        RHW_op, LW_op, LS_op, MM_op, WHM_op
    } opcode_t;
    
    state_t current_state, next_state;
    reg [2 + $clog2(K) : 0] instr;
    reg [$clog2(2*N) : 0] count;
    wire [2:0] opcode;
    assign opcode = instr[$clog2(K)+2:$clog2(K)];

    assign instr_reg = instr[$clog2(K)-1 : 0];

    // State transition logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= Start;
            instr <= '0;
            count <= '0;
        end else begin
            current_state <= next_state;
            instr <= (next_state == Decode) ? (instruction) : ((next_state == Start) ? ('0) : (instr));
            case(next_state)
            LW_Wait:        count <= (current_state != next_state) ? (N) : (count - 1);
            LS_Wait:        count <= (current_state != next_state) ? (N-1) : (count - 1);
            Result_Wait:    count <= (current_state != next_state) ? ((2*N) - 1) : (count - 1);
            default:        count <= '0;
            endcase
        end
    end

    // Next state logic
    always_comb begin
        next_state = current_state;
        case (current_state)
            Start: begin
                next_state = (s_update) ? (Decode) : (Start);
            end
            Decode: begin
                case (instr[$clog2(K)+2:$clog2(K)]) // opcode
                    RHW_op:  next_state = RHM;
                    LW_op:   next_state = LW;
                    LS_op:   next_state = LS;
                    MM_op:   next_state = LS_Wait;
                    WHM_op:  next_state = WHM;
                    default: next_state = Start;
                endcase
            end
            RHM:            next_state = Start;
            LW:             next_state = LW_Wait;
            LW_Wait:        next_state = (count == 0) ? (Start) : (LW_Wait);
            LS:             next_state = Start;
            LS_Wait:        next_state = (count == 0) ? (Result_Wait) : (LS_Wait);
            Result_Wait:    next_state = (count == 0) ? (MM_Result) : (Result_Wait);
            MM_Result:      next_state = Start;
            WHM:            next_state = Start;
            default:        next_state = Start;
        endcase
    end

    // Output logic
    always_comb begin
        control_signals = 12'b000000000000;
        case (current_state)
            Start:          control_signals = 12'b000000000000;
            Decode:         control_signals = 12'b000000000000;
            RHM:            control_signals = 12'b010110000000;
            LW:             control_signals = 12'b001001000000;
            LW_Wait:        control_signals = 12'b000000100000;
            LS:             control_signals = 12'b001000010000;
            LS_Wait:        control_signals = 12'b000000001100;
            Result_Wait:    control_signals = 12'b000000001101;
            MM_Result:      control_signals = 12'b000110000010;
            WHM:            control_signals = 12'b101000000000;
            default:        control_signals = 12'b000000000000;
        endcase
    end

endmodule
