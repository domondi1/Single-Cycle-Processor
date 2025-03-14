module datapath(
    input CLOCK_50,          // System clock
    input reset,             // Reset signal
    output reg [31:0] PC     // Program counter (for debugging)
);

    // Internal signals
    wire [31:0] instruction; // Current instruction
    wire [31:0] oprnd1, oprnd2, regDataWrite, aluResult, regData2, PCPlusFour, imm, immSft, PCOffset, nPc;
    wire BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, aluZeroFlag;
    wire [2:0] ALUOp;

    // Instantiate modules
    instructionMemory IM(
        .PC(PC),
        .ins(instruction)
    );

    registerFile RF(
        .rs1(instruction[19:15]),  // rs1 field
        .rs2(instruction[24:20]),  // rs2 field
        .rd(instruction[11:7]),    // rd field
        .writeData(regDataWrite),   // Data to write to register
        .regWrite(regWrite),        // Write enable
        .clk(CLOCK_50),             // Clock
        .readData1(oprnd1),         // Output operand 1
        .readData2(regData2)        // Output operand 2
    );

    alu ALU(
        .oprnd1(oprnd1),
        .oprnd2(oprnd2),
        .ALUOp(ALUOp),
        .aluResult(aluResult),
        .aluZeroFlag(aluZeroFlag)
    );

    dataMemory DM(
        .address(aluResult),        // Memory address (from ALU)
        .writeData(regData2),       // Data to write (from rs2)
        .memWrite(memWrite),        // Write enable
        .memRead(memToReg),         // Read enable
        .clk(CLOCK_50),             // Clock
        .readData(regDataWriteSrc)  // Data read from memory
    );

    controlUnit CU(
        .opcode(instruction[6:0]),
        .func3(instruction[14:12]),
        .func7(instruction[31:25]),
        .BR(BR),
        .memToReg(memToReg),
        .memWrite(memWrite),
        .ALUSrc(ALUSrc),
        .regWrite(regWrite),
        .PCToReg(PCToReg),
        .aluToPC(aluToPC),
        .ALUOp(ALUOp)
    );

    immediateGenerator immGen(
        .ins(instruction),
        .imm(imm)
    );

    // Assign signals
    assign oprnd2 = ALUSrc ? imm : regData2; // Mux for ALU operand 2
    assign regDataWrite = PCToReg ? PCPlusFour : regDataWriteSrc; // Mux for register write data
    assign PCPlusFour = PC + 32'd4; // PC + 4
    assign immSft = (aluToPC ? aluResult : imm) << 1; // Shift immediate for branches/jumps
    assign PCOffset = PC + immSft[31:0]; // PC + offset for branches/jumps
    assign nPc = (BR && aluZeroFlag) || (BR && PCToReg) ? PCOffset[31:0] : PCPlusFour[31:0]; // Next PC logic

    // Update PC
    always @(posedge CLOCK_50 or posedge reset) begin
        if (reset)
            PC <= 32'b0; // Reset PC to 0
        else
            PC <= nPc; // Update PC to next instruction
    end

endmodule