# Experiment 2: 8-Bit Barrel Shifter (Behavioral)

## 1. Objective
To design and implement an 8-bit Barrel Shifter using behavioral/dataflow modeling.

## 2. Working Principle
A Barrel Shifter is a combinational circuit that shifts or rotates a data word in a single operation using $log_2(n)$ stages.

### Shift Modes
- **Logical Shift Left (LSL) - `control = 0`**: Fills empty bits with `0`.
- **Rotate Left (ROL) - `control = 1`**: Wraps the MSB bits back to the LSB side.

## 3. Code Explanation

### `barrel_shifter.v`
```verilog
module barrel_shifter (
    input  [7:0] data_in,   // 8-bit input
    input  [2:0] select,    // Shift amount (0-7)
    input        control,   // 0: Shift, 1: Rotate
    output [7:0] data_out
);
    wire [7:0] stage0, stage1;

    // Stage 0: 1-Bit Shift/Rotate
    // If select[0]=1, shift by 1. 
    // If control=0: Fill with 0 ({d[6:0], 1'b0})
    // If control=1: Fill with MSB ({d[6:0], d[7]})
    assign stage0 = select[0] ? (control ? {data_in[6:0], data_in[7]} : {data_in[6:0], 1'b0}) : data_in;

    // Stage 1: 2-Bit Shift/Rotate
    // If select[1]=1, shift by 2.
    // If control=0: Fill with 2 zeros ({s0[5:0], 2'b00})
    // If control=1: Fill with rotated bits ({s0[5:0], s0[7:6]})
    assign stage1 = select[1] ? (control ? {stage0[5:0], stage0[7:6]} : {stage0[5:0], 2'b00}) : stage0;

    // Stage 2: 4-Bit Shift/Rotate
    // Final output is shifted by 4 if select[2]=1.
    assign data_out = select[2] ? (control ? {stage1[3:0], stage1[7:4]} : {stage1[3:0], 4'b0000}) : stage1;
endmodule
```

## 4. How to Run
```bash
make run   # Compile and see terminal output
make wave  # Open GTKWave to see timing diagrams
```
