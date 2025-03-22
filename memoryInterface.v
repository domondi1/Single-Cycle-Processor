module memoryInterface(input CLOCK_50);

wire clk, clkMem, reset;
wire [31:0] nPc, instruction, aluResult, regData2, memOut;
wire memWrt, ht;

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
	
fakeRom IM(
		.address(nPc[7:2]), // word-aligned
		.ht(ht),
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

module fakeRom(
	input [5:0] address, // shadow PC
	input ht,
	input clock,
	output [31:0] q
);

reg [5:0] addrReg;
reg [31:0] ins [0:19];

initial begin
	$monitor("instruction q: %h %b", q, q);
	addrReg = 6'd0;
	// Test program 2
//	ins[0] = 32'h00800293;
//	ins[1] = 32'h00800293;
//	ins[2] = 32'h00F00313; 
//	ins[3] = 32'h0062A023; 
//	ins[4] = 32'h005303B3; 
//	ins[5] = 32'h40530E33; 
//	ins[6] = 32'h03C384B3; 
//	ins[7] = 32'h00428293; 
//	ins[8] = 32'hFFC2A903; 
//	ins[9] = 32'h41248933; 
//	ins[10] = 32'h00291913;
//	ins[11] = 32'h0122A023;
//	ins[12] = 32'h0000007F;
//	// Test program 3
	ins[0] = 32'h00600513;
	ins[1] = 32'h00600513;
	ins[2] = 32'h00C000EF;
	ins[3] = 32'h00A02023;
	ins[4] = 32'h0000007F;
	ins[5] = 32'hFF810113;
	ins[6] = 32'h00112223;
	ins[7] = 32'h00A12023;
	ins[8] = 32'h00100293;
	ins[9] = 32'h00551863;
	ins[10] = 32'h00100513;
	ins[11] = 32'h00810113;
	ins[12] = 32'h00008067;
	ins[13] = 32'hFFF50513;
	ins[14] = 32'hFDDFF0EF;
	ins[15] = 32'h00012303;
	ins[16] = 32'h00412083;
	ins[17] = 32'h00810113;
	ins[18] = 32'h02650533;
	ins[19] = 32'h00008067;
	// Test program fibonacci
	// ins[0] = 32'h00000513;
	// ins[1] = 32'h00000513;
	// ins[2] = 32'h06400593;
	// ins[3] = 32'h00a5a023;
	// ins[4] = 32'h00100513;
	// ins[5] = 32'h00458593;
	// ins[6] = 32'h00a5a023;
	// ins[7] = 32'h00300713;
	// ins[8] = 32'h01500793;
	// ins[9] = 32'h00458593;
	// ins[10] = 32'hffc5a603;
	// ins[11] = 32'hff85a683;
	// ins[12] = 32'h00d60533;
	// ins[13] = 32'h00a5a023;
	// ins[14] = 32'h00170713;
	// ins[15] = 32'h00f70463;
	// ins[16] = 32'hfe5ff06f;
	// ins[17] = 32'h0000007f;
	
end

always @(posedge clock) begin
	if(!ht)
		addrReg <= address;
end

assign q = ins[addrReg];

endmodule
