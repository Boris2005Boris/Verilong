# Experiment 4 Report

## 1 Problem Statement

### 1.1 Objective
*   Design a circuit that takes an 8-bit moving binary input (string of bits) and determines if the current aggregate 8-bit value is divisible by 3.
*   The output should be '1' if the 8-bit number is divisible by 3, and '0' otherwise.
*   The design should utilize a shift register to maintain the "moving" 8-bit window of bits.

## 2 Procedure

### 2.1 Divisibility by 3 Logic
A binary number $N$ is divisible by 3 if the alternating sum of its bits is divisible by 3. Specifically, if $S_{even}$ is the sum of bits at even positions ($2^0, 2^2, \dots$) and $S_{odd}$ is the sum of bits at odd positions ($2^1, 2^3, \dots$), then:
$$N \equiv (S_{even} - S_{odd}) \pmod 3$$
If $S_{even} \equiv S_{odd} \pmod 3$, then $N$ is divisible by 3.

In this implementation, we use the Verilog modulo operator `%` for the combinational check, which the synthesizer translates into efficient gate-level logic for small divisors like 3.

### 2.2 Moving Number Implementation
To handle a "moving" number, a **Shift Register** is employed. 
1.  On every clock cycle, a new bit (`serial_in`) is shifted into the LSB (Least Significant Bit) position.
2.  The existing bits are shifted to the left, and the previous MSB (Most Significant Bit) is discarded.
3.  The 8-bit wide output of the shift register is fed into the combinational logic that checks for divisibility by 3.
4.  A `reset` signal is provided to initialize the shift register to zero.

## 3 Codes and Results

### 3.1 Source Code - `exp4/divisibility_by_3/divisible_by_3.v`

```verilog
module divisible_by_3 (
    input  wire       clk,
    input  wire       reset,
    input  wire       serial_in,
    output reg  [7:0] shift_reg,
    output wire       is_divisible
);

    // Shift register to store the "moving" 8-bit number
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 8'b0;
        end else begin
            // Shift left and insert the new serial bit at the LSB
            shift_reg <= {shift_reg[6:0], serial_in};
        end
    end

    // Combinational logic to check divisibility by 3
    assign is_divisible = (shift_reg % 3 == 0);

endmodule
```

### 3.2 Testbench - `exp4/divisibility_by_3/testbench.v`

```verilog
`timescale 1ns/1ps

module testbench;
    reg clk;
    reg reset;
    reg serial_in;
    wire [7:0] shift_reg;
    wire is_divisible;

    divisible_by_3 uut (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .shift_reg(shift_reg),
        .is_divisible(is_divisible)
    );

    // Clock generation: 100MHz (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    integer i;
    // Example test sequence: 1101 1010 0101 1001
    reg [15:0] test_sequence = 16'b1101101001011001;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        // Reset the system
        reset = 1; serial_in = 0; #10;
        reset = 0;

        $display("Time	Bit	Shift Reg	Decimal	Divisible by 3?");
        $monitor("%t	%b	%b	%d	%b", $time, serial_in, shift_reg, shift_reg, is_divisible);

        // Shift in the test sequence bit by bit
        for (i = 15; i >= 0; i = i - 1) begin
            serial_in = test_sequence[i];
            #10;
        end

        // Additional test: Input 12 (00001100)
        serial_in = 0; #10;
        serial_in = 0; #10;
        serial_in = 0; #10;
        serial_in = 0; #10;
        serial_in = 1; #10;
        serial_in = 1; #10;
        serial_in = 0; #10;
        serial_in = 0; #10;

        $finish;
    end
endmodule
```

### 3.3 Makefile

```makefile
OUT = div3
SRC = divisible_by_3.v testbench.v
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

### 3.4 Simulation Result

The simulation shows the state of the 8-bit shift register at each clock cycle as new bits are shifted in. The `is_divisible` flag correctly identifies multiples of 3 (e.g., 0, 3, 6, 27, 54, 180, 105, 210, 165, 75, 150, 144, 33, 12).

```text
Time    Bit     Shift Reg       Decimal Divisible by 3?
               10000    1       00000000          0     1
               15000    1       00000001          1     0
               25000    1       00000011          3     1
               30000    0       00000011          3     1
               35000    0       00000110          6     1
               40000    1       00000110          6     1
               45000    1       00001101         13     0
               55000    1       00011011         27     1
               60000    0       00011011         27     1
               65000    0       00110110         54     1
               70000    1       00110110         54     1
               75000    1       01101101        109     0
               85000    0       11011010        218     0
               95000    0       10110100        180     1
              105000    1       01101001        105     1
              115000    0       11010010        210     1
              125000    1       10100101        165     1
              135000    1       01001011         75     1
              145000    0       10010110        150     1
              155000    0       00101100         44     0
              165000    1       01011001         89     0
              205000    0       10010000        144     1
              215000    1       00100001         33     1
              245000    0       00001100         12     1
```
