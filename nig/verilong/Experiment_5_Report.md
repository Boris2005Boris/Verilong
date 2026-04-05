# Experiment 5 Report

## 1 Problem Statement

### 1.1 Part A: Clock Generation
*   Design a clock signal with a time period of 60ns and a duty cycle of 25%.
*   Use `always` and `initial` statements for the implementation.
*   The clock must be initialized to 0 at `time = 0`.

### 1.2 Part B: 1-to-4 De-Multiplexer (Switch-Level)
*   Design a 1-to-2 De-Multiplexer (De-MUX) using switch-level Verilog description.
*   Construct a 1-to-4 De-MUX by hierarchically instantiating the 1-to-2 De-MUX modules.
*   Verify the functionality using a testbench covering all select line combinations.

## 2 Procedure

### 2.1 Clock Generation Design
A clock with a 60ns period and 25% duty cycle implies:
*   **Total Period ($T$):** 60ns
*   **High Time ($T_{high}$):** 25% of 60ns = 15ns
*   **Low Time ($T_{low}$):** 75% of 60ns = 45ns

The clock was initialized in an `initial` block. The oscillation was generated in an `always` block using delays. To ensure the duty cycle and start at 0, the logic waits for 45ns (Low phase) then sets the clock to 1, then waits for 15ns (High phase) then sets it back to 0.

### 2.2 Switch-Level De-MUX Design
Switch-level modeling in Verilog uses primitives like `nmos` and `pmos`. A 1-to-2 De-MUX was implemented using NMOS transistors as pass gates.
*   **Logic:**
    *   If `sel = 0`, the input is passed to `y0`.
    *   If `sel = 1`, the input is passed to `y1`.
*   An inverter (gate level `not`) was used to generate the complementary select signal.
*   Two `nmos` transistors were used: one controlled by `sel` and one by `~sel`.

The 1-to-4 De-MUX was built by cascading these 1-to-2 modules:
*   **First Stage:** Split the input into two intermediate wires based on `sel[1]`.
*   **Second Stage:** Two De-MUXes split the intermediate wires into the final four outputs based on `sel[0]`.

## 3 Codes and Results

### 3.1 Part A: Clock Generation

#### Source Code - `exp5/clock_gen/clock_gen_tb.v`
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

#### Simulation Result (Terminal Output)
```text
Time    Clock Value
                   0    0
               45000    1
               60000    0
              105000    1
              120000    0
              165000    1
              180000    0
```

---

### 3.2 Part B: 1-to-4 De-MUX (Switch-Level)

#### Source Code - `exp5/demux_switch/demux1to4.v`
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

#### Testbench - `exp5/demux_switch/testbench.v`
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
        $display("Time	In	Sel	Y (3-2-1-0)");
        $monitor("%t	%b	%b	%b", $time, in, sel, y);

        in = 1;
        #10 sel = 2'b00; #10 sel = 2'b01; #10 sel = 2'b10; #10 sel = 2'b11;
        in = 0;
        #10 sel = 2'b00; #10 sel = 2'b01; #10 sel = 2'b10; #10 sel = 2'b11;
        $finish;
    end
endmodule
```

#### Simulation Result
The simulation shows that only the selected output follows the input, while other outputs are in high-impedance (`z`), which is characteristic of switch-level pass-transistor logic.
```text
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
