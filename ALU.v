///ALU//////////
module ALU(
    input [31:0] A, B,         // Operands
    input [2:0] ALUOp,         // Operation selector
    output reg [31:0] result,  // Result
    output reg zero            // Zero flag for branches
);

always @* begin
    case(ALUOp)
        3'b000: result = A + B;        // ADD, ADDI, LW, SW
        3'b001: result = A - B;        // SUB, branch operations
        3'b010: result = A * B;        // MUL
        3'b011: result = A & B;        // AND
        3'b100: result = A | B;        // OR
        3'b101: result = A << B[4:0];  // SLL, SLLI (logical shift left)
        default: result = 32'b0;       // Default case
    endcase
    zero = (result == 32'b0);          // Set zero flag
end

endmodule