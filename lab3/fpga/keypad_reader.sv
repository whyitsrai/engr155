/* Rai Wandeler rwandeler@hmc.edu 2026-09-22

 This module scans (row by row), synchronizes the input of, and debounces the keypresses of a `NUM_ROWS` by `NUM_COLS` keypad
 matrix. The output of the module is a known to be correct map of the current state of every key on that keypad in row-first order.

 The `COUNT_PER_ROW` parameter controls the rate at which the keypad is scanned and is the number of clock cycles that is spent on one
 row before moving on to the next one. The `DEBOUNCE_CYCLES` parameter determines how many sequential input snapshots for any given key
 must match up before the keymap is updated (see the debounce module for more details).

 The scanning logic consists of setting a row to be HIGH and taking a snapshot of the (column) keys that are pressed in that moment.
 This row is then set back to LOW, and the next ROW is scanned. All of the debouncing logic is synchronized with respect to the scanning counter.
*/

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
                col_debouncer(clk, reset, enable, col_synced, key_status[i]);
        end
    endgenerate
endmodule
