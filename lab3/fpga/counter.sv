/* Rai Wandeler rwandeler@hmc.edu 2026-09-12

This module take in parameter N which specifies the oscillator's bit-width and counts from 0 to stopn. 
When enable is HIGH, the counter counts up by 1 every clock cycle (positive edge). When enable is LOW,
the current counter value is retained and continues to be output
When reset is triggered, the counter resets to 0 at the next positive clock edge (synchronous).
*/

module counter
    #(parameter N=32, stopn = 32'b1)
    (input logic clk, reset, enable,
     output logic [N-1:0] count);

    always_ff @(posedge clk) begin
        if   (reset) count <= 'b0;
        else if (enable && count < stopn) count <= count + 1'b1;
        else if (enable) count <= 'b0;
    end

endmodule
