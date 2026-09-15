module lab2_rw(input logic reset,
               input logic [3:0] sw1, sw2,
               input logic [3:0] col,
               output logic [3:0] leds,
               output logic [1:0] segment_sel, // normally HIGH
               output logic [6:0] segment_char,
               output logic [3:0] row);
    // input switches are pull-up, hence extra NOT gates
    logic int_osc;
    HSOSC hf_osc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    logic [18:0] seg_mux_count;
    counter #(19,19'd479999) seg_mux(int_osc, ~reset, 1'b1, seg_mux_count);

    logic[3:0] sw_cur;
    logic[6:0] seg;

    // else statement should never trigger
    assign segment_sel = (seg_mux_count < 240000) ? 2'b10 : (seg_mux_count < 480000) ? 2'b01 : 2'b11;
    assign sw_cur = (seg_mux_count < 240000) ? sw1 : (seg_mux_count < 480000) ? sw2 : sw1;

    sevensegment_hex display(~sw_cur, seg);

    assign segment_char = ~seg; // pull down to be on
    assign leds = ~col; // pull down to be on

    logic [3:0] r;
    keypad_matrix_scan #(4,2) keypad(int_osc, ~reset, 1'b1, r);
    assign row = ~r; // pull down to be own

endmodule
