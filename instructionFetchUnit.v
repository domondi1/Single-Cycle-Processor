module instructionFetchUnit(
    input CLOCK_50,
    input BR, PCToReg, aluToPC, halt,
    input [31:0] aluResult,
    input [31:0] imm,
    input branchTaken,
    output reg [31:0] PC,
    output [31:0] ins
);

// Internal wires
wire [31:0] nPc, PCPlusFour, PCOffset, immSft;

// Instruction memory (FPGA version with ROM)
instructionMemory IM(
    .PC(PC),
    .CLOCK_50(CLOCK_50),
    .ins(ins)
);

// PC update logic
assign PCPlusFour = PC + 32'd4;           // Normal PC increment
assign immSft = (aluToPC ? aluResult : imm) << 1;  // Shift immediate for jumps
assign PCOffset = PC + immSft[31:0];      // Branch/jump target address

// Next PC logic
assign nPc = (branchTaken || (BR && PCToReg)) ? PCOffset[31:0] :  // Branch or jump
             (aluToPC ? aluResult : PCPlusFour);                  // JALR or normal increment

// PC management
initial begin
    $monitor("%d PC: %d", $time, PC);
    PC = 32'b0;  // Initialize PC to 0
end

always @(posedge CLOCK_50) begin
    if (!halt)  // Stop PC updates when halt is asserted
        PC <= nPc[31:0];
end

endmodule