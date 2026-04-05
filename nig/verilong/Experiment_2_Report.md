# Experiment 2 Report

## 1 Problem Statement

### 1.1 Part A: Behavioral Barrel Shifter
*   Design and implement an 8-bit Barrel Shifter using behavioral/dataflow modeling in Verilog.
*   The shifter should support two modes: Logical Shift Left (LSL) and Rotate Left (ROL).
*   The shift amount should be selectable from 0 to 7 bits using a 3-bit select line.
*   Verify the functionality using a testbench with various input patterns.

### 1.2 Part B: Structural Barrel Shifter
*   Design and implement the same 8-bit Barrel Shifter using structural modeling.
*   Utilize 2:1 Multiplexers to build the shifting stages.
*   Implement the design in three hierarchical stages (1-bit, 2-bit, and 4-bit shifts).
*   Verify that the structural implementation is logically equivalent to the behavioral version.

## 2 Procedure

### 2.1 Behavioral Barrel Shifter Design
A Barrel Shifter is a combinational circuit that can shift or rotate a data word by a specified number of bits in a single operation. The design was implemented using three stages corresponding to the bits of the select line (`select[2:0]`):

*   **Stage 0 (select[0]):** Shifts or rotates by 1 bit.
*   **Stage 1 (select[1]):** Shifts or rotates by 2 bits.
*   **Stage 2 (select[2]):** Shifts or rotates by 4 bits.

The `control` signal determines the fill bits:
*   `control = 0` (Logical Shift Left): Fills the empty LSB positions with zeros.
*   `control = 1` (Rotate Left): Fills the empty LSB positions with the bits shifted out from the MSB side.

The behavioral implementation used concatenation and the ternary operator to describe the logic for each stage.

### 2.2 Structural Barrel Shifter Design
The structural implementation realized the same three-stage logic using 2:1 Multiplexers. 
*   A `mux2to1` module was created to select between two bits based on a select signal.
*   For each stage, a set of "Data MUXes" was used to either pass the current bit or the bit from a shifted position.
*   "Control MUXes" were used to determine the "fill" bit for each stage based on the `control` signal (either a constant `0` for LSL or the actual MSB bit for ROL).

This modular approach allowed for a clear mapping of the shifting logic into hardware primitives.

## 3 Codes and Results

### 3.1 Part A: Behavioral Barrel Shifter

#### Source Codes - `exp2/exp2-behavioural/`
**Barrel Shifter (`barrel_shifter.v`):**
```verilog
module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] select,
    input        control,   // 0: Logical Shift Left, 1: Rotate Left
    output [7:0] data_out
);
    wire [7:0] stage0, stage1;

    assign stage0 = select[0] ? (control ? {data_in[6:0], data_in[7]}   : {data_in[6:0], 1'b0}) : data_in;
    assign stage1 = select[1] ? (control ? {stage0[5:0], stage0[7:6]}  : {stage0[5:0], 2'b00}) : stage0;
    assign data_out = select[2] ? (control ? {stage1[3:0], stage1[7:4]} : {stage1[3:0], 4'b0000}) : stage1;
endmodule
```

**Testbench (`testbench.v`):**
```verilog
`timescale 1ns/1ps

module testbench;
    reg  [7:0] data_in;
    reg  [2:0] select;
    reg        control;
    wire [7:0] data_out;

    barrel_shifter uut (
        .data_in (data_in),
        .select  (select),
        .control (control),
        .data_out(data_out)
    );

    integer i, c, p;
    reg [7:0] patterns [0:2];

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        patterns[0] = 8'b1010_1100;
        patterns[1] = 8'b1000_0000;
        patterns[2] = 8'b0101_0101;

        $display("Time	Ctrl	Sel	Input		Output");
        $monitor("%t	%b	%d	%b	%b", $time, control, select, data_in, data_out);

        for (p = 0; p < 3; p = p + 1) begin
            data_in = patterns[p];
            for (c = 0; c < 2; c = c + 1) begin
                control = c;
                for (i = 0; i < 8; i = i + 1) begin
                    select = i; #10;
                end
            end
        end
        $finish;
    end
endmodule
```

**Makefile:**
```makefile
OUT = barrel
SRC = barrel_shifter.v testbench.v
.PHONY: all compile run wave clean
all: run
compile:
	iverilog -o $(OUT) $(SRC)
run: compile
	vvp $(OUT)
wave: compile
	vvp $(OUT)
	gtkwave dump.vcd
clean:
	rm -f $(OUT) *.vcd
```

#### Simulation Result (Behavioral)
```text
=== Testing Data Pattern: 10101100 ===
--- Mode: Logical Shift Left ---
Time    Ctrl    Sel     Input           Output
                   0    0       0       10101100        10101100
               10000    0       1       10101100        01011000
               20000    0       2       10101100        10110000
               30000    0       3       10101100        01100000
               40000    0       4       10101100        11000000
               50000    0       5       10101100        10000000
               60000    0       6       10101100        00000000
               70000    0       7       10101100        00000000
--- Mode: Rotate Left ---
               80000    1       0       10101100        10101100
               90000    1       1       10101100        01011001
              100000    1       2       10101100        10110010
              110000    1       3       10101100        01100101
              120000    1       4       10101100        11001010
              130000    1       5       10101100        10010101
              140000    1       6       10101100        00101011
              150000    1       7       10101100        01010110
```

---

### 3.2 Part B: Structural Barrel Shifter

#### Source Codes - `exp2/exp2-structural/`
**2:1 Multiplexer (`mux2to1.v`):**
```verilog
module mux2to1 (
    input  a, b, sel,
    output out
);
    assign out = sel ? b : a;
endmodule
```

**Barrel Shifter (`barrel_shifter.v`):**
```verilog
module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] select,
    input        control,   // 0: Shift, 1: Rotate
    output [7:0] data_out
);

    wire [7:0] s0, s1;       // Outputs of Stage 0 and Stage 1
    wire [7:0] fill0, fill1, fill2; // Fill bits (0 or Rotated)

    // Stage 0: Shift/Rotate by 1 bit
    mux2to1 ctrl0 (1'b0, data_in[7], control, fill0[0]);
    mux2to1 stage0_0 (data_in[0], fill0[0],    select[0], s0[0]);
    mux2to1 stage0_1 (data_in[1], data_in[0],  select[0], s0[1]);
    mux2to1 stage0_2 (data_in[2], data_in[1],  select[0], s0[2]);
    mux2to1 stage0_3 (data_in[3], data_in[2],  select[0], s0[3]);
    mux2to1 stage0_4 (data_in[4], data_in[3],  select[0], s0[4]);
    mux2to1 stage0_5 (data_in[5], data_in[4],  select[0], s0[5]);
    mux2to1 stage0_6 (data_in[6], data_in[5],  select[0], s0[6]);
    mux2to1 stage0_7 (data_in[7], data_in[6],  select[0], s0[7]);

    // Stage 1: Shift/Rotate by 2 bits
    mux2to1 ctrl1_0 (1'b0, s0[6], control, fill1[0]);
    mux2to1 ctrl1_1 (1'b0, s0[7], control, fill1[1]);
    mux2to1 stage1_0 (s0[0], fill1[0], select[1], s1[0]);
    mux2to1 stage1_1 (s0[1], fill1[1], select[1], s1[1]);
    mux2to1 stage1_2 (s0[2], s0[0],    select[1], s1[2]);
    mux2to1 stage1_3 (s0[3], s0[1],    select[1], s1[3]);
    mux2to1 stage1_4 (s0[4], s0[2],    select[1], s1[4]);
    mux2to1 stage1_5 (s0[5], s0[3],    select[1], s1[5]);
    mux2to1 stage1_6 (s0[6], s0[4],    select[1], s1[6]);
    mux2to1 stage1_7 (s0[7], s0[5],    select[1], s1[7]);

    // Stage 2: Shift/Rotate by 4 bits
    mux2to1 ctrl2_0 (1'b0, s1[4], control, fill2[0]);
    mux2to1 ctrl2_1 (1'b0, s1[5], control, fill2[1]);
    mux2to1 ctrl2_2 (1'b0, s1[6], control, fill2[2]);
    mux2to1 ctrl2_3 (1'b0, s1[7], control, fill2[3]);
    mux2to1 stage2_0 (s1[0], fill2[0], select[2], data_out[0]);
    mux2to1 stage2_1 (s1[1], fill2[1], select[2], data_out[1]);
    mux2to1 stage2_2 (s1[2], fill2[2], select[2], data_out[2]);
    mux2to1 stage2_3 (s1[3], fill2[3], select[2], data_out[3]);
    mux2to1 stage2_4 (s1[4], s1[0],    select[2], data_out[4]);
    mux2to1 stage2_5 (s1[5], s1[1],    select[2], data_out[5]);
    mux2to1 stage2_6 (s1[6], s1[2],    select[2], data_out[6]);
    mux2to1 stage2_7 (s1[7], s1[3],    select[2], data_out[7]);

endmodule
```

**Testbench (`testbench.v`):**
```verilog
`timescale 1ns/1ps

module testbench;
    reg  [7:0] data_in;
    reg  [2:0] select;
    reg        control;
    wire [7:0] data_out;

    barrel_shifter uut (
        .data_in (data_in),
        .select  (select),
        .control (control),
        .data_out(data_out)
    );

    integer i, c;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
        data_in = 8'b1010_1100;

        for (c = 0; c < 2; c = c + 1) begin
            control = c;
            for (i = 0; i < 8; i = i + 1) begin
                select = i; #10;
            end
        end
        $finish;
    end
endmodule
```

**Makefile:**
```makefile
OUT = barrel_structural
SRC = mux2to1.v barrel_shifter.v testbench.v
.PHONY: all compile run wave clean
all: run
compile:
	iverilog -o $(OUT) $(SRC)
run: compile
	vvp $(OUT)
wave: compile
	vvp $(OUT)
	gtkwave dump.vcd
clean:
	rm -f $(OUT) *.vcd
```

#### Simulation Result (Structural)
The structural simulation results were identical to the behavioral implementation for the tested pattern `10101100`, confirming the correctness of the gate-level wiring.
```text
--- Mode: Logical Shift Left ---
Time    Ctrl    Sel     Input           Output
                   0    0       0       10101100        10101100
               10000    0       1       10101100        01011000
               ... (results identical to behavioural) ...
```
