module mux2to1 (
    input  a, b, sel,
    output out
);
    // Behavioral logic using ternary operator
    assign out = sel ? b : a;
endmodule
