module memoryInterface(input CLOCK_50);

wire clk, clkMem, reset;
wire [31:0] nPc, instruction, aluResult, regData2, memOut;
wire memWrt, ht;
reg [5:0] PC;

always @* begin
	if(!ht)
		PC <= nPc[7:2];
end

//wire [5:0] PC;
//reg [5:0] prevNPC;
//
//assign PC = instruction[6:0] == 7'b1111111 ? prevNPC : nPc[7:2];
//
//always @(posedge clk) begin
//	prevNPC <= PC;
//end

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
	.memWrite(memWrt),
	.ht(ht)
	);
	
rom IM(
		.address(PC), // word-aligned
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
	.outclk_1(clkMem)
	);

endmodule
