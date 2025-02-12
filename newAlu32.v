
// 32-bit Arithmetic Logic Unit (ALU)
// This module performs various arithmetic and logical operations based on the control signal (alu_control).
// Supported operations include AND, OR, ADD, SUB, NOR, SLL (Shift Left Logical), and SRL (Shift Right Logical).

module alu32(alu_out, a, b, zout, alu_control, shamt);

output reg [31:0] alu_out;  // 32-bit output of ALU operation
input [31:0] a, b;         // 32-bit input operands
input [2:0] alu_control;   // Control signal determining the ALU operation
input [5:0] shamt;         // Shift amount for SLL and SRL operations

output zout;               // Zero flag output
reg zout;                  

// ALU Operation Execution
always @(a or b or alu_control or shamt)
begin
    case(alu_control)
        3'b111: alu_out = a & b;          // Logical AND operation
        3'b110: alu_out = a | b;          // Logical OR operation
        3'b001: alu_out = a + b;          // Addition operation
        3'b010: alu_out = b << shamt;     // SLL - Shift Left Logical
        3'b011: alu_out = b >> shamt;     // SRL - Shift Right Logical
        3'b100: alu_out = ~(a | b);       // NOR operation
        3'b101: alu_out = a - b ;         // Subtraction operation

        default: alu_out = 31'bx;         // Default case for invalid inputs
    endcase

    // Zero Flag Calculation
    zout = ~(|alu_out);  // Set zout to 1 if alu_out is zero
end

endmodule