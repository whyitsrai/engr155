/* Rai Wandeler rwandeler@hmc.edu 2026-09-20

 This module is specific to this lab (lab3) and should be used with caution outside of this context.
 The module takes in a keymap of every (row by row) singular key that is being pressed and outputs the
 appropriate binary encoding of the hexadecimal number that this key represents on the keypad.
 
 IMPORTANT: AN INPUT KEYMAP THAT DOES NOT HAVE A ONE-HOT ENCODING WILL RESULT IN UNDEFINED BEHAVIOUR!
 This is designed with a bunch of if statements in order to reduce the hardware expense (with the drawback of invalid inputs having unknowable outputs).
*/

module onehot_to_bin(input logic [15:0] keymap,
                     output logic [3:0] encoded); // binary encoding

    always_comb begin
        encoded = 'b0; // default case

        if (keymap[0] == 'b1) encoded = 'b0001;
        if (keymap[1] == 'b1) encoded = 'b0010;
        if (keymap[2] == 'b1) encoded = 'b0011;
        if (keymap[3] == 'b1) encoded = 'b1010;
        if (keymap[4] == 'b1) encoded = 'b0100;
        if (keymap[5] == 'b1) encoded = 'b0101;
        if (keymap[6] == 'b1) encoded = 'b0110;
        if (keymap[7] == 'b1) encoded = 'b1011;
        if (keymap[8] == 'b1) encoded = 'b0111;
        if (keymap[9] == 'b1) encoded = 'b1000;
        if (keymap[10] == 'b1) encoded = 'b1001;
        if (keymap[11] == 'b1) encoded = 'b1100;
        if (keymap[12] == 'b1) encoded = 'b1110;
        if (keymap[13] == 'b1) encoded = 'b0000;
        if (keymap[14] == 'b1) encoded = 'b1111;
        if (keymap[15] == 'b1) encoded = 'b1101;
    end

endmodule