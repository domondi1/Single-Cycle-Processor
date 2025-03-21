module memoryInterface(input CLOCK_50);

wire clk, clkMem, reset;
wire [31:0] nPc, instruction, aluResult, regData2, memOut;
wire memWrt;

//reg [7:0] prevAddr, address;
//reg [31:0] prevData, data;
//reg prevWrt, wren;
//
//always @(posedge clkMem) begin
//	prevAddr <= address;
//	prevData <= data;
//	prevWrt <= wren;
//end
//
//always @* begin
//	if(instruction[6:0] == 7'b1111111) begin
//		address = prevAddr;
//		data = prevData;
//		wren = prevWrt;
//	end
//	else begin
//		address = aluResult[9:2];
//		data = regData2;
//		wren = memWrt;
//	end
//end

datapath DP(
	.clk(clk),
	.instruction(instruction),
	.memOut(memOut),
	.nPc(nPc),
	.aluResult(aluResult),
	.regData2(regData2),
	.memWrite(memWrt)
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
		.wren(memWrt),
		.q(memOut)
	);	

PLL CLK(
	.refclk(CLOCK_50),
	.rst(reset),
	.outclk_0(clk),
	.outclk_1(clkMem),
	);

endmodule
