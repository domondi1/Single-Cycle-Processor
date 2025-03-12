module singleCycleProcessor();

reg [31:0] PC;
reg [31:0] RF[0:31];
wire [31:0] ins;
wire BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC;
wire ALUOp;

controlUnit CU(ins[6:0], ins[14:12], ins[31:25], BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, ALUOp);

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
				endcase
			end
			else if(func3 == 3'b111) ALUOp = 3'b011; // AND
			else if(func3 == 3'b110) ALUOp = 3'b100; // OR
			else if(func3 == 3'b001) ALUOp = 3'b101; // SLL
		end
		7'b0010011: begin // I
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC} = { 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0 };
			// check func3
			case(func3)
				3'b000: ALUOp = 3'b000; // ADDI
				3'b001: ALUOp = 3'b101; // SLLI
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
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC} = { 1'b1, 1'bx, 1'b0, 1'bx, 1'b1, 1'b1, 1'b0 };
			ALUOp = 3'bxxx; // X
		end
		7'b1100111: begin // JALR
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC} = { 1'b1, 1'bx, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1 };
			ALUOp = 3'b000; // add
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
	endcase
end

endmodule
