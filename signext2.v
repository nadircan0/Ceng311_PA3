// Sign Extension Module (24-bit to 32-bit)
// This module extends a 24-bit input to a 32-bit output with sign preservation.
// It is used for handling larger immediate values or jump addresses in instructions.

module signext2(in1, out1);

// Input - 24-bit value to be extended
input [23:0] in1;

// Output - 32-bit sign-extended value
output [31:0] out1;

// Sign extend the 24-bit input to 32 bits
assign out1 = {{8{in1[23]}}, in1};  // Replicates the sign bit (in1[23]) for the upper 8 bits

endmodule