// Sign Extension Module
// This module performs sign extension to convert a 16-bit input to a 32-bit output.
// It is used for handling immediate values in instructions, ensuring proper sign representation.

module signext(in1, out1);

// Input - 16-bit value to be extended
input [15:0] in1;

// Output - 32-bit sign-extended value
output [31:0] out1;

// Sign extend the 16-bit input to 32 bits
assign out1 = {{16{in1[15]}}, in1};  // Replicates the sign bit (in1[15]) for the upper 16 bits

endmodule