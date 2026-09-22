/* Rai Wandeler rwandeler@hmc.edu 2026-09-22

 This module synchronizes from one clock domain (or async input) to the clock domain clk through a number of stages
 specified by `N_STAGES`. It is simply a few flip flops in series that allow for the settling of metastability.
 It can do this to a number of bits equivalent to the `N_BITS` parameter.

 This module is always active and has no reset value in order to most faithfully pass through a synchronized version of it's input
 even if that input is not initialized. I cannot think of a reason as to why you would want to pause data from going through the synchronizer;
 it would just make things more confusing.
*/

module synchronizer 
    #(parameter N_BITS=1, N_STAGES=2)
    (input logic clk,
     input logic [N_BITS-1:0] async,
     output logic [N_BITS-1:0] sync);

    initial begin
        assert (N_STAGES >= 2)
        else $error("A synchronizer must have 2 or more stages!");
    end

    logic [N_BITS-1:0] intermediate_vals [N_STAGES-1:0];

    genvar i;
    generate
        for (i=0; i<N_STAGES; i=i+1) begin: sync_stages
            always_ff @(posedge clk) begin
                if (i == 0) begin: first_stage
                    intermediate_vals[i] <= async;
                end else begin: other_stages
                    intermediate_vals[i] <= intermediate_vals[i-1];
                end
            end
        end
    endgenerate
    assign sync = intermediate_vals[N_STAGES-1]; // this bullshit is needed for questa to sim properly
                                                 // else it thinks that sync is driven by multiple sources

endmodule
