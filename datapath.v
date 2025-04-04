module datapath(
    input clk,              // System clock
	 input [31:0] instruction, memOut,
    //input reset,             // Reset signal
	 output [31:0] regData2, aluResult,
	 output reg [31:0] nPc,
	 output memWrite, ht
	);

    // Internal signals
    //wire [31:0] instruction; // Current instruction
    wire [31:0] oprnd1, oprnd2, regDataWrite, regDataWriteSrc, PCPlusFour, imm, immSft, PCOffset;
    wire BR, memToReg, ALUSrc, regWrite, PCToReg, aluToPC, aluZeroFlag;
    wire [2:0] ALUOp;
	 reg [31:0] PC;
	 wire reset;
	 
	initial begin
		PC = 32'd0;
	end

    // Instantiate modules
	 
//    instructionMemory IM(
//        .PC(PC),
//        .ins(instruction)
//    );
	 

    registerFile RF(
        .rs1(instruction[19:15]),  // rs1 field
        .rs2(instruction[24:20]),  // rs2 field
        .rd(instruction[11:7]),    // rd field
        .writeData(regDataWrite),   // Data to write to register
        .regWrite(regWrite),        // Write enable
        .clk(clk),             // Clock
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
        .ALUOp(ALUOp),
		  .halt(ht)
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
    assign immSft = imm << 1; // Shift immediate for branches/jumps
    assign PCOffset = PC + immSft[31:0]; // PC + offset for branches/jumps
	 assign brOnZero = instruction[14:12] == 3'b001 ? ~aluZeroFlag : aluZeroFlag;
	 
	 always @* begin
			//nPc = (BR && brOnZero) || (BR && PCToReg) ? PCOffset[31:0] : (aluToPC) ? aluResult : PCPlusFour[31:0]; // Next PC logic
			//if(~ht) begin
				if((BR && brOnZero) || (BR && PCToReg)) begin
					if(aluToPC) 
						nPc = aluResult;
					else 
						nPc = PCOffset[31:0];
				end else
					nPc = PCPlusFour[31:0];
//			end else begin
//				nPc = PC;
//			end
		end
	

    // Update PC
    always @(posedge clk) begin
			//PC <= nPc;
        if(!ht)
            PC <= nPc; // Update PC to next instruction
			//else  PC <= PC;
    end

endmodule