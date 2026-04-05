module barrel_shifter (
    input  [7:0] data_in,   // 8-bit binary input
    input  [2:0] select,    // 3-bit select lines (shift amount 0-7)
    input        control,   // 1-bit control: 0 for Logical Shift Left, 1 for Rotate Left
    output [7:0] data_out
);

    wire [7:0] stage0, stage1;

    // Stage 0: Shift/Rotate by 1 bit
    // If control=0: {i6,i5,i4,i3,i2,i1,i0, 0}
    // If control=1: {i6,i5,i4,i3,i2,i1,i0, i7}
    assign stage0 = select[0] ? (control ? {data_in[6:0], data_in[7]}   : {data_in[6:0], 1'b0}) : data_in;

    // Stage 1: Shift/Rotate by 2 bits
    assign stage1 = select[1] ? (control ? {stage0[5:0], stage0[7:6]}  : {stage0[5:0], 2'b00}) : stage0;

    // Stage 2: Shift/Rotate by 4 bits
    assign data_out = select[2] ? (control ? {stage1[3:0], stage1[7:4]} : {stage1[3:0], 4'b0000}) : stage1;

endmodule
