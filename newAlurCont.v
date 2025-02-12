
// ALU Control Unit
// This module generates the ALU control signals based on the ALUOp code and function field (funct) from the instruction.
// It determines which operation the ALU should perform, such as ADD, SUB, AND, OR, SLL, SRL, or NOR.

module alucont(aluop1, aluop0, f3, f2, f1, f0, gout);

input aluop1, aluop0;         // ALU operation code inputs
input f3, f2, f1, f0;         // Function field inputs (funct[3:0])
output reg [2:0] gout;        // ALU control output to select the operation

// ALU Control Logic
always @(aluop1 or aluop0 or f3 or f2 or f1 or f0)
begin
    // ALUOp = 00: ADD operation (used for lw, sw, and addi instructions)
    if (~(aluop1 | aluop0))         
        gout = 3'b001;         // ADD

    // ALUOp = 01: SUB operation (used for beq and bne instruction)
    if (aluop0)                
        gout = 3'b101;         // SUB

    // ALUOp = 10: R-Type instructions
    if (aluop1)                
    begin
        // Function field decoding for R-type instructions
        if (~(f3) & f2 & f1 & f0)
            gout = 3'b001;     // ADD
        if (~(f3) & ~(f2) & ~(f1) & f0)
            gout = 3'b010;     // SLL (Shift Left Logical)
        if (~(f3) & ~(f2) & f1 & ~(f0))
            gout = 3'b011;     // SRL (Shift Right Logical)
        if (~(f3) & ~(f2) & f1 & f0)
            gout = 3'b100;     // NOR
        if (~(f3) & f2 & ~(f1) & ~(f0))
            gout = 3'b101;     // SUB
        if (~(f3) & f2 & ~(f1) & f0)
            gout = 3'b110;     // OR
        if (~(f3) & f2 & f1 & ~(f0))
            gout = 3'b111;     // AND
    end
end

endmodule