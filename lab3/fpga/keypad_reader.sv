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
    #(parameter num_rows=3, num_cols=3, count_per_row=65536, debounce_cycles=16)
    (input logic clk, reset, enable,
     input logic [num_cols-1:0] col,
     output logic [num_rows-1:0] row,
     output logic [num_rows-1:0][num_cols-1:0] key_status);
	 
    localparam count_bits = $clog2(num_rows*65536 - 1);
    logic [count_bits-1:0] scan_count;
    counter #(count_bits, (num_rows+1)*count_per_row-1) keypad_counter(clk, reset, enable, scan_count);

    genvar i;
    generate
        for (i=0; i<num_rows; i=i+1) begin: keypad_row_select
           assign row[i] = (scan_count >= i * count_per_row) && (scan_count < (i+1) * count_per_row);

            logic [3:0][debounce_cycles-1:0] keypresses;
            always_ff @(posedge clk) begin
                for (int j=0; j<num_cols; j=j+1) begin
                    if   (reset) begin key_status[i] <= 'b0; keypresses <= 'b0; end
                    else if (scan_count == ((i+1)*count_per_row)-1 && enable) begin
                        keypresses[j][debounce_cycles-1:1] <= keypresses[j][debounce_cycles-2:0];
                        keypresses[j][0] <= col[j];
                        if (~|keypresses[j]) key_status[i][j] <= 'b0; // needs one more cycle
                        else if (&keypresses[j]) key_status[i][j] <= 'b1;
                    end
                end
            end
        end
    endgenerate
endmodule
