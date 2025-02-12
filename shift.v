// Shift Module
// This module performs a left shift operation by 2 bits on a 32-bit input.
// It is typically used to calculate word-aligned memory addresses or offsets.

module shift(shout, shin);

// Output - Shifted value
output [31:0] shout;      // 32-bit output after shifting

// Input - Value to be shifted
input [31:0] shin;        // 32-bit input value

// Perform Left Shift Operation
assign shout = shin << 2; // Shift input left by 2 bits (multiply by 4)

endmodule