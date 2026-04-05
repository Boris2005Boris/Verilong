Title: Experiment 4 — Moving 8-bit Divisibility-by-3 Detector using Shift Register and Combinational Logic

Author(s): 23EC30064, 23EC10030

Date: March–April 2026


1. Abstract

This report presents the design and verification of a synchronous digital circuit that tracks a moving 8‑bit window of incoming serial bits and asserts a flag when the current 8‑bit value is divisible by 3. The design comprises an 8‑bit left-shifting register updated each clock and a small piece of combinational logic that checks divisibility by 3. We implement the circuit in Verilog, simulate it using Icarus Verilog, and view waveforms in GTKWave. Simulation results confirm correct operation across representative input sequences, including several known multiples of 3.


2. Objectives

- Implement a hardware block that:
  - Accepts a serial bit stream and maintains a moving 8‑bit word using a shift register.
  - Outputs 1 when the current 8‑bit value is divisible by 3, else 0.
  - Supports synchronous operation with asynchronous reset to a known state.
- Create a self-checking testbench that exercises typical and edge-case patterns.
- Validate the design via RTL simulation and waveform inspection.


3. Theory and Design Rationale

3.1 Divisibility by 3 in Binary

For an unsigned integer N formed from 8 binary digits b7…b0, a standard property for divisibility by 3 is:

N is divisible by 3 if (Sum of even-position bits) − (Sum of odd-position bits) ≡ 0 (mod 3),
where positions are counted from the least-significant bit: even positions = {b0, b2, b4, b6}, odd positions = {b1, b3, b5, b7}.

Modern synthesizers can efficiently implement constant-modulo operations for small divisors. In our RTL, we therefore use the Verilog % operator with a constant divisor of 3; synthesis tools commonly translate this into compact combinational logic without instantiating a general divider.

3.2 Moving 8-bit Window via Shift Register

We maintain a “moving” number by shifting in the newest serial bit at every rising clock edge:

- On reset, the register clears to 0.
- On each clock, the register shifts left; the previous MSB is discarded, and the new serial bit becomes the LSB.
- The current 8‑bit content is continuously presented to the divisibility check.

This design choice provides a minimal, streaming-friendly architecture that is straightforward to time and verify.


4. Implementation Details

4.1 RTL Module

The module `divisible_by_3` exposes the following ports:
- clk (input): System clock; divisibility updates occur on its rising edge.
- reset (input): Asynchronous active-high reset to clear the shift register.
- serial_in (input): Serial bit that forms the incoming stream.
- shift_reg (output [7:0]): The current moving 8‑bit window (for visibility/debugging).
- is_divisible (output): High when `shift_reg % 3 == 0`.

Key behaviors:
- Shift register update on `posedge clk` or `posedge reset`.
- Combinational assignment computes the divisibility flag from the present register contents.

4.2 Source Code

File: Verilong/nig/verilong/exp4/divisibility_by_3/divisible_by_3.v

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
            shift_reg <= {shift_reg[6:0], serial_in};
        end
    end

    // Combinational logic to check divisibility by 3
    assign is_divisible = (shift_reg % 3 == 0);

endmodule
```

4.3 Testbench

The testbench drives a 100 MHz clock (10 ns period), performs an initial reset, then shifts in a 16-bit test sequence `16'b1101101001011001`. It also appends an explicit pattern that generates decimal 12 (00001100), which is divisible by 3, to demonstrate correctness on a known multiple.

File: Verilong/nig/verilong/exp4/divisibility_by_3/testbench.v

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

        $display("Time\tBit\tShift Reg\tDecimal\tDivisible by 3?");
        $monitor("%t\t%b\t%b\t%d\t%b", $time, serial_in, shift_reg, shift_reg, is_divisible);

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

4.4 Build and Run

We use Icarus Verilog (iverilog) to compile, then vvp to run, and GTKWave for viewing waveforms. A minimal `Makefile` automates these steps:

File: Verilong/nig/verilong/exp4/divisibility_by_3/Makefile

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


5. Verification and Results

5.1 Console Trace Excerpt

An excerpt of the console output (columns: time, incoming bit, current shift register, decimal value, divisibility flag):

```
Time    Bit     Shift Reg       Decimal Divisible by 3?
15000   1       00000001              1     0
25000   1       00000011              3     1
35000   0       00000110              6     1
55000   1       00011011             27     1
65000   0       00110110             54     1
95000   0       10110100            180     1
105000  1       01101001            105     1
115000  0       11010010            210     1
125000  1       10100101            165     1
135000  1       01001011             75     1
145000  0       10010110            150     1
245000  0       00001100             12     1
```

These entries include a representative set of multiples of 3 (3, 6, 27, 54, 180, 105, 210, 165, 75, 150, 12), demonstrating that the `is_divisible` flag is asserted correctly.

5.2 Waveforms

The simulation produces a `dump.vcd` that can be inspected with GTKWave. Key observations in the waveform:
- On reset, `shift_reg` initializes to 0 and `is_divisible` is 1 (0 is divisible by 3).
- At each clock, the window advances as the incoming bit is appended to the LSB.
- `is_divisible` updates purely from the instantaneous `shift_reg` value and consistently flags known multiples of 3.


6. Discussion

- Correctness: The design behaves as intended; both sampled console output and waveform traces confirm correct identification of divisible-by-3 values across typical and targeted sequences.
- Synthesizability: The `% 3` operation over an 8‑bit vector is commonly optimized by synthesizers to a compact combinational network. For larger bit-widths or different divisors, a dedicated modulo-3 state machine or residue-tracking approach may be preferred to control area and timing.
- Latency and Throughput: The solution is fully pipelined at one sample per clock, with flag updates available in the same cycle as the shifted data due to simple combinational logic.
- Reset Strategy: Asynchronous active-high reset ensures deterministic startup. This matches standard synchronous design practices and simplifies testbenching.


7. Conclusion

We implemented and verified a hardware block that tracks a moving 8‑bit serial window and asserts a flag when the current value is divisible by 3. The design was validated using Icarus Verilog and GTKWave. Results show correct detection for representative and known-multiple inputs. The approach offers a compact, streaming-friendly solution appropriate for small-width modulo checks.


8. Tools and Environment

- HDL and Simulation: Verilog (Icarus Verilog v13.x), VVP runtime.
- Waveform Viewer: GTKWave.
- Host: Linux (kernel 4.18).


9. References

- Digital design texts on divisibility rules and residue arithmetic.
- Icarus Verilog and GTKWave user documentation.


Appendix A — Build Artifacts

- Executable: Verilong/nig/verilong/exp4/divisibility_by_3/div3 (VVP output)
- Waveform: Verilong/nig/verilong/exp4/divisibility_by_3/dump.vcd


Appendix B — Full Simulation Log (Truncated)

See the console output within the testbench run (Makefile target `run`) for the complete trace. The excerpt in Section 5.1 captures the key correctness points without the full verbosity of the log.

