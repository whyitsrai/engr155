/* Rai Wandeler rwandeler@hmc.edu 2026-09-02

 This module takes in a 4-bit number and generated the required signals to display that 4-bit
 number as a digit on a 7-segment display. The outputs for the seven-segment display are ascribed as
 follows:

        A
      +---+
    F |   | B
      +-G-+
    E |   | C
      +---+
        D

In this case, a HIGH ('b1) output means that a given segment is illuminated and vice versa
*/

module sevensegment_hex(input logic [3:0] digit
                        output logic [6:0] segments); // the seven segments

    always_comb begin
        case (digit)
            4'b0000: {A, B, C, D, E, F, G} = 7'b1111110; // 0
            4'b0001: {A, B, C, D, E, F, G} = 7'b0110000; // 1
            4'b0010: {A, B, C, D, E, F, G} = 7'b1101101; // 2
            4'b0011: {A, B, C, D, E, F, G} = 7'b1111001; // 3
            4'b0100: {A, B, C, D, E, F, G} = 7'b0110011; // 4
            4'b0101: {A, B, C, D, E, F, G} = 7'b1011011; // 5
            4'b0110: {A, B, C, D, E, F, G} = 7'b1011111; // 6
            4'b0111: {A, B, C, D, E, F, G} = 7'b1110000; // 7
            4'b1000: {A, B, C, D, E, F, G} = 7'b1111111; // 8
            4'b1001: {A, B, C, D, E, F, G} = 7'b1111011; // 9
            4'b1010: {A, B, C, D, E, F, G} = 7'b1110111; // A
            4'b1011: {A, B, C, D, E, F, G} = 7'b0011111; // b
            4'b1100: {A, B, C, D, E, F, G} = 7'b0001101; // c
            4'b1101: {A, B, C, D, E, F, G} = 7'b0111101; // d
            4'b1110: {A, B, C, D, E, F, G} = 7'b1001111; // E
            4'b1111: {A, B, C, D, E, F, G} = 7'b1000111; // F
            default: {A, B, C, D, E, F, G} = 7'b0000000; // all off
        endcase
    end

endmodule

