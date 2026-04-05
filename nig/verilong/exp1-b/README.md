# Experiment 1: 4-Bit Ripple Carry Adder (Structural)

## 1. Objective
To design and implement a 4-bit Ripple Carry Adder (RCA) using structural modeling in Verilog.

## 2. Working Principle
A **Ripple Carry Adder** is a digital circuit that produces the arithmetic sum of two binary numbers. It is constructed by cascading 1-bit **Full Adders**.

### 1-Bit Full Adder Logic
- **Sum** = $A \oplus B \oplus C_{in}$
- **Carry-out** = $(A \cdot B) + (B \cdot C_{in}) + (A \cdot C_{in})$

## 3. Design Architecture
The 4-bit adder is formed by connecting four 1-bit Full Adders (FA0 to FA3). The carry "ripples" from the first stage to the last.

## 4. Code Explanation

### `full_adder.v`
```verilog
module full_adder (
    input  a, b, cin,
    output sum, cout
);
    // Sum is calculated using the XOR of all inputs
    assign sum  = a ^ b ^ cin;
    
    // Cout is high if any two or more inputs are high
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule
```

### `ripple_carry_adder_4bit.v`
```verilog
module ripple_carry_adder_4bit (
    input [3:0] A, B, input Cin,
    output [3:0] Sum, output Cout
);
    // Internal wires to carry the signal between stages
    wire c1, c2, c3;

    // Stage 0: Adds LSBs and takes the external Cin
    full_adder FA0 (.a(A[0]), .b(B[0]), .cin(Cin), .sum(Sum[0]), .cout(c1));

    // Stage 1 & 2: Take carry from previous stage as Cin
    full_adder FA1 (.a(A[1]), .b(B[1]), .cin(c1),  .sum(Sum[1]), .cout(c2));
    full_adder FA2 (.a(A[2]), .b(B[2]), .cin(c2),  .sum(Sum[2]), .cout(c3));

    // Stage 3: Adds MSBs and outputs the final Cout
    full_adder FA3 (.a(A[3]), .b(B[3]), .cin(c3),  .sum(Sum[3]), .cout(Cout));
endmodule
```

## 5. How to Run
```bash
make run   # Compile and see terminal output
make wave  # Open GTKWave to see timing diagrams
```
