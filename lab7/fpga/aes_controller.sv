/////////////////////////////////////////////
// aes_controller
//   AES encryption module control module
/////////////////////////////////////////////

module aes_controller(input  logic clk, reset,
                      output logic [7:0] rcon_cur,
                      output logic enable_sub_bytes, enable_shift_rows, enable_mix_columns, 
                      output logic  state_updated,
                      output logic  done);

    typedef enum logic [3:0] {pre_round, round1, round2, round3, round4, round5, round6, round7, round8, round9, round10, hold} fsm_state;
    fsm_state current_state, next_state;

    logic [2:0] count;
    counter #(7) sig_delay_comp(clk, state_updated | reset, current_state != hold, count);

    always_ff @(posedge clk)
        if (reset) current_state <= pre_round;
        else current_state <= next_state;

    // next state logic
    always_comb begin
        next_state = current_state;

        case (current_state) inside
            pre_round:       if (count >= 5) next_state = round1;
            [round1:round9]: if (count >= 5) next_state = current_state.next();
            round10:         if (count >= 3) next_state = hold;
        endcase
    end

    // reset counter if state is complete
    assign state_updated = current_state != next_state;

    // output logic
    always_comb begin
        enable_sub_bytes = 1'b0;
        enable_shift_rows = 1'b0;
        enable_mix_columns = 1'b0;
        done = 1'b0;

        case (current_state) inside
            [round1:round9]: {enable_sub_bytes, enable_shift_rows, enable_mix_columns} = 3'b111;
            round10:         {enable_sub_bytes, enable_shift_rows} = 2'b11;
            hold:             done = 1'b1;
        endcase
    end

    // rcon logic
    logic [7:0] rcon_next;
    galoismult rcon(rcon_cur, rcon_next);

    always_ff @(posedge clk)
        if (reset) rcon_cur <= 8'h01;
        else if (next_state >= round1 && next_state < round10 && state_updated == 1'b1) rcon_cur <= rcon_next;

endmodule

