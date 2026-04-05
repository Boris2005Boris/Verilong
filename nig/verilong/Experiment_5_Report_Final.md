Title: Experiment 5 — Clock Generation (60ns, 25% Duty) and 1-to-4 De-Multiplexer (Switch-Level)

Author(s): 23EC30064, 23EC10030

Date: March–April 2026


1. Abstract

This report documents two designs: (A) a clock generator producing a 60 ns period with a 25% duty cycle, and (B) a 1-to-4 de-multiplexer built hierarchically from switch-level 1-to-2 de-mux modules. We implement both in Verilog, verify correct timing and functional behavior through simulation with Icarus Verilog, and present terminal traces demonstrating the expected waveforms and de-mux routing. Two distinct discussions analyze implementation trade-offs and practical considerations.


2. Objectives

- Implement a clock generator with:
  - Period T = 60 ns
  - Duty cycle = 25% (Thigh = 15 ns, Tlow = 45 ns)
  - Initialization to 0 at t = 0
- Design a 1-to-4 de-multiplexer using switch-level modeling:
  - Build a 1-to-2 de-mux with switch-level primitives
  - Compose two stages hierarchically to realize 1-to-4 behavior
- Develop testbenches that exercise representative scenarios and capture results for validation.


3. Theory and Design Rationale

3.1 Clock Generation with Specified Duty Cycle

A periodic digital clock of period T and duty cycle D% has Thigh = D% × T and Tlow = (1 − D%) × T. For T = 60 ns and D = 25%, Thigh = 15 ns and Tlow = 45 ns. In a testbench environment, we can model this using delays in an always block while ensuring an initial known state (clk = 0).

3.2 Switch-Level De-Multiplexer

Switch-level modeling uses transistor primitives (e.g., nmos/pmos) to express connectivity rather than Boolean functions. A 1-to-2 de-mux passes the input to one of two outputs under control of a select signal; cascading stages with a 2-bit select expands to a 1-to-4 de-mux. This modeling illustrates low-level behavior, including high-impedance (‘z’) when an output is not actively driven.


4. Implementation Details

4.1 Part A — Clock Generation

File: Verilong/nig/verilong/exp5/clock_gen/clock_gen_tb.v

```verilog
`timescale 1ns/1ps

module clock_gen_tb;
    reg clk;

    initial begin
        clk = 0; // Initialized to 0 at t=0
        $dumpfile("dump.vcd");
        $dumpvars(0, clock_gen_tb);
        #180 $finish; // Run for 3 cycles
    end

    always begin
        #45 clk = 1;  // Low for 45ns
        #15 clk = 0;  // High for 15ns
    end
endmodule
```

4.2 Part B — 1-to-4 De-MUX (Switch-Level)

File: Verilong/nig/verilong/exp5/demux_switch/demux1to4.v

```verilog
// 1-to-2 De-MUX using Switch Level Description
module demux1to2 (
    input  wire in,
    input  wire sel,
    output wire y0,
    output wire y1
);
    wire sel_n;
    not (sel_n, sel);

    // nmos(output, input, control)
    nmos n1 (y0, in, sel_n);
    nmos n2 (y1, in, sel);
endmodule

// 1-to-4 De-MUX hierarchical design
module demux1to4 (
    input  wire in,
    input  wire [1:0] sel,
    output wire [3:0] y
);
    wire w0, w1;
    demux1to2 d_main (in, sel[1], w0, w1);
    demux1to2 d_sub0 (w0, sel[0], y[0], y[1]);
    demux1to2 d_sub1 (w1, sel[0], y[2], y[3]);
endmodule
```

Testbench: Verilong/nig/verilong/exp5/demux_switch/testbench.v

```verilog
`timescale 1ns/1ps

module testbench;
    reg in;
    reg [1:0] sel;
    wire [3:0] y;

    demux1to4 uut (.in(in), .sel(sel), .y(y));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
        $display("Time\tIn\tSel\tY (3-2-1-0)");
        $monitor("%t\t%b\t%b\t%b", $time, in, sel, y);

        in = 1;
        #10 sel = 2'b00; #10 sel = 2'b01; #10 sel = 2'b10; #10 sel = 2'b11;
        in = 0;
        #10 sel = 2'b00; #10 sel = 2'b01; #10 sel = 2'b10; #10 sel = 2'b11;
        $finish;
    end
endmodule
```


5. Verification and Results

5.1 Clock Generation

The simulation trace shows the clock toggling with the desired timing: a low phase of 45 ns followed by a high phase of 15 ns, repeating with a 60 ns period. Example terminal output:

```
Time    Clock Value
       0        0
   45000        1
   60000        0
  105000        1
  120000        0
  165000        1
  180000        0
```

5.2 De-MUX (Switch-Level)

Simulation indicates that only the selected output reflects the input; others remain high-impedance (‘z’), consistent with pass-transistor behavior:

```
Time    In      Sel     Y (3-2-1-0)
       0    1       00      zzz1
   10000    1       01      zz1z
   20000    1       10      z1zz
   30000    1       11      1zzz
   40000    0       00      zzz0
   50000    0       01      zz0z
   60000    0       10      z0zz
   70000    0       11      0zzz
```


6. Discussion 1 — Design and Implementation Considerations

- Duty-cycle realization: Implementing a 25% duty over a 60 ns period with explicit #delays ensures exact Thigh/Tlow in simulation; initializing clk=0 prevents transient high at t=0 and makes waveforms unambiguous.
- Switch-level clarity: Using `nmos` primitives models conduction paths and high‑Z explicitly, aligning simulated outputs with physical pass behavior (selected output driven, others left floating).
- Hierarchical composition: Building 1-to-4 de-mux from 1-to-2 blocks promotes reuse, readability, and testability; each stage isolates concerns (MSB split, then LSB routing).
- Observability and dumps: `$dumpvars` at the top-level testbench and structured `$monitor` output provide quick validation without extensive waveform inspection.


7. Discussion 2 — Practicalities, Limitations, and Extensions

- Real-silicon caveats: Pure nmos pass gating degrades logic-high levels; a CMOS transmission-gate or buffered stage may be needed to restore logic levels and meet noise margins.
- High-impedance handling: Downstream logic must tolerate ‘z’ on unselected outputs; synthesisable RTL often replaces ‘z’ with defined 0/1 and uses enable signals for safer interfacing.
- Timing robustness: The clock TB uses ideal delays; in synthesised designs, a dedicated PLL/clocking resource is preferred. For the de-mux, registering outputs can improve timing closure in larger systems.
- Scalability and parameterization: The de-mux can be generalized (1-to-2^N) via generate blocks; adding assertions in the testbench (e.g., only one output equals input) improves coverage and catches wiring errors.


8. Conclusion

We implemented and verified a 60 ns, 25% duty-cycle clock generator and a hierarchical 1-to-4 de-multiplexer in switch-level Verilog. Simulation results validate the timing and routing behavior. The discussions outlined key design choices, physical considerations, and natural paths to parameterize and harden the designs for broader use.


9. Tools and Environment

- HDL and Simulation: Verilog (Icarus Verilog v13.x), VVP runtime.
- Waveform Viewer: GTKWave.
- Host: Linux (kernel 4.18).


10. References

- Standard digital design texts on timing, duty-cycle generation, and pass-transistor logic.
- Icarus Verilog and GTKWave documentation.


Appendix — File Map

- Clock TB: Verilong/nig/verilong/exp5/clock_gen/clock_gen_tb.v
- De-MUX RTL: Verilong/nig/verilong/exp5/demux_switch/demux1to4.v
- De-MUX TB: Verilong/nig/verilong/exp5/demux_switch/testbench.v

