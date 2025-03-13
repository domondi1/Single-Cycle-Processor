module singleCycleProcessor(input CLOCK_50, input [31:0] ins);

reg [31:0] PC;
wire [31:0] imm, oprnd1, oprnd2, regDataWrite, aluResult, regData2, PCPlusFour, regDataWriteSrc, PCOffset, immSft;
wire BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, aluZeroFlag;
wire [2:0] ALUOp;

registerFile RF(ins[19:15], ins[24:20], ins[11:7], regDataWrite, regWrite, CLOCK_50, oprnd1, regData2);
controlUnit CU(ins[6:0], ins[14:12], ins[31:25], BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, ALUOp);
alu ALU(oprnd1, oprnd2, ALUOp, aluResult, aluZeroFlag);
immediateGenerator immGen(ins, imm);

assign oprnd2 = ALUSrc ? imm : regData2;
assign regDataWrite = PCToReg ? PCPlusFour : regDataWriteSrc;
assign PCPlusFour = PC + 32'd4;
assign immSft = (aluToPC ? aluResult : imm) << 1;
assign PCOffset = PC + immSft;

initial begin
	$monitor("%d PC: %d", $time, PC);
	PC = 32'b0;	
end

always @(posedge CLOCK_50) begin
	PC <= (BR && aluZeroFlag) || (BR && PCToReg) ? PCOffset : PCPlusFour;
end

endmodule

module controlUnit(
	input [6:0] opcode,
	input [2:0] func3,
	input [6:0] func7,
	output reg BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC,
	output reg [2:0] ALUOp
);

always @* begin
	case(opcode)
		7'b0110011: begin // R
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC} = { 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0 };
			// check func7&func3
			if(func3 == 3'b000) begin
				case(func7)
					7'b0000000: ALUOp = 3'b000; // ADD
					7'b0100000: ALUOp = 3'b001; // SUB
					7'b0000001: ALUOp = 3'b010; // MUL
					default: ALUOp = 3'bxxx;
				endcase
			end
			else if(func3 == 3'b111) ALUOp = 3'b011; // AND
			else if(func3 == 3'b110) ALUOp = 3'b100; // OR
			else if(func3 == 3'b001) ALUOp = 3'b101; // SLL
			else ALUOp = 3'bxxx;
		end
		7'b0010011: begin // I
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC} = { 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0 };
			// check func3
			case(func3)
				3'b000: ALUOp = 3'b000; // ADDI
				3'b001: ALUOp = 3'b101; // SLLI
				default: ALUOp = 3'bxxx;
			endcase
		end
		7'b0000011: begin // LW
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC} = { 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0 };
			ALUOp = 3'b000; // add
		end
		7'b0100011: begin // SW
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC} = { 1'b0, 1'bx, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0 };
			ALUOp = 3'b000; // add
		end
		7'b1100011: begin // B
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC} = { 1'b1, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 };
			ALUOp = 3'b001; // sub
		end
		7'b1101111: begin // JAL
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC} = { 1'b1, 1'bx, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0 };
			ALUOp = 3'bxxx; // X
		end
		7'b1100111: begin // JALR
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC} = { 1'b1, 1'bx, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1 };
			ALUOp = 3'b000; // add
		end
		default: begin
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC} = { 1'bx, 1'bx, 1'bx, 1'b0, 1'bx, 1'bx, 1'bx };
			ALUOp = 3'bxxx;
		end
	endcase
end

endmodule

module immediateGenerator(input [31:0] ins, output reg [31:0] imm);

wire [6:0] opcode;
assign opcode = ins[6:0];

always @* begin
	case(opcode)
		7'b0010011: begin
			imm[11:0] = ins[31:20]; // I
			imm[31:12] = {20{ins[31]}};
		end
		7'b1100111: begin
			imm[11:0] = ins[31:20]; // JALR
			imm[31:12] = {20{ins[31]}};
		end
		7'b1100011: begin
			imm[11:0] = {ins[31], ins[7], ins[30:25], ins[11:8]}; // B
			imm[31:12] = {20{ins[31]}};
		end
		7'b1101111: begin
			imm[19:0] = {ins[31], ins[19:12], ins[20], ins[30:21]}; // JAL
			imm[31:20] = {12{ins[31]}};
		end
		default: imm = 32'hxxxxxxxx;
	endcase
end

endmodule
