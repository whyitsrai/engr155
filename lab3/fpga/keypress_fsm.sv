/* Rai Wandeler rwandeler@hmc.edu 2026-09-21

 This module handles all of the Lab 3 general keypress logic. Given the status of a list of keys,
 this module determines whether a new keypress has been registered and then sets the variable `display_next_char`
 HIGH.
 
 It ignores multiple keypresses until only one key is pressed, handles single keypresses as expected, and handles transitions
 into multiple keypresses through roll-off (which technically allows for the same key to be registered twice).

 This FSM used to return back to normal as soon as no keys were pressed:
 ```(onekeypressed_nodisp: if ((|key_status) == 0) state <= read_keypad;)```
 which effectively would ignore all multi-press conditions and only recognize single keypresses. This violated the Lab 3 specification
 and was therefore removed.
*/

module keypress_fsm 
    #(parameter WIDTH = 16) 
    (input logic clk, reset, enable,
     input logic [WIDTH-1:0] key_status,
     output logic display_next_char);

    logic one_key_pressed; // 1 clock cycle delay for this logic to avoid FPGA timing constraint violations & increase legibility
    always_ff @(posedge clk) begin
        if (reset) one_key_pressed <= 'b0;
        else one_key_pressed <= ((key_status != 0) && ((key_status & (key_status - 1)) == 0));
    end

    // main FSM logic for this lab
    typedef enum logic [1:0] {onekeypressed_disp, onekeypressed_nodisp, read_keypad} fsm_states;
    fsm_states state = read_keypad; // some weird shit happens in hardware
                                    // where states are not initialized properly otherwise

    always_ff @(posedge clk) begin
        if (reset) state <= read_keypad;
        else if (enable)
            case (state)
                read_keypad: if (one_key_pressed)            state <= onekeypressed_disp;
                onekeypressed_disp:                          state <= onekeypressed_nodisp;
                onekeypressed_nodisp: if (~one_key_pressed)  state <= read_keypad;
                default:                                     state <= read_keypad;
            endcase
    end

    assign display_next_char = (state == onekeypressed_disp);

endmodule