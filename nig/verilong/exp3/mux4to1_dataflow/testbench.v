`timescale 1ns/1ps

module testbench;
    reg  [3:0] d;
    reg  [1:0] s;
    wire       y;

    mux4to1 uut (
        .d(d),
        .s(s),
        .y(y)
    );

    integer i;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        $display("Time	S	D		Y");
        $monitor("%t	%b	%b	%b", $time, s, d, y);

        d = 4'b1010;
        for (i = 0; i < 4; i = i + 1) begin
            s = i; #10;
        end

        d = 4'b1100;
        for (i = 0; i < 4; i = i + 1) begin
            s = i; #10;
        end

        $finish;
    end
endmodule
