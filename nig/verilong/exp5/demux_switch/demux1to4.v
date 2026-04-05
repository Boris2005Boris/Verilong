// 1-to-2 De-MUX using Switch Level Description
module demux1to2 (
    input  wire in,
    input  wire sel,
    output wire y0,
    output wire y1
);
    wire sel_n;
    
    // CMOS Not gate at switch level (can also use 'not' gate)
    not (sel_n, sel);

    // Using nmos switches as pass transistors: nmos(output, input, control)
    // If sel=0, y0 = in. If sel=1, y1 = in.
    nmos n1 (y0, in, sel_n);
    nmos n2 (y1, in, sel);

endmodule

// 1-to-4 De-MUX hierarchical design
module demux1to4 (
    input  wire in,
    input  wire [1:0] sel,
    output wire [3:0] y
);
    wire w0, w1;

    // First stage using sel[1]
    demux1to2 d_main (
        .in (in),
        .sel(sel[1]),
        .y0 (w0),
        .y1 (w1)
    );

    // Second stage using sel[0]
    demux1to2 d_sub0 (
        .in (w0),
        .sel(sel[0]),
        .y0 (y[0]),
        .y1 (y[1])
    );

    demux1to2 d_sub1 (
        .in (w1),
        .sel(sel[0]),
        .y0 (y[2]),
        .y1 (y[3])
    );

endmodule
