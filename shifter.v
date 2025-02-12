// Shifter Module
// This module performs a left shift operation by 2 bits on a 26-bit input.
// It is commonly used to handle jump address calculations in the instruction set architecture (ISA).

module shifter(shout, shin);

// Output - Shifted value
output [27:0] shout;       // 28-bit output after shifting

// Input - Value to be shifted
input [25:0] shin;         // 26-bit input value

// Perform Left Shift Operation
assign shout = shin << 2;  // Shift input left by 2 bits (used for address alignment)

endmodule