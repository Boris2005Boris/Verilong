`timescale 1ns/1ps

module testbench;
    reg in;
    reg [1:0] sel;
    wire [3:0] y;

    demux1to4 uut (
        .in (in),
        .sel(sel),
        .y  (y)
    );

    integer i;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        $display("Time	In	Sel	Y (3-2-1-0)");
        $monitor("%t	%b	%b	%b", $time, in, sel, y);

        // Set input to 1
        in = 1;

        // Iterate through all select lines
        for (i = 0; i < 4; i = i + 1) begin
            sel = i; #10;
        end

        // Set input to 0 and re-test
        in = 0;
        for (i = 0; i < 4; i = i + 1) begin
            sel = i; #10;
        end

        $finish;
    end
endmodule
