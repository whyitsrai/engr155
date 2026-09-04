/* Rai Wandeler rwandeler@hmc.edu 2026-09-03

 This module takes takes in parameters N and p to form a counter. Every clock cycle a N-bit integer is incremented by p (if enabled).
 The internal counter resets to 0 when enable is pulled low.

 Taking the most significant bit of the output `count` gives you a square wave of frequency
    F = (p * F_clk)/(2^N)


 To calculate these, go and reference this link: https://www.desmos.com/calculator/flkjjktugp
*/

module counter_pn
    #(parameter N = 16, p =1)
    (input logic clk, reset, enable,
     output logic [N-1:0] count);

    always_ff @(posedge clk, posedge reset) begin
        if   (reset | ~enable) count <= 'b0;
        else if (enable) count <= count + p;
    end

endmodule