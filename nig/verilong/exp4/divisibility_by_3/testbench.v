`timescale 1ns/1ps

module testbench;
    reg clk;
    reg reset;
    reg serial_in;
    wire [7:0] shift_reg;
    wire is_divisible;

    divisible_by_3 uut (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .shift_reg(shift_reg),
        .is_divisible(is_divisible)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    integer i;
    reg [15:0] test_sequence = 16'b1101101001011001;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        reset = 1; serial_in = 0; #10;
        reset = 0;

        $display("Time	Bit	Shift Reg	Decimal	Divisible by 3?");
        $monitor("%t	%b	%b	%d	%b", $time, serial_in, shift_reg, shift_reg, is_divisible);

        for (i = 15; i >= 0; i = i - 1) begin
            serial_in = test_sequence[i];
            #10;
        end

        // Additional test: Input multiple of 3
        // Let's shift in 12 (00001100)
        serial_in = 0; #10;
        serial_in = 0; #10;
        serial_in = 0; #10;
        serial_in = 0; #10;
        serial_in = 1; #10;
        serial_in = 1; #10;
        serial_in = 0; #10;
        serial_in = 0; #10;

        $finish;
    end
endmodule
