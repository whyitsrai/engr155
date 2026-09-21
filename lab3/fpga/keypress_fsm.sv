/* Rai Wandeler rwandeler@hmc.edu 2026-09-21

the fsm used to have this logic (no keys pressed), but it does not adhere to the spec:
onekeypressed_nodisp: if ((|key_status) == 0)                                 state <= read_keypad;
kept here for historical reasons
*/

module keypress_fsm 
    #(parameter WIDTH = 16) 
    (input logic clk, reset, enable,
     input logic [WIDTH-1:0] key_status,
     output logic display_next_char);

    logic one_key_pressed; // 1 clock cycle delay for this logic to avoid timing violations & increase legibility
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