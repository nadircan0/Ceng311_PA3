
// 2-to-1 Multiplexer (32-bit)
// This module selects one of the two 32-bit inputs (i0 or i1) based on the selector signal (s0).
// If s0 = 0, output (out) is set to i0.
// If s0 = 1, output (out) is set to i1.

module mult2_to_1_32(out, i0, i1, s0);
output [31:0] out;        // 32-bit output
input [31:0] i0, i1;      // 32-bit inputs
input s0;                 // Selector signal

// Multiplexer logic: Select input based on selector signal
assign out = s0 ? i1 : i0;

endmodule