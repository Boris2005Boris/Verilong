`timescale 1ns/1ps

module clock_gen_tb;
    reg clk;

    // Requirement: Initialize to 0 at t=0
    initial begin
        clk = 0;
        
        // Setup dumping for waveforms
        $dumpfile("dump.vcd");
        $dumpvars(0, clock_gen_tb);

        // Display clock transitions for 3 periods (180ns)
        $display("Time	Clock Value");
        $monitor("%t	%b", $time, clk);

        // Run for 3 full periods (3 * 60ns)
        #180 $finish;
    end

    // Requirement: Time period = 60ns, Duty cycle = 25%
    // 25% of 60ns is 15ns (High time)
    // 75% of 60ns is 45ns (Low time)
    always begin
        #45 clk = 1;  // Wait for Low time
        #15 clk = 0;  // Wait for High time
    end

endmodule
