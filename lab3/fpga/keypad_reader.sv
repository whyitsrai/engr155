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

    logic [$clog2(NUM_ROWS*COUNT_PER_ROW)-1:0] scan_count;

    counter #(NUM_ROWS*COUNT_PER_ROW-1) keypad_counter(clk, reset, enable, scan_count);

    genvar i;
    generate
        for (i=0; i<NUM_ROWS; i=i+1) begin: single_row_processing
            // row scanning
            assign row[i] = (scan_count >= i * COUNT_PER_ROW) && (scan_count < (i+1) * COUNT_PER_ROW);

            logic [NUM_COLS-1:0] col_synced;
            synchronizer #(NUM_COLS, 2) col_synchronizer(clk, col, col_synced);
            debouncer #(NUM_COLS, DEBOUNCE_CYCLES, NUM_ROWS*COUNT_PER_ROW-1, (i+1) * COUNT_PER_ROW - 1)
                row_debouncer(clk, reset, enable, col_synced, key_status[i]);
        end
    endgenerate
endmodule
