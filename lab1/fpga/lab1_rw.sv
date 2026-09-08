module lab1_rw(input logic reset,
               input logic [3:0] switches,
               output logic [2:0] leds,
               output logic [6:0] segments);
    // input switches are pull-up, hence extra NOT gates
    logic int_osc;
    logic [6:0] seg;
    logic signed [24:0] counter_blink_led;

    sevensegment_hex display(~switches, seg);
    HSOSC hf_osc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
    oscillator_vduty #(25,-25'd10000000,25'd9999999) blink_led(int_osc, ~reset, 1'b1, counter_blink_led);

    assign leds[0] = ~switches[0] ^ ~switches[1];
    assign leds[1] = ~switches[2] & ~switches[3];
    assign leds[2] = ~counter_blink_led[24]; // sign bit controls LED
    assign segments = ~seg;

endmodule
