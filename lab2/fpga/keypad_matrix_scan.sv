/* Rai Wandeler rwandeler@hmc.edu 2026-09-11

 This module takes care of scanning a keypad matirx row by row and outputs the (normally LOW) bits
 corresponding to the collumn that is being scanned.

 This module DOES NOT save its state and output a list of all keys that are currently being pressed,
 only the row that is being asserted

 The output is using a one-hot encoding scheme, with each bit corresponding to a key.
 For example, for a 3x3 matrix with switches

     1 0 1
     0 1 1
     1 1 0

 assuming that the second row is being scanned expect row=3'b010. The keys pressed in the column can
 be found out in the top module.
*/

module keypad_matrix_scan
    #(parameter num_rows=4, scan_freq=2)
    (input logic clk, reset, enable,
     output logic [num_rows-1:0] row);

    localparam count_bits = $clog2(48_000_000/scan_freq - 1);
    localparam logic [count_bits-1:0] max_count = 48_000_000/scan_freq - 1;
    localparam logic [count_bits-1:0] count_per_row = (max_count + 1) / num_rows;
    logic [count_bits-1:0] scan_count;

    counter #(count_bits, max_count) keypad_counter(clk, reset, enable, scan_count);
    
    genvar i;
    generate
        // as the scan_count variable increases, a more significant bit is toggled on
        for (i=0; i<num_rows; i=i+1) begin: keypad_row_select
           assign row[i] = (scan_count >= i * count_per_row) && (scan_count < (i+1) * count_per_row);
        end
    endgenerate

endmodule

