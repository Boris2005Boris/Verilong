`timescale 1ns/1ps

module testbench;

    reg  [3:0] A, B;
    reg        Cin;
    wire [3:0] Sum;
    wire       Cout;

    // Instantiate the Unit Under Test (UUT)
    ripple_carry_adder_4bit uut (
        .A   (A),
        .B   (B),
        .Cin (Cin),
        .Sum (Sum),
        .Cout(Cout)
    );

    initial begin
        // Setup waveform dumping
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        // Display header
        $display("Time\tA\tB\tCin\tSum\tCout");
        $monitor("%t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

        // Test Cases
        A = 4'b0000; B = 4'b0000; Cin = 0; #10;
        A = 4'b0001; B = 4'b0001; Cin = 0; #10;
        A = 4'b0111; B = 4'b0001; Cin = 0; #10;
        A = 4'b1111; B = 4'b1111; Cin = 0; #10;
        A = 4'b1010; B = 4'b0101; Cin = 1; #10;
        A = 4'b1100; B = 4'b0011; Cin = 0; #10;

        $finish;
    end

endmodule


