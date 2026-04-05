# Experiment 3 Report

## 1 Problem Statement

### 1.1 Part A: 4x1 Multiplexer Design
*   Design a 4x1 Multiplexer (MUX) using dataflow modeling in Verilog.
*   Verify the functionality using a testbench by iterating through all select line combinations.

### 1.2 Part B: 4-bit Adder Design
*   **Obj-2(a):** Implement a 4-bit Adder using dataflow modeling and the concatenation operator.
*   **Obj-2(b):** Implement a 4-bit Adder using Carry-lookahead adder (CLA) topology (Dataflow and Structural).
*   Verify all implementations using testbenches covering zero, random, and overflow cases.

## 2 Procedure

### 2.1 4x1 Multiplexer Design
A 4x1 Multiplexer selects one of four input lines (`d[3:0]`) based on a 2-bit select signal (`s[1:0]`). 
The design was implemented using **Dataflow modeling**: `assign y = d[s]`.

### 2.2 4-Bit Adder (Dataflow with Concatenation)
This implementation leverages high-level Verilog operators: `{Cout, Sum} = A + B + Cin`.

### 2.3 4-Bit Carry-lookahead Adder (CLA)
The CLA logic improves speed by calculating carries in parallel using Generate ($G_i$) and Propagate ($P_i$) functions. 
*   **Dataflow Approach:** Uses `assign` statements for the entire logic.
*   **Structural Approach:** Breaks the design into hierarchical modules:
    *   `pg_unit`: Computes $P$ and $G$ for each bit.
    *   `cla_block`: Implements the carry lookahead equations.
    *   `sum_unit`: Computes the final sum bit.
    *   `top_module`: Instantiates these units to form the complete 4-bit CLA.

## 3 Codes and Results

### 3.1 4x1 Multiplexer (Dataflow)
(Source and results as previously documented)

### 3.2 4-Bit Adder (Dataflow & Concatenation)
(Source and results as previously documented)

### 3.3 4-Bit Carry-lookahead Adder (Dataflow)
(Source as previously documented)

### 3.4 4-Bit Carry-lookahead Adder (Structural)

#### Source Code - `exp3/adder_4bit_cla_structural/adder_4bit_cla.v`
```verilog
// Propagate and Generate unit
module pg_unit (input wire a, b, output wire p, g);
    assign p = a ^ b;
    assign g = a & b;
endmodule

// Carry Lookahead Logic (CLL) block
module cla_block (input wire [3:0] p, g, input wire cin, output wire [4:1] c);
    assign c[1] = g[0] | (p[0] & cin);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & cin);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & cin);
endmodule

// Sum unit
module sum_unit (input wire p, c, output wire sum);
    assign sum = p ^ c;
endmodule

// Top level structural 4-bit CLA
module adder_4bit_cla (
    input  wire [3:0] A, B,
    input  wire Cin,
    output wire [3:0] Sum,
    output wire Cout
);
    wire [3:0] P, G;
    wire [4:0] C;
    assign C[0] = Cin;

    pg_unit pg0 (A[0], B[0], P[0], G[0]);
    pg_unit pg1 (A[1], B[1], P[1], G[1]);
    pg_unit pg2 (A[2], B[2], P[2], G[2]);
    pg_unit pg3 (A[3], B[3], P[3], G[3]);

    cla_block cll (P, G, C[0], C[4:1]);

    sum_unit s0 (P[0], C[0], Sum[0]);
    sum_unit s1 (P[1], C[1], Sum[1]);
    sum_unit s2 (P[2], C[2], Sum[2]);
    sum_unit s3 (P[3], C[3], Sum[3]);

    assign Cout = C[4];
endmodule
```

#### Simulation Result
The structural CLA results are functionally identical to the dataflow implementation, verifying the hierarchical wiring.
```text
Time    A       B       Cin     Sum     Cout
                   0    0000    0000    0       0000    0
               10000    0001    0001    0       0010    0
               20000    0111    0001    0       1000    0
               30000    1111    1111    0       1110    1
               40000    1010    0101    1       0000    1
```
