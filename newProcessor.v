module processor;

// Clock and Program Counter
reg clk;                                // Clock signal
reg [31:0] pc;                          // Program Counter (PC)

// Memory and Register Files
reg [7:0] datmem[0:63], mem[0:31];      // Data memory (64 bytes) and instruction memory (32 words)
reg [31:0] registerfile [0:15];         // Register file with 16 registers

integer i, c;                           // Iterators for initialization and debugging
reg [31:0] t_mem;                       // Temporary memory for debugging


// Internal Signals
wire [3:0] out1; 
wire [31:0] data, datab;                // Data inputs for ALU
wire [31:0] out2, out3, out4, out5, out6, out7;
wire [31:0] sum, extad, adder1out, adder2out, sextad, readdata, jump_address;
wire [7:0] opcode;                       // Opcode (8 bits)
wire [3:0] rs, rt, rd;                   // Register fields (4 bits)
wire [5:0] shamt;                        // Shift amount (6 bits)
wire [5:0] funct;                        // Function field (6 bits)
wire [15:0] address;                     // Immediate address (16 bits)
wire [23:0] j_address;                   // Jump address (24 bits)
reg [3:0] nr, necl;                      // Jalfor-specific counters
wire [31:0] instruct, dpack;             // Current instruction and data packet
wire [2:0] gout;                         // ALU operation type
wire [31:0] jump_ext;                    // Extended jump address


// Control Signals
wire cout, zout, pcsrc, regdest, alusrc, memtoreg, regwrite, memread,
memwrite, branch, aluop1, aluop0, jal, jump, jr, bne, addi, jalfor; // Control signals

// Counters for Jalfor
reg [3:0] loop_count;                    // Loop repetition counter
reg [31:0] loop_pc;                      // Loop start address


// Data Memory Write Operations
always @(posedge clk)
begin
    if (memwrite)
    begin 
        // Write data into memory byte by byte
        datmem[sum[5:0]+3] <= datab[7:0];
        datmem[sum[5:0]+2] <= datab[15:8];
        datmem[sum[5:0]+1] <= datab[23:16];
        datmem[sum[5:0]] <= datab[31:24];
    end
end


// Instruction Memory Fetch
assign instruct = {mem[pc[4:0]],
                  mem[pc[4:0]+1],
                  mem[pc[4:0]+2],
                  mem[pc[4:0]+3]};

// *** Instruction Format Parsing (ISA-Compatible) ***
// R-Type Instructions
assign opcode = instruct[31:24];     // Opcode (8 bits)
assign rs = instruct[23:20];         // Source register (4 bits)
assign rt = instruct[19:16];         // Target register (4 bits)
assign rd = instruct[15:12];         // Destination register (4 bits)
assign shamt = instruct[11:6];       // Shift amount (6 bits)
assign funct = instruct[5:0];        // Function field (6 bits)

// I-Type Instructions
assign address = instruct[15:0];     // Immediate address (16 bits)

// J-Type Instructions
assign j_address = instruct[23:0];   // Jump address (24 bits)

// Jal-for Instruction Parsing
assign nr = instruct[23:20];         // Loop repetition count (4 bits)
assign necl = instruct[19:16];       // Number of executed lines per iteration (4 bits)


// Register File Access
assign data = registerfile[rs];       // Source register data
assign datab = registerfile[rt];      // Target register data


// Data Memory Read Operations
assign dpack = {datmem[sum[5:0]],
                datmem[sum[5:0]+1],
                datmem[sum[5:0]+2],
                datmem[sum[5:0]+3]};

// Jump Address Calculation
signext2 signext(j_address, jump_address);


// Multiplexers for Data Selection
mult2_to_1_1 mult0(out0, zout, zout_of_bne, ~(instruct[24]));  // we can use last bit of opcodes because one of them 0 one of them 1
mult2_to_1_5 mult1(out1, rt, rd, regdest);
mult2_to_1_32 mult2(out2, datab, extad, alusrc);
mult2_to_1_32 mult3(out3, sum, dpack, memtoreg);
mult2_to_1_32 mult4(out4, adder1out, adder2out, pcsrc);
mult2_to_1_32 mult5(out5, out4, jump_address, jump);


// Writing to Register File
always @(posedge clk)
begin
  	registerfile[out1] = regwrite ? out3 : registerfile[out1]; // Write result to register
end


// *** Jalfor Control and Data Path ***
// Control Registers for Jalfor Loop Execution
reg [31:0] ret_addr;                // Return address
reg [3:0] iter_count;               // Iteration counter
reg [3:0] line_count;               // Total line count
reg [3:0] line_count_0;             // Current line counter
reg [31:0] loop_start;              // Loop start address


always @(posedge clk) begin
    // Jalfor Initialization
    if (jalfor) begin
        ret_addr <= pc + 4;                        // Save return address
        iter_count <= nr;                          // Load iteration count
        line_count <= necl;                        // Load line count
        line_count_0 <= 1;                         // Reset current line count
        loop_start <= {16'b0, instruct[15:0]};     // Set loop start address
        pc <= {16'b0, instruct[15:0]};             // Jump to loop start address
    end 

    // Execution Within Loop
    else if (iter_count > 0) begin
        if (line_count_0 == line_count) begin
            if (iter_count == 1) begin
                pc <= ret_addr;                    // Return to saved address
                iter_count <= 0;                   // Reset iteration counter
		        line_count_0 <= line_count + 1;    // Reset line counter
            end 
	        else begin
                pc <= loop_start;                  // Restart loop
                iter_count <= iter_count - 1;      // Decrease iteration counter
		        line_count_0 <= 1;                 // Reset line counter
            end
	    end 
	    else begin
            line_count_0 <= line_count_0 + 1;      // Increment line counter
		    pc <= pc + 4;                          // Move to next instruction
        end
    end 
    // Normal Execution
    else begin
        pc <= out5;                               // Continue normal execution
    end
end


// ALU and Arithmetic Operations
alu32 alu1(sum, data, out2, zout, gout, shamt);
adder add1(pc, 32'h4, adder1out);
adder add2(adder1out, sextad, adder2out);

// Control Unit Initialization
control ctrl(opcode, regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop0, jal, jump, jr, addi, jalfor);

// ALU Control Unit
alucont alu_ctrl(aluop1, aluop0, funct[3], funct[2], funct[1], funct[0], gout);

// Sign Extension
signext sext(address, extad);           // Sign-extends the immediate value (16-bit to 32-bit)

// Shift Operation
shift shift2(sextad, extad);            // Left-shifts the sign-extended value by 2 bits


// *** Branch Control Logic ***
// Controls branching based on comparison result
assign zout_of_bne = (~zout);               // NOT operation for zero flag (used in BNE)
assign pcsrc = branch && out0;          // PC source determined by branch condition


// *** Memory and Register Initialization ***
// Initialize memory and registers at the start
initial
begin
	// Load initial data into memory and registers
    $readmemh("initDM.dat",datmem);
    $readmemh("initIM.dat",mem);
    $readmemh("initReg.dat",registerfile);

	// Debugging: Display memory and register content
	for (i = 0; i < 31; i = i + 1)
		$display("Instruction Memory[%0d]= %h, Data Memory[%0d]= 0x%h, Register[%0d]= 0x%h",
		         i, mem[i], i, datmem[i], i, registerfile[i]);

	// Debugging: Display instruction details
	c = 0;
	t_mem = 0;

	for (i = 0; i < 31; i = i + 1) begin
		t_mem = {t_mem[23:0], mem[i]};  // Combine bytes into a full instruction
		c = c + 1;

		// Display instruction when 4 bytes are combined
		if (c == 4) begin
			c = 0;
			$display("Instruction Memory[%0d]= 0x%h [%b %b %b %b %b %b]",
			         i - 3, t_mem,                 // Instruction memory index and value
			         t_mem[31:24], t_mem[23:20],   // Opcode and rs
			         t_mem[19:16], t_mem[15:12],   // rt and rd
			         t_mem[11:6], t_mem[5:0]);     // shamt and funct
			t_mem = 0; 
		end
	end
end


// *** Program Counter Initialization and Simulation Time ***
// Initialize program counter and define simulation duration
initial
begin
	pc = 0;                             // Start PC at address 0
	#500 $finish;                       // End simulation after 500 time units
end


// *** Clock Signal Generation ***
// Generate clock signal with 20-unit period
initial
begin
	clk = 0;                            // Start clock at 0
	forever #20 clk = ~clk;             // Toggle clock every 20 time units
end


// *** Execution Monitoring ***
// Display execution trace for debugging
initial 
begin
	$monitor($time,                      // Display simulation time
	         " PC: %h [%d]", pc, pc,      // Program counter in hex and decimal
	         " SUM: %h", sum,             // ALU output
	         " INST: %h [%b %b %b %b %b %b]", instruct[31:0], // Instruction details
	         opcode, rs, rt, rd, shamt, funct, // Parsed instruction fields
	         " REG: %h %h %h %h %p",      // Register contents
	         registerfile[4], registerfile[5], 
	         registerfile[6], registerfile[1], 
	         registerfile,
	         " DATA MEM: %p", datmem);    // Data memory contents
end

endmodule
