module mux2to1 (
    input  a, b, sel,
    output out
);
    wire not_sel, and_a, and_b;

    // Gate-level implementation (Structural)
    not (not_sel, sel);
    and (and_a, a, not_sel);
    and (and_b, b, sel);
    or  (out, and_a, and_b);

endmodule
