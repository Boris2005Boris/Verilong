`timescale 1ns/1ps

module testbench;
    reg  [3:0] A, B;
    reg        Cin;
    wire [3:0] Sum;
    wire       Cout;

    adder_4bit uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        $display("Time	A	B	Cin	Sum	Cout");
        $monitor("%t	%b	%b	%b	%b	%b", $time, A, B, Cin, Sum, Cout);

        A = 4'b0000; B = 4'b0000; Cin = 0; #10;
        A = 4'b0001; B = 4'b0001; Cin = 0; #10;
        A = 4'b0111; B = 4'b0001; Cin = 0; #10;
        A = 4'b1111; B = 4'b1111; Cin = 0; #10;
        A = 4'b1010; B = 4'b0101; Cin = 1; #10;

        $finish;
    end
endmodule
