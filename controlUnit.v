module controlUnit(
	input [6:0] opcode,
	input [2:0] func3,
	input [6:0] func7,
	output reg BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt,
	output reg [2:0] ALUOp
);

always @* begin
	case(opcode)
		7'b0110011: begin // R
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = { 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0 };
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
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = { 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0 };
			// check func3
			case(func3)
				3'b000: ALUOp = 3'b000; // ADDI
				3'b001: ALUOp = 3'b101; // SLLI
				default: ALUOp = 3'bxxx;
			endcase
		end
		7'b0000011: begin // LW
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = { 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0 };
			ALUOp = 3'b000; // add
		end
		7'b0100011: begin // SW
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = { 1'b0, 1'bx, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0 };
			ALUOp = 3'b000; // add
		end
		7'b1100011: begin // B
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = { 1'b1, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0 };
			ALUOp = 3'b001; // sub
		end
		7'b1101111: begin // JAL
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = { 1'b1, 1'bx, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0 };
			ALUOp = 3'bxxx; // X
		end
		7'b1100111: begin // JALR
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = { 1'b1, 1'bx, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0 };
			ALUOp = 3'b000; // add
		end
		7'b1111111: begin // halt
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = { 1'b0, 1'bx, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 };
			ALUOp = 3'bxxx; // add
		end
		default: begin
			{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = { 1'bx, 1'bx, 1'bx, 1'b0, 1'bx, 1'bx, 1'bx, 1'b0 };
			ALUOp = 3'bxxx; // x
		end
	endcase
end

endmodule