module instructionMemory(
    input [31:0] PC,
    output reg [31:0] ins
);

reg [31:0] memory[0:1023];  // 4KB instruction memory

always @* begin
    ins = memory[PC[11:2]];  // Word-aligned fetch
end

endmodule