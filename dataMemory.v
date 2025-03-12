
////Data Memory /////
module dataMemory(
    input [31:0] address,        // Memory address (from ALU)
    input [31:0] writeData,      // Data to write (from rs2)
    input memWrite, memRead,     // Control signals
    input clk,                   // Clock
    output reg [31:0] readData   // Data read from memory
);

reg [31:0] memory[0:1023];  // 4KB memory (1024 words, each 32 bits)

always @(posedge clk) begin
    if (memWrite)
        memory[address[11:2]] <= writeData;  // Word-aligned write
end

always @* begin
    if (memRead)
        readData = memory[address[11:2]];    // Word-aligned read
    else
        readData = 32'b0;
end

endmodule