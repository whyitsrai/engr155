// NO RESET

// get one debounced row at a time (through the generate block)
//      this will make the code as neat and BEAUTIFUL as possible
//
// same thing for the synchronizer
//
//
// the debouncer takes in a whole row of keys (array of keys)
//
// then it returns the status of those keys

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
