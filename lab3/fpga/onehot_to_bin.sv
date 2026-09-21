/* Rai Wandeler rwandeler@hmc.edu 2026-09-20

 This module takes in a 4-bit number and generated the required signals to display that 4-bit
 number as a digit on a 7-segment display. The outputs for the seven-segment display are ascribed as
 follows:


 This is designed with a bunch of if statements in order to reduce the hardware expense (with the drawback of invalid inputs having unknowable outputs)
*/

// TODO parametrize this and make it generalized (maybe??)

module onehot_to_bin(input logic [15:0] keymap, // use to be [3:0][3:0]
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

// ensure that this style is borderline acceptable