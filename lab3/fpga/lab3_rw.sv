module lab3_rw(input logic reset,
               input logic [3:0] col,
               output logic [1:0] segment_sel,
               output logic [6:0] segment_char,
               output logic [3:0] row);
    // clk
    logic int_osc;
    HSOSC #(.CLKHF_DIV("0b00")) hf_osc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc)); // 48MHz Clock

    // keypad scanning & reading
    logic [3:0] r;
    assign row = ~r; // pull down to be on
    logic [3:0][3:0] key_status;
    logic [3:0] next_displayed_char;
    keypad_reader #(4,4, 32768, 8) keypad(int_osc, ~reset, 'b1, ~col, r, key_status); // used to be 65536
    onehot_to_bin key_decoder(key_status, next_displayed_char);

    // core logic
    logic display_next_char;
    keypress_fsm #(16) main_fsm(int_osc, ~reset, 'b1, key_status, display_next_char);

    // display driver
    logic[6:0] segchar;
    logic [1:0] segsel;
    two_digit_display display(int_osc, ~reset, 'b1, display_next_char, {1'b1, next_displayed_char}, segsel, segchar);
    assign segment_char = ~segchar; // pull down to be on
    assign segment_sel = ~segsel; // pull down to be on

endmodule
