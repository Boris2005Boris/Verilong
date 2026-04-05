# Experiment 2: 8-Bit Barrel Shifter (Structural)

## 1. Objective
To design and implement an 8-bit Barrel Shifter using structural modeling by connecting Multiplexers.

## 2. Working Principle
This implementation uses 2-to-1 Multiplexers (`mux2to1`) to build three stages (1, 2, and 4-bit shifts). The same logic as the behavioral version is achieved through manual wiring.

## 3. Code Explanation

### `mux2to1.v`
```verilog
module mux2to1 (
    input  a, b, sel, output out
);
    // Selects input 'b' if sel=1, otherwise 'a'
    assign out = sel ? b : a;
endmodule
```

### `barrel_shifter.v` (Key Blocks)
The design uses **Control MUXes** to decide the fill bits for each stage.

#### Stage 0: 1-Bit Shift/Rotate
```verilog
// Control MUX for Stage 0 (Shift vs Rotate)
// Determines if the bit coming from the left is 0 or data_in[7]
mux2to1 ctrl0 (1'b0, data_in[7], control, fill0[0]);

// Data MUXes for Stage 0
// If select[0]=0, passes current bit. If select[0]=1, passes previous bit.
mux2to1 stage0_0 (data_in[0], fill0[0], select[0], s0[0]);
mux2to1 stage0_1 (data_in[1], data_in[0], select[0], s0[1]);
...
```

#### Stage 1: 2-Bit Shift/Rotate
Similar to Stage 0, but connects bits from 2 positions away.
```verilog
// Control MUXes for 2 rotated bits
mux2to1 ctrl1_0 (1'b0, s0[6], control, fill1[0]);
mux2to1 ctrl1_1 (1'b0, s0[7], control, fill1[1]);

// Data MUXes for Stage 1
mux2to1 stage1_2 (s0[2], s0[0], select[1], s1[2]);
...
```

#### Stage 2: 4-Bit Shift/Rotate
Final stage connecting bits from 4 positions away.
```verilog
// Control MUXes for 4 rotated bits
mux2to1 ctrl2_0 (1'b0, s1[4], control, fill2[0]);
...
// Data MUXes for Stage 2
mux2to1 stage2_4 (s1[4], s1[0], select[2], data_out[4]);
...
```

## 4. How to Run
```bash
make run   # Compile and see terminal output
make wave  # Open GTKWave to see timing diagrams
```
