// 2-to-1 Multiplexer (1-bit)
// This module implements a 1-bit 2-to-1 multiplexer. 
// It selects one of the two inputs (i0 or i1) based on the select signal (s0).
// If s0 = 0, output 'out' takes the value of i0.
// If s0 = 1, output 'out' takes the value of i1.

module mult2_to_1_1(out, i0, i1, s0);
    output out;         // 1-bit output
    input i0, i1;       // 1-bit inputs
    input s0;           // Select signal

    // Multiplexer logic: Selects input based on the value of s0
    assign out = s0 ? i1 : i0; 
endmodule