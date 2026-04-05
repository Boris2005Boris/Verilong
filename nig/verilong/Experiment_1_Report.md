# Experiment 1 Report

## 1 Problem Statement

### 1.1 Part A: Multiplexer Design
*   Design a 2:1 Multiplexer (MUX) using both structural and behavioral modeling formats.
*   Build an 8:1 MUX utilizing the 2:1 MUX modules designed in the previous step.
*   Verify the functionality of the multiplexer designs using a Testbench (TB).

### 1.2 Part B: Adder Implementation
*   Implement a 4-bit Ripple Carry Adder (RCA) by instantiating four 1-bit Full Adders.
*   Demonstrate and verify the correct output of the adder using testbench waveforms.

## 2 Procedure

### 2.1 Multiplexer (MUX) Design
A 2:1 Multiplexer was first implemented using behavioral modeling. The module consists of a single select line (sel), two inputs (a, b), and a single output. The functionality was described using a ternary operator: `out = sel ? b : a`.

Next, the same 2:1 Multiplexer was implemented using structural modeling. Basic logic gates (NOT, AND, OR) were instantiated to realize the equation: `out = (a · ~sel) + (b · sel)`.

An 8:1 Multiplexer was then designed using hierarchical modeling by instantiating seven 2:1 MUX modules. The design was implemented in three stages:
*   **Stage 1:** Four 2:1 MUXes select between pairs of inputs (data[1:0], data[3:2], data[5:4], data[7:6]) using `sel[0]`.
*   **Stage 2:** Two 2:1 MUXes select between intermediate outputs using `sel[1]`.
*   **Stage 3:** One final 2:1 MUX selects the output using `sel[2]`.

A behavioral version of the 8:1 MUX was also implemented using a `case` statement inside an `always` block, where the output directly maps to `data[sel]` for all select combinations.

The functionality of both structural and behavioral 8:1 MUX designs was verified using a testbench by applying different input patterns and iterating through all possible select values.

### 2.2 4-Bit Ripple Carry Adder (RCA) Design
A 1-bit Full Adder module was designed with inputs `a`, `b`, and `cin` (carry-in), and outputs `sum` and `cout` (carry-out). The logic was implemented using:
*   `sum = a ⊕ b ⊕ cin`
*   `cout = (a · b) + (b · cin) + (a · cin)`

Using this module, a 4-bit Ripple Carry Adder was constructed by instantiating four Full Adders. Two 4-bit input vectors (`A` and `B`) and an input carry (`Cin`) were defined, along with a 4-bit sum output and a final carry output.

The design connects the carry-out of each Full Adder to the carry-in of the next stage using intermediate wires, forming a ripple carry chain from the least significant bit to the most significant bit.

The RCA was verified using a testbench by applying multiple input combinations, including zero inputs, random values, carry propagation cases, and overflow conditions, and observing the resulting sum and carry outputs.

## 3 Codes and Results

### 3.1 Part A: Multiplexer (Behavioural Modeling)

#### Source Codes - `exp1-a/behavioural/`
**2:1 MUX (`mux2to1.v`):**
```verilog
module mux2to1 (
    input  a, b, sel,
    output out
);
    // Behavioral logic using ternary operator
    assign out = sel ? b : a;
endmodule
```

**8:1 MUX (`mux8to1.v`):**
```verilog
module mux8to1 (
    input  [7:0] data,
    input  [2:0] sel,
    output reg   out
);
    // Behavioral logic using a case block
    always @(*) begin
        case (sel)
            3'b000: out = data[0];
            3'b001: out = data[1];
            3'b010: out = data[2];
            3'b011: out = data[3];
            3'b100: out = data[4];
            3'b101: out = data[5];
            3'b110: out = data[6];
            3'b111: out = data[7];
            default: out = 1'b0;
        endcase
    end
endmodule
```

**Testbench (`testbench.v`):**
```verilog
`timescale 1ns/1ps

module testbench;
    reg  [7:0] data;
    reg  [2:0] sel;
    wire       out;

    mux8to1 uut (
        .data(data),
        .sel (sel),
        .out (out)
    );

    integer i;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
        $display("Time	Sel	Data		Out");
        $monitor("%t	%d	%b	%b", $time, sel, data, out);

        data = 8'b10101010;
        for (i = 0; i < 8; i = i + 1) begin
            sel = i; #10;
        end

        data = 8'b11001100;
        for (i = 0; i < 8; i = i + 1) begin
            sel = i; #10;
        end
        $finish;
    end
endmodule
```

**Makefile:**
```makefile
OUT = mux_beh
SRC = mux2to1.v mux8to1.v testbench.v
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

#### Simulation Result (Behavioural)
```text
Time    Sel     Data            Out
                   0    0       10101010        0
               10000    1       10101010        1
               20000    2       10101010        0
               30000    3       10101010        1
               40000    4       10101010        0
               50000    5       10101010        1
               60000    6       10101010        0
               70000    7       10101010        1
               80000    0       11001100        0
               90000    1       11001100        0
              100000    2       11001100        1
              110000    3       11001100        1
              120000    4       11001100        0
              130000    5       11001100        0
              140000    6       11001100        1
              150000    7       11001100        1
```

---

### 3.2 Part A: Multiplexer (Structural Modeling)

#### Source Codes - `exp1-a/structural/`
**2:1 MUX (`mux2to1.v`):**
```verilog
module mux2to1 (
    input  a, b, sel,
    output out
);
    wire not_sel, and_a, and_b;
    not (not_sel, sel);
    and (and_a, a, not_sel);
    and (and_b, b, sel);
    or  (out, and_a, and_b);
endmodule
```

**8:1 MUX (`mux8to1.v`):**
```verilog
module mux8to1 (
    input  [7:0] data,
    input  [2:0] sel,
    output       out
);
    wire m1, m2, m3, m4, m5, m6;
    mux2to1 u1 (data[0], data[1], sel[0], m1);
    mux2to1 u2 (data[2], data[3], sel[0], m2);
    mux2to1 u3 (data[4], data[5], sel[0], m3);
    mux2to1 u4 (data[6], data[7], sel[0], m4);
    mux2to1 u5 (m1, m2, sel[1], m5);
    mux2to1 u6 (m3, m4, sel[1], m6);
    mux2to1 u7 (m5, m6, sel[2], out);
endmodule
```

**Testbench (`testbench.v`):**
The structural implementation was verified using the same testbench architecture as the behavioral design to ensure functional consistency.
```verilog
`timescale 1ns/1ps

module testbench;
    reg  [7:0] data;
    reg  [2:0] sel;
    wire       out;

    mux8to1 uut (
        .data(data),
        .sel (sel),
        .out (out)
    );

    integer i;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
        $display("Time	Sel	Data		Out");
        $monitor("%t	%d	%b	%b", $time, sel, data, out);

        data = 8'b10101010;
        for (i = 0; i < 8; i = i + 1) begin
            sel = i; #10;
        end

        data = 8'b11001100;
        for (i = 0; i < 8; i = i + 1) begin
            sel = i; #10;
        end
        $finish;
    end
endmodule
```

**Makefile:**
```makefile
OUT = mux_str
SRC = mux2to1.v mux8to1.v testbench.v
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
The results confirmed logical equivalence with the behavioral model.
```text
Time    Sel     Data            Out
                   0    0       10101010        0
               10000    1       10101010        1
               ... (results identical to behavioral implementation) ...
```

---

### 3.3 Part B: 4-Bit Ripple Carry Adder

#### Source Codes - `exp1-b/`
**1-Bit Full Adder (`full_adder.v`):**
```verilog
module full_adder (
    input  a, b, cin,
    output sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule
```

**4-Bit Ripple Carry Adder (`ripple_carry_adder_4bit.v`):**
```verilog
module ripple_carry_adder_4bit (
    input  [3:0] A, B,
    input        Cin,
    output [3:0] Sum,
    output       Cout
);
    wire c1, c2, c3;
    full_adder FA0 (.a(A[0]), .b(B[0]), .cin(Cin), .sum(Sum[0]), .cout(c1));
    full_adder FA1 (.a(A[1]), .b(B[1]), .cin(c1),  .sum(Sum[1]), .cout(c2));
    full_adder FA2 (.a(A[2]), .b(B[2]), .cin(c2),  .sum(Sum[2]), .cout(c3));
    full_adder FA3 (.a(A[3]), .b(B[3]), .cin(c3),  .sum(Sum[3]), .cout(Cout));
endmodule
```

**Testbench (`testbench.v`):**
```verilog
`timescale 1ns/1ps

module testbench;
    reg  [3:0] A, B;
    reg        Cin;
    wire [3:0] Sum;
    wire       Cout;

    ripple_carry_adder_4bit uut (
        .A(A), .B(B), .Cin(Cin), .Sum(Sum), .Cout(Cout)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
        $display("Time	A	B	Cin	Sum	Cout");
        $monitor("%t	%b	%b	%b	%b	%b", $time, A, B, Cin, Sum, Cout);

        A = 4'b0000; B = 4'b0000; Cin = 0; #10;
        A = 4'b0001; B = 4'b0001; Cin = 0; #10;
        A = 4'b0111; B = 4'b0001; Cin = 0; #10;
        A = 4'b1111; B = 4'b1111; Cin = 0; #10;
        A = 4'b1010; B = 4'b0101; Cin = 1; #10;
        A = 4'b1100; B = 4'b0011; Cin = 0; #10;
        $finish;
    end
endmodule
```

**Makefile:**
```makefile
OUT = rca
SRC = full_adder.v ripple_carry_adder_4bit.v testbench.v
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

#### Simulation Result (RCA)
```text
Time    A       B       Cin     Sum     Cout
                   0    0000    0000    0       0000    0
               10000    0001    0001    0       0010    0
               20000    0111    0001    0       1000    0
               30000    1111    1111    0       1110    1
               40000    1010    0101    1       0000    1
               50000    1100    0011    0       1111    0
```
