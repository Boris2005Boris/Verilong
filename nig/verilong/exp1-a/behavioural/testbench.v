`timescale 1ns/1ps

module testbench;

    reg  [7:0] data;
    reg  [2:0] sel;
    wire       out;

    // Instantiate 8:1 MUX
    mux8to1 uut (
        .data(data),
        .sel (sel),
        .out (out)
    );

    integer i;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        $display("Time\tSel\tData\t\tOut");
        $monitor("%t\t%d\t%b\t%b", $time, sel, data, out);

        // Pattern 1: Single bit high
        data = 8'b10101010;
        for (i = 0; i < 8; i = i + 1) begin
            sel = i; #10;
        end

        // Pattern 2: Different bits
        data = 8'b11001100;
        for (i = 0; i < 8; i = i + 1) begin
            sel = i; #10;
        end

        $finish;
    end

endmodule
