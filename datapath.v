module datapath(
    input CLOCK_50,          // System clock
    input reset,             // Reset signal
    output reg [31:0] PC     // Program counter (for debugging)
);

    // Internal signals
    wire [31:0] instruction; // Current instruction
    wire [31:0] oprnd1, oprnd2, regDataWrite, regDataWriteSrc, aluResult, regData2, PCPlusFour, imm, immSft, PCOffset, nPc, memOut;
    wire BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, aluZeroFlag, pllRst, pllClk0, pllClk1, pllLocked;
    wire [2:0] ALUOp;

    // Instantiate modules
	 PLL pll(
		.refclk(CLOCK_50),
		.rst(pllRst),
		.outclk_0(pllClk0),
		.outclk_1(pllClk1),
		.locked(pllLocked)
	);
	 
//    instructionMemory IM(
//        .PC(PC),
//        .ins(instruction)
//    );
	 
	 rom IM(
		.address(nPc[5:0]),
		.clock(pllClk0),
		.q(instruction)
	);

    registerFile RF(
        .rs1(instruction[19:15]),  // rs1 field
        .rs2(instruction[24:20]),  // rs2 field
        .rd(instruction[11:7]),    // rd field
        .writeData(regDataWrite),   // Data to write to register
        .regWrite(regWrite),        // Write enable
        .clk(pllClk0),             // Clock
        .readData1(oprnd1),         // Output operand 1
        .readData2(regData2)        // Output operand 2
    );

    alu ALU(
        .A(oprnd1),
        .B(oprnd2),
        .ALUOp(ALUOp),
        .result(aluResult),
        .zero(aluZeroFlag)
    );
	 
//	 ROM rom(
//        .address(aluResult),        // Memory address (from ALU)
//        .writeData(regData2),       // Data to write (from rs2)
//        .memWrite(memWrite),        // Write enable
//        .memRead(memToReg),         // Read enable
//        .clk(pllClk0),             // Clock
//        .readData(regDataWriteSrc)  // Data read from memory
//    );
	 //Connect everything to the wirw
	 
	 

//    dataMemory DM(
//        .address(aluResult),        // Memory address (from ALU)
//        .writeData(regData2),       // Data to write (from rs2)
//        .memWrite(memWrite),        // Write enable
//        .memRead(memToReg),         // Read enable
//        .clk(pllClk1),             // Clock
//        .readData(regDataWriteSrc)  // Data read from memory
//    );

	ram DM(
		.address(aluResult),
		.clock(pllClk1),
		.data(regData2),
		.wren(memWrite),
		.q(memOut)
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
	 //assign regDataWriteScr = memToReg ? memOut : aluResult;
    assign regDataWrite = PCToReg ? PCPlusFour : (memToReg ? memOut : aluResult); // Mux for register write data
    assign PCPlusFour = PC + 32'd4; // PC + 4
    assign immSft = (aluToPC ? aluResult : imm) << 1; // Shift immediate for branches/jumps
    assign PCOffset = PC + immSft[31:0]; // PC + offset for branches/jumps
    assign nPc = (BR && aluZeroFlag) || (BR && PCToReg) ? PCOffset[31:0] : PCPlusFour[31:0]; // Next PC logic

    // Update PC
    always @(posedge pllClk0 or posedge reset) begin
        if (reset)
            PC <= 32'b0; // Reset PC to 0
        else
            PC <= nPc; // Update PC to next instruction
    end

endmodule