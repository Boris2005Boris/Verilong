module barrel_shifter (
    input  [7:0] data_in,
    input  [2:0] select,
    input        control,   // 0: Shift, 1: Rotate
    output [7:0] data_out
);

    wire [7:0] s0, s1;       // Outputs of Stage 0 and Stage 1
    wire [7:0] fill0, fill1, fill2; // Fill bits (0 or Rotated)

    // Stage 0: Shift/Rotate by 1 bit
    // If control=0: fill0 = 0. If control=1: fill0 = data_in[7]
    mux2to1 ctrl0 (1'b0, data_in[7], control, fill0[0]);
    mux2to1 stage0_0 (data_in[0], fill0[0],    select[0], s0[0]);
    mux2to1 stage0_1 (data_in[1], data_in[0],  select[0], s0[1]);
    mux2to1 stage0_2 (data_in[2], data_in[1],  select[0], s0[2]);
    mux2to1 stage0_3 (data_in[3], data_in[2],  select[0], s0[3]);
    mux2to1 stage0_4 (data_in[4], data_in[3],  select[0], s0[4]);
    mux2to1 stage0_5 (data_in[5], data_in[4],  select[0], s0[5]);
    mux2to1 stage0_6 (data_in[6], data_in[5],  select[0], s0[6]);
    mux2to1 stage0_7 (data_in[7], data_in[6],  select[0], s0[7]);

    // Stage 1: Shift/Rotate by 2 bits
    mux2to1 ctrl1_0 (1'b0, s0[6], control, fill1[0]);
    mux2to1 ctrl1_1 (1'b0, s0[7], control, fill1[1]);
    mux2to1 stage1_0 (s0[0], fill1[0], select[1], s1[0]);
    mux2to1 stage1_1 (s0[1], fill1[1], select[1], s1[1]);
    mux2to1 stage1_2 (s0[2], s0[0],    select[1], s1[2]);
    mux2to1 stage1_3 (s0[3], s0[1],    select[1], s1[3]);
    mux2to1 stage1_4 (s0[4], s0[2],    select[1], s1[4]);
    mux2to1 stage1_5 (s0[5], s0[3],    select[1], s1[5]);
    mux2to1 stage1_6 (s0[6], s0[4],    select[1], s1[6]);
    mux2to1 stage1_7 (s0[7], s0[5],    select[1], s1[7]);

    // Stage 2: Shift/Rotate by 4 bits
    mux2to1 ctrl2_0 (1'b0, s1[4], control, fill2[0]);
    mux2to1 ctrl2_1 (1'b0, s1[5], control, fill2[1]);
    mux2to1 ctrl2_2 (1'b0, s1[6], control, fill2[2]);
    mux2to1 ctrl2_3 (1'b0, s1[7], control, fill2[3]);
    mux2to1 stage2_0 (s1[0], fill2[0], select[2], data_out[0]);
    mux2to1 stage2_1 (s1[1], fill2[1], select[2], data_out[1]);
    mux2to1 stage2_2 (s1[2], fill2[2], select[2], data_out[2]);
    mux2to1 stage2_3 (s1[3], fill2[3], select[2], data_out[3]);
    mux2to1 stage2_4 (s1[4], s1[0],    select[2], data_out[4]);
    mux2to1 stage2_5 (s1[5], s1[1],    select[2], data_out[5]);
    mux2to1 stage2_6 (s1[6], s1[2],    select[2], data_out[6]);
    mux2to1 stage2_7 (s1[7], s1[3],    select[2], data_out[7]);

endmodule
