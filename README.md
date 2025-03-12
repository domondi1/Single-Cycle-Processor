# Single-Cycle-Processor
Single-cycle RISCV processor

## ALU Operation Mapping

| ALUOp (Binary) | Operation |
|----------------|-----------|
| 000            | add       |
| 001            | sub       |
| 010            | mul       |
| 011            | and       |
| 100            | or        |
| 101            | sll       |

## Jump Instructions Datapath

### Control Signals
- `PCToReg`: When set to 1 (for `JAL` and `JALR`), this signal selects PC+4 to the data write port of the register file. When set to 0, the source of the data write port of the register file is determined by `memToReg`. 
- `aluToPC`: When set to 1 (for `JALR`), this signal selects the jump offset from the ALU. When set to 0 (for `JAL`), the jump offset is the output of immediate generation.
