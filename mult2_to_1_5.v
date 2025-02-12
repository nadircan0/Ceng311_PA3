
// 2-to-1 Multiplexer (4-bit)
// This module selects one of the two 4-bit inputs (i0 or i1) based on the selector signal (s0).
// If s0 = 0, output (out) is set to i0.
// If s0 = 1, output (out) is set to i1.

module mult2_to_1_5(out, i0, i1, s0);
output [3:0] out;        // 4-bit output
input [3:0] i0, i1;      // 4-bit inputs
input s0;                // Selector signal

// Multiplexer logic: Select input based on selector signal
assign out = s0 ? i1 : i0;

endmodule