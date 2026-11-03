/////////////////////////////////////////////
// round_key_gen
//   Generates the subsequent round key (4 words)
//   given the previous round key value and the
//   corresponding 4 words of the rcon table to
//   be added to this round
/////////////////////////////////////////////

module round_key_gen(input  logic clk,
                     input logic [127:0] round_key_prev,
                     input logic [7:0] rcon, // only applied to first byte
                     output logic [127:0] round_key_next);

    logic [31:0] rkey0_rot, rkey0_sub;
    assign rkey0_rot = round_key_prev[31:0] << 8 | round_key_prev[31:24];
    sbox_sync sub0(.clk, .a(rkey0_rot[31:24]), .y(rkey0_sub[31:24]));
    sbox_sync sub1(.clk, .a(rkey0_rot[23:16]), .y(rkey0_sub[23:16]));
    sbox_sync sub2(.clk, .a(rkey0_rot[15: 8]), .y(rkey0_sub[15: 8]));
    sbox_sync sub3(.clk, .a(rkey0_rot[ 7: 0]), .y(rkey0_sub[ 7: 0]));

    always_ff @(posedge clk) begin
        round_key_next[127:96] <= round_key_prev[127:96] ^ rkey0_sub ^ {rcon, 24'b0};
        round_key_next[95 :64] <= round_key_prev[95 :64] ^ round_key_next[127:96];
        round_key_next[63 :32] <= round_key_prev[63 :32] ^ round_key_next[95 :64];
        round_key_next[31 : 0] <= round_key_prev[31 : 0] ^ round_key_next[63 :32];
    end

endmodule
