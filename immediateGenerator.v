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