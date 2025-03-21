module memoryInterface(input CLOCK_50);

wire clk, clkMem, reset, pllLocked;
wire [31:0] nPc, instruction, aluResult, regData2, memOut;
wire memWrite;

datapath DP(
	.clk(clk),
	.instruction(instruction),
	.memOut(memOut),
	.nPc(nPc),
	.aluResult(aluResult),
	.regData2(regData2),
	.memWrite(memWrite)
	);
	
rom IM(
		.address(nPc[7:2]), // word-aligned
		.clock(clk),
		.q(instruction)
	);
	
ram DM(
		.address(aluResult[9:2]), // word-aligned
		.clock(clkMem),
		.data(regData2),
		.wren(memWrite),
		.q(memOut)
	);	

PLL CLK(
	.refclk(CLOCK_50),
	.rst(reset),
	.outclk_0(clk),
	.outclk_1(clkMem),
	.locked(pllLocked)
	);

endmodule
