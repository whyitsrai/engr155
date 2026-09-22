// NO RESET

module synchronizer 
    #(parameter N_BITS=1, N_STAGES=2)
    (input logic clk,
     input logic [N_BITS-1:0] async,
     output logic [N_BITS-1:0] sync);

    initial begin
        assert (N_STAGES >= 2)
        else $error("A synchronizer must have 2 or more stages!");
    end

    logic [N_BITS-1:0] intermediate_vals [N_STAGES-2:0];

    genvar i;
    generate
        for (i=0; i<N_STAGES; i=i+1) begin: sync_stages
            always_ff @(posedge clk) begin
                if (i == 0) begin: first_stage
                    intermediate_vals[i] <= async;
                end else if (i == N_STAGES-1) begin: last_stage
                    sync <= intermediate_vals[i-1];
                end else begin: middle_stages
                    intermediate_vals[i] <= intermediate_vals[i-1];
                end
            end
        end
    endgenerate
endmodule
