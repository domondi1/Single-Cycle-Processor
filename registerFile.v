

////////REGISTER FILE /////////////////////
module registerFile(
    input [4:0] rs1, rs2, rd,      // Register addresses
    input [31:0] writeData,        // Data to write
    input regWrite,                // Write enable
    input clk,                     // Clock
    output [31:0] readData1, readData2  // Read data
);

reg [31:0] RF[0:31];  // 32 registers, each 32 bits wide

// Read logic (combinational)
assign readData1 = RF[rs1];
assign readData2 = RF[rs2];

// Write logic. Sequential on negative clk edge
always @(posedge ~clk) begin
    if (regWrite && rd != 5'b0)  // Prevent writing to x0 (always 0)
        RF[rd] <= writeData;
end

// Ensure x0 is always 0 // TO-DO: initialize all register
initial begin
   RF[0] = 32'd0;
	RF[10] = 32'd0;
	RF[11] = 32'd0;
	RF[1] = 32'd0;
	RF[2] = 32'd1023;
end

endmodule