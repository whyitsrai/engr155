module two_digit_display 
    (input logic clk, reset, enable, update,
     input logic [4:0] new_display_data,
     output logic [1:0] segment_sel,
     output logic [6:0] segment_char);

    logic[1:0][4:0] displayed_chars;
    always_ff @(posedge clk) begin: sevensegment_shift_reg
        if (reset) displayed_chars <= 'b0;
        else if (update) begin
            displayed_chars[1] <= displayed_chars[0];
            displayed_chars[0] <= new_display_data;
        end
    end

    logic [18:0] seg_mux_count;
    counter #(19'd479999) seg_mux(clk, reset, 1'b1, seg_mux_count);
    logic [4:0] display_mux_char;
    logic[6:0] seg;
    assign segment_sel = (seg_mux_count < 240000 && display_mux_char[4]) ? 2'b01 : (seg_mux_count < 480000 && display_mux_char[4]) ? 2'b10 : 2'b00;
    assign display_mux_char = (seg_mux_count < 240000) ? displayed_chars[0] : (seg_mux_count < 480000) ? displayed_chars[1] : new_display_data;

    sevensegment_hex sevenseg_decoder(display_mux_char[3:0], segment_char);

endmodule
