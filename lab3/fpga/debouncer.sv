/* Rai Wandeler rwandeler@hmc.edu 2026-09-22

 This module debounces an input by sending it through a shift register of length `N_STAGES`.
 The output is altered only when every bit of the shift register is the same (i.e. the last `N_STAGES` inputs all match);
 in this case the output matches the value of the entire shift register (as every bit is the same). Else, the output retains its
 old value.

 The number of bits that are simultaneously debounced is set by the `N_BITS` parameter.
 Lastly, `MAX_COUNT` and `TRIG_COUNT` control when and how often the shift register is advanced.
 This can be useful to keep multiple debouncers synchronized while having them take snapshots at different times; this
 would be necessary when an input needs to go down a different pathway at different times (is multiplexed). As an example, see
 the Lab 3 code.
*/

module debouncer 
    #(parameter N_BITS, N_STAGES=16, MAX_COUNT, TRIG_COUNT)
    (input logic clk, reset, enable,
     input logic [N_BITS-1:0] bouncing,
     output logic [N_BITS-1:0] debounced);

    initial begin
        assert (N_STAGES >= 2)
        else $error("A debouncer must have 2 or more stages!");
    end

    logic [$clog2(MAX_COUNT+1)-1:0] count;
    counter #(MAX_COUNT) debounce_counter(clk, reset, enable, count);

    logic [N_BITS-1:0][N_STAGES-1:0] shift_reg;

    always_ff @(posedge clk) begin
        for (int i=0; i<N_BITS; i=i+1) begin: single_bit_debounce
            if   (reset) begin debounced[i] <= 'b0; shift_reg <= 'b0; end
            else if (count == TRIG_COUNT && enable) begin
                shift_reg[i] <= {shift_reg[i][N_STAGES-2:0], bouncing[i]};

                // output logic
                if (~|shift_reg[i]) debounced[i] <= 'b0;
                else if (&shift_reg[i]) debounced[i] <= 'b1;
            end
        end
    end

endmodule
