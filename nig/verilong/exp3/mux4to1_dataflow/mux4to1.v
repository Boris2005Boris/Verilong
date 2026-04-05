module mux4to1 (
    input  [3:0] d,
    input  [1:0] s,
    output       y
);
    // Dataflow modeling using bit-selection
    assign y = d[s];
endmodule
