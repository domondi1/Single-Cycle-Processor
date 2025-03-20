`timescale 10ns/1ns

module tb_datapath();

reg clk, clkMem;
wire [31:0] nPc, instruction, aluResult, regData2, memOut;
wire memWrite;

initial begin
	#0 clk = 1'b0; clkMem = 1'b0;
end

always @* begin
	#0.5 clk <= ~clk;
	#0.25 clkMem <= ~clkMem;
	#0.25 clk <= ~clk; clkMem <= ~clkMem;
end

datapath dp(
	.clk(clk),
	.instruction(instruction),
	.memOut(memOut),
	.nPc(nPc),
	.aluResult(aluResult),
	.regData2(regData2),
	.memWrite(memWrite)
	);

instruction IM(
		.address(nPc[7:2]), // word-aligned
		.clock(clk),
		.q(instruction)
	);

data DM(
		.address(aluResult[9:2]), // word-aligned
		.clock(clkMem),
		.data(regData2),
		.wren(memWrite),
		.q(memOut)
	);	

endmodule

module instruction(
	input [5:0] address, // shadow PC
	input clock,
	output [31:0] q
);

reg [5:0] addrReg;
reg [31:0] ins [0:7];

initial begin
	$monitor("instruction q: %h %b", q, q);
	addrReg = 0;
	ins[0] = 32'h00b00533; // add a0, x0, a1
	ins[1] = 32'h02000513; // addi a0, x0, 32
	ins[2] = 32'h0005a503; // lw a0, (0)a1
	ins[3] = 32'h00a5a223; // sw a0, (1)a1
	ins[4] = 32'h00b50263; // beq a0, a1, 4
	ins[5] = 32'h004580e7; // jalr ra, (4)a1
	ins[6] = 32'h00002023; // sw x0, (0)x0
	ins[7] = 32'hfedff0ef; // jal ra, -20
end

always @(posedge clock) begin
	addrReg <= address;
end

assign q = ins[addrReg];

endmodule

module data(
	input [7:0] address,
	input clock,
	input [31:0] data,
	input wren,
	output [31:0] q
);

reg [7:0] addrReg;
reg wrtReg;
reg [31:0] dataReg;
reg [31:0] memory[0:255];  // 1KB memory (256 words, each 32 bits)

initial begin
	memory[0] = 32'b0;
end

always @(posedge clock) begin
	addrReg <= address;
	wrtReg <= wren;
	dataReg <= data;
end

always @* begin
	if(wrtReg) memory[addrReg] = dataReg;
end

assign q = memory[addrReg];

endmodule
