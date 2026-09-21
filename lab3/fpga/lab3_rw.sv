module lab3_rw(input logic reset,
               input logic [3:0] col,
               output logic [1:0] segment_sel,
               output logic [6:0] segment_char,
               output logic [3:0] row);
    // clk
    logic int_osc;
    HSOSC #(.CLKHF_DIV("0b00")) hf_osc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc)); // 48MHz Clock

    // sevensegment mux/driving
    logic [18:0] seg_mux_count;
    counter #(19'd479999) seg_mux(int_osc, ~reset, 1'b1, seg_mux_count);
    logic[1:0][3:0] displayed_chars;
    logic [3:0] display_mux_char, next_displayed_char;
    logic[6:0] seg;
    assign segment_sel = (seg_mux_count < 240000) ? 2'b10 : (seg_mux_count < 480000) ? 2'b01 : 2'b11;
    assign display_mux_char = (seg_mux_count < 240000) ? displayed_chars[0] : (seg_mux_count < 480000) ? displayed_chars[1] : next_displayed_char;
    sevensegment_hex display(display_mux_char, seg);
    assign segment_char = ~seg; // pull down to be on

    // keypad scanning & reading
    logic [3:0] r;
    assign row = ~r; // pull down to be own
    logic [3:0][3:0] key_status;
    keypad_reader #(4,4, 32768, 8) keypad(int_osc, ~reset, 'b1, ~col, r, key_status); // used to be 65536
    onehot_to_bin key_decoder(key_status, next_displayed_char);

    logic display_next_char;
    keypress_fsm #(16) main_fsm(int_osc, ~reset, 'b1, key_status, display_next_char);

    always_ff @(posedge int_osc) begin: sevensegment_shift_reg
        if (~reset) displayed_chars <= 'b0;
        else if (display_next_char) begin
            displayed_chars[1] <= displayed_chars[0];
            displayed_chars[0] <= next_displayed_char;
        end
    end
    

endmodule
