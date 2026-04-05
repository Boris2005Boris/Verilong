// Propagate and Generate unit
module pg_unit (
    input  wire a, b,
    output wire p, g
);
    assign p = a ^ b;
    assign g = a & b;
endmodule

// Carry Lookahead Logic (CLL) block
module cla_block (
    input  wire [3:0] p, g,
    input  wire cin,
    output wire [4:1] c
);
    assign c[1] = g[0] | (p[0] & cin);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & cin);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & cin);
endmodule

// Sum unit
module sum_unit (
    input  wire p, c,
    output wire sum
);
    assign sum = p ^ c;
endmodule

// Top level structural 4-bit CLA
module adder_4bit_cla (
    input  wire [3:0] A, B,
    input  wire Cin,
    output wire [3:0] Sum,
    output wire Cout
);
    wire [3:0] P, G;
    wire [4:0] C;
    
    assign C[0] = Cin;

    // Instantiate PG units for each bit
    pg_unit pg0 (A[0], B[0], P[0], G[0]);
    pg_unit pg1 (A[1], B[1], P[1], G[1]);
    pg_unit pg2 (A[2], B[2], P[2], G[2]);
    pg_unit pg3 (A[3], B[3], P[3], G[3]);

    // Instantiate the CLA logic block
    cla_block cll (P, G, C[0], C[4:1]);

    // Instantiate Sum units for each bit
    sum_unit s0 (P[0], C[0], Sum[0]);
    sum_unit s1 (P[1], C[1], Sum[1]);
    sum_unit s2 (P[2], C[2], Sum[2]);
    sum_unit s3 (P[3], C[3], Sum[3]);

    assign Cout = C[4];

endmodule
