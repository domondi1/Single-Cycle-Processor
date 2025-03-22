`timescale 10ns/1ns

module tb_datapath();

reg clk, clkMem;
wire [31:0] nPc, instruction, aluResult, regData2, memOut;
wire memWrite, ht;
//reg [5:0] PC;
//
//always @* begin
//	if(~ht)
//		PC = nPc[7:2];
//end
//wire [5:0] PC;
//reg [5:0] prevNPC;
//
//assign PC = instruction[6:0] == 7'b1111111 ? prevNPC : nPc[7:2];
//
//always @(posedge clk) begin
//	prevNPC <= PC;
//end

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
	.memWrite(memWrite),
	.ht(ht)
	);

fakeRom IM(
		.address(nPc[7:2]), // word-aligned
		.clock(clk),
		.ht(ht),
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
	input ht,
	input clock,
	output [31:0] q
);

reg [5:0] addrReg;
reg [31:0] ins [0:18];

initial begin
	$monitor("instruction q: %h %b", q, q);
	addrReg = 0;
	//tp1
	ins[0] = 32'h00800293; 
	ins[1] = 32'h00F00313; 
	ins[2] = 32'h0062A023; 
	ins[3] = 32'h005303B3; 
	ins[4] = 32'h40530E33; 
	ins[5] = 32'h03C384B3; 
	ins[6] = 32'h00428293; 
	ins[7] = 32'hFFC2A903; 
	ins[8] = 32'h41248933; 
	ins[9] = 32'h00291913;
	ins[10] = 32'h0122A023;
	ins[11] = 32'h0000007F;
	//tp2
	ins[0] = 32'h00600513;
	ins[1] = 32'h00C000EF;
	ins[2] = 32'h00A02023;
	ins[3] = 32'h0000007F;
	ins[4] = 32'hFF810113;
	ins[5] = 32'h00112223;
	ins[6] = 32'h00A12023;
	ins[7] = 32'h00100293;
	ins[8] = 32'h00551863;
	ins[9] = 32'h00100513;
	ins[10] = 32'h00810113;
	ins[11] = 32'h00008067;
	ins[12] = 32'hFFF50513;
	ins[13] = 32'hFDDFF0EF;
	ins[14] = 32'h00012303;
	ins[15] = 32'h00412083;
	ins[16] = 32'h00810113;
	ins[17] = 32'h02650533;
	ins[18] = 32'h00008067;
end

always @(posedge clock) begin
	if(~ht)
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
reg [31:0] memory [0:255];  // 1KB memory (256 words, each 32 bits)

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
