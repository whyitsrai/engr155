/* Rai Wandeler rwandeler@hmc.edu 2026-09-06

This module take in parameter N which specifies the oscillator's bit-width and counts from 0 to
stopn. When enable is HIGH, the counter counts up by 1 every clock cycle. When reset is triggered,
the counter resets to 0.
*/

module counter_pos
    #(parameter N=32, stopn = 32'b1)
    (input logic clk, reset, enable,
     output logic [N-1:0] count);

    always_ff @(posedge clk, posedge reset) begin
        if   (reset) count <= N'b0;
        else if (enable && count < stopn) count <= count + 1'b1;
        else if (enable) count <= N'b0;
    end

endmodule
