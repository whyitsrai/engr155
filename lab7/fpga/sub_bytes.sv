/////////////////////////////////////////////
// sub_bytes
//   Substitues all of the bytes the input
//   using the substitution box sbox
/////////////////////////////////////////////

module sub_bytes(input  logic clk,
                 input logic [127:0] a,
                 output logic [127:0] y);

    genvar i;
    generate
        for (i=0; i<16; i=i+1) begin: single_byte_substitution
            sbox_sync sub(.clk, 
                          .a(a[((i+1)*8)-1:i*8]),
                          .y(y[((i+1)*8)-1:i*8]));
        end
    endgenerate

endmodule
