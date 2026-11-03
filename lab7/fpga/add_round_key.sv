/////////////////////////////////////////////
// add_round_key
//   Adds round key to input in 8-bit galoid field
/////////////////////////////////////////////

module add_round_key(input logic [127:0] a, round_key,
                     output logic [127:0] y);

    assign y[127:96] = a[127:96] ^ round_key[127:96];
    assign y[ 95:64] = a[ 95:64] ^ round_key[ 95:64];
    assign y[ 63:32] = a[ 63:32] ^ round_key[ 63:32];
    assign y[ 31: 0] = a[ 31: 0] ^ round_key[ 31: 0];

endmodule

