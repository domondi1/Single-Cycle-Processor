module tb_cu_immgen;

reg [31:0] ins;
wire signed [31:0] imm;
wire BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC;
wire ALUOp;

controlUnit CU(ins[6:0], ins[14:12], ins[31:25], BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, ALUOp);
immediateGenerator immGen(ins, imm);

initial begin
	$monitor("ALU Source: %b, memToReg: %b, regWrite: %b, memWrite: %b, branch: %b, ALU Operation: %b, immediate: %d %b",
		ALUSrc, memToReg, regWrite, memWrite, BR, ALUOp, imm, imm);
	#0 ins = 32'h00b00533; // add a0, x0, a1
	#1 ins = 32'h02000513; // addi a0, x0, 32
	#1 ins = 32'h0005a503; // lw a0, (0)a1
	#1 ins = 32'h00a5a023; // sw a0, (0)a1
	#1 ins = 32'h00b50263; // beq a0, a1, 4
	#1 ins = 32'hfedff0ef; // jal ra, -20
	#1 ins = 32'h004580e7; // jalr ra, (4)a1
end

endmodule