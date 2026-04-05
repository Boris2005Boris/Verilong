module divisible_by_3 (
    input  wire       clk,
    input  wire       reset,
    input  wire       serial_in,
    output reg  [7:0] shift_reg,
    output wire       is_divisible
);

    // Shift register to store the "moving" 8-bit number
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 8'b0;
        end else begin
            shift_reg <= {shift_reg[6:0], serial_in};
        end
    end

    // Combinational logic to check divisibility by 3
    // A number N is divisible by 3 if (Sum_even_bits - Sum_odd_bits) mod 3 = 0
    // For 8 bits: (b0+b2+b4+b6) - (b1+b3+b5+b7) mod 3 = 0
    assign is_divisible = (shift_reg % 3 == 0);

endmodule
