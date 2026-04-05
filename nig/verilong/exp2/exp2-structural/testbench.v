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

    integer i, c;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        $display("Time\tCtrl\tSel\tInput\t\tOutput");
        $monitor("%t\t%b\t%d\t%b\t%b", $time, control, select, data_in, data_out);

        // Input pattern: 10101100
        data_in = 8'b1010_1100;

        for (c = 0; c < 2; c = c + 1) begin
            control = c;
            $display("\n--- Mode: %s ---", control ? "Rotate Left" : "Logical Shift Left");
            for (i = 0; i < 8; i = i + 1) begin
                select = i; #10;
            end
        end

        $finish;
    end

endmodule
