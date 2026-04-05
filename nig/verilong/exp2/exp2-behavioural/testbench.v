`timescale 1ns/1ps

module testbench;

    reg  [7:0] data_in;
    reg  [2:0] select;
    reg        control;
    wire [7:0] data_out;

    // Instantiate Barrel Shifter
    barrel_shifter uut (
        .data_in (data_in),
        .select  (select),
        .control (control),
        .data_out(data_out)
    );

    integer i, c, p;
    reg [7:0] patterns [0:2];

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        // Define test patterns
        patterns[0] = 8'b1010_1100; // Original pattern
        patterns[1] = 8'b1000_0000; // Single MSB bit
        patterns[2] = 8'b0101_0101; // Alternating bits

        $display("Time\tCtrl\tSel\tInput\t\tOutput");
        $monitor("%t\t%b\t%d\t%b\t%b", $time, control, select, data_in, data_out);

        for (p = 0; p < 3; p = p + 1) begin
            data_in = patterns[p];
            $display("\n=== Testing Data Pattern: %b ===", data_in);
            
            for (c = 0; c < 2; c = c + 1) begin
                control = c;
                $display("--- Mode: %s ---", control ? "Rotate Left" : "Logical Shift Left");
                for (i = 0; i < 8; i = i + 1) begin
                    select = i; #10;
                end
            end
        end

        $finish;
    end

endmodule
