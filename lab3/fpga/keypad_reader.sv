// no declared parameters yet
//
//
//
// just re-write the old module for this stuff
//
// Logic HIGH is on
//
//
// using a partially unpacked array, so ensure that it will actually be synthesized as flops and not
// DRAM

module keypad_reader 
    #(parameter NUM_ROWS=3, NUM_COLS=3, COUNT_PER_ROW=65536, DEBOUNCE_CYCLES=16)
    (input logic clk, reset, enable,
     input logic [NUM_COLS-1:0] col,
     output logic [NUM_ROWS-1:0] row,
     output logic [NUM_ROWS-1:0][NUM_COLS-1:0] key_status);

    logic [$clog2(NUM_ROWS*COUNT_PER_ROW+1)-1:0] scan_count;
    counter #((NUM_ROWS+1)*COUNT_PER_ROW-1) keypad_counter(clk, reset, enable, scan_count);

    genvar i;
    generate
        for (i=0; i<NUM_ROWS; i=i+1) begin: keypad_row_select
            assign row[i] = (scan_count >= i * COUNT_PER_ROW) && (scan_count < (i+1) * COUNT_PER_ROW);

            logic [3:0][DEBOUNCE_CYCLES-1:0] keypresses;
            always_ff @(posedge clk) begin
                for (int j=0; j<NUM_COLS; j=j+1) begin: keypad_per_column
                    if   (reset) begin key_status[i] <= 'b0; keypresses <= 'b0; end
                    else if (scan_count == ((i+1)*COUNT_PER_ROW)-1 && enable) begin
                        keypresses[j][DEBOUNCE_CYCLES-1:1] <= keypresses[j][DEBOUNCE_CYCLES-2:0];
                        keypresses[j][0] <= col[j];
                        if (~|keypresses[j]) key_status[i][j] <= 'b0; // needs one more cycle
                        else if (&keypresses[j]) key_status[i][j] <= 'b1;
                    end
                end
            end
        end
    endgenerate
endmodule
