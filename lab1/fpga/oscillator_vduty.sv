/* Rai Wandeler rwandeler@hmc.edu 2026-09-06

This module take in parameter N which specifies the oscillator's bit-width and counts from startn
(which can be negative) to stopn. When enable is HIGH, the counter counts up by 1 every clock cycle.
When reset is triggered, the counter resets to startn.

One possible use for this is to form a variable duty-cycle counter. The value of the `count` is
stored in 2's complement and therefore count[N-1] is HIGH when the number is negative and LOW when
the number is positive. 

    If you want to create a signal that is on for 4 counts and off for 2 counts, set `startn=-4` and `stopn=1`.
*/

module oscillator_vduty
    #(parameter N=32, startn = 32'b1, stopn = {1'b0, 31'b1})
    (input logic clk, reset, enable,
     output logic signed [N-1:0] count);

    always_ff @(posedge clk, posedge reset) begin
        if   (reset) count <= startn;
        else if (enable && count < signed'(stopn)) count <= count + 1'b1;
        else if (enable) count <= startn;
    end

endmodule
