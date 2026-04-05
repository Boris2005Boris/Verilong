module mux2to1 (
    input  a,   // Input 0
    input  b,   // Input 1
    input  sel, // Select
    output out
);

    assign out = sel ? b : a;

endmodule
