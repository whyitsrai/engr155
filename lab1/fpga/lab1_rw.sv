module lab1_rw(input logic reset,
               input logic [3:0] switches,
               output logic [2:0] leds,
               output logic [6:0] segments);

    logic int_osc;
    logic [6:0] seg;
    logic [31:0] counter_blink_led;

    sevensegment_hex display(switches, seg);
    HSOSC hf_osc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
    counter_pn #(32,32'd429) blink_led(int_osc, reset, 1'b1, counter_blink_led);

    assign leds[0] = switches[0] ^ switches[1];
    assign leds[1] = switches[2] & switches[3];
    assign leds[2] = counter_blink_led[31];
    assign segments = ~seg;

endmodule
