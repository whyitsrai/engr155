/////////////////////////////////////////////
// shift_rows
//   Performs a cyclic left shift of rows by
//   0, 1, 2, and 3 bytes per row respectively
/////////////////////////////////////////////

module shift_rows(input logic [127:0] a,
                  output logic [127:0] y);

    // row 0
    assign y[127:120] = a[127:120];
    assign y[ 95: 88] = a[ 95: 88];
    assign y[ 63: 56] = a[ 63: 56];
    assign y[ 31: 24] = a[ 31: 24];

    // row1
    assign y[119:112] = a[ 87: 80];
    assign y[ 87: 80] = a[ 55: 48];
    assign y[ 55: 48] = a[ 23: 16];
    assign y[ 23: 16] = a[119:112];

    // row2
    assign y[111:104] = a[ 47: 40];
    assign y[ 79: 72] = a[ 15:  8];
    assign y[ 47: 40] = a[111:104];
    assign y[ 15:  8] = a[ 79: 72];

    // row3
    assign y[103: 96] = a[  7:  0];
    assign y[ 71: 64] = a[103: 96];
    assign y[ 39: 32] = a[ 71: 64];
    assign y[  7:  0] = a[ 39: 32];

endmodule
