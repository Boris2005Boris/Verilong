module mux8to1 (
    input  [7:0] data,
    input  [2:0] sel,
    output       out
);
    wire m1, m2, m3, m4, m5, m6;

    // First layer: 4 muxes for the 8 data lines
    mux2to1 u1 (data[0], data[1], sel[0], m1);
    mux2to1 u2 (data[2], data[3], sel[0], m2);
    mux2to1 u3 (data[4], data[5], sel[0], m3);
    mux2to1 u4 (data[6], data[7], sel[0], m4);

    // Second layer: 2 muxes to combine the 4 inputs
    mux2to1 u5 (m1, m2, sel[1], m5);
    mux2to1 u6 (m3, m4, sel[1], m6);

    // Final layer: 1 mux to produce the final output
    mux2to1 u7 (m5, m6, sel[2], out);

endmodule
