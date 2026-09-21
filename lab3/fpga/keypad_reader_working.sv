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

module keypad_reader (input logic clk, reset, enable,
                      input logic [3:0] col,
                      output logic [3:0] row,
                      output logic [3:0][3:0] key_status);

    logic [17:0] scan_count; // need to change bit length

    counter #(18, 'd262143) keypad_counter(clk, reset, enable, scan_count);

    assign row[0] = (scan_count >= 0) && (scan_count < 'd65536);
    assign row[1] = (scan_count >= 'd65536) && (scan_count < 'd131072);
    assign row[2] = (scan_count >= 'd131072) && (scan_count < 'd196608);
    assign row[3] = (scan_count >= 'd196608) && (scan_count < 'd262144);

    logic [3:0][15:0] keypresses0;
    always_ff @(posedge clk) begin
        if   (reset) begin key_status[0] <= 'b0; keypresses0 <= 'b0; end
        else if (scan_count == 'd65535 && enable) begin
            keypresses0[0][15:1] <= keypresses0[0][14:0];
            keypresses0[0][0] <= col[0];
            keypresses0[1][15:1] <= keypresses0[1][14:0];
            keypresses0[1][0] <= col[1];
            keypresses0[2][15:1] <= keypresses0[2][14:0];
            keypresses0[2][0] <= col[2];
            keypresses0[3][15:1] <= keypresses0[3][14:0];
            keypresses0[3][0] <= col[3];
            if (~|keypresses0[0]) key_status[0][0] <= 'b0; // needs one more cycle
            else if (&keypresses0[0]) key_status[0][0] <= 'b1;
            if (~|keypresses0[0]) key_status[0][1] <= 'b0;
            else if (&keypresses0[1]) key_status[0][1] <= 'b1;
            if (~|keypresses0[0]) key_status[0][2] <= 'b0;
            else if (&keypresses0[2]) key_status[0][2] <= 'b1;
            if (~|keypresses0[0]) key_status[0][3] <= 'b0;
            else if (&keypresses0[3]) key_status[0][3] <= 'b1;
        end
    end
    logic [3:0][15:0] keypresses1;
    always_ff @(posedge clk) begin
        if   (reset) begin key_status[1] <= 'b0; keypresses1 <= 'b0; end
        else if (scan_count == 'd131071 && enable) begin
            keypresses1[0][15:1] <= keypresses1[0][14:0];
            keypresses1[0][0] <= col[0];
            keypresses1[1][15:1] <= keypresses1[1][14:0];
            keypresses1[1][0] <= col[1];
            keypresses1[2][15:1] <= keypresses1[2][14:0];
            keypresses1[2][0] <= col[2];
            keypresses1[3][15:1] <= keypresses1[3][14:0];
            keypresses1[3][0] <= col[3];
            if (~|keypresses1[0]) key_status[1][0] <= 'b0;
            else if (&keypresses1[0]) key_status[1][0] <= 'b1;
            if (~|keypresses1[0]) key_status[1][1] <= 'b0;
            else if (&keypresses1[1]) key_status[1][1] <= 'b1;
            if (~|keypresses1[0]) key_status[1][2] <= 'b0;
            else if (&keypresses1[2]) key_status[1][2] <= 'b1;
            if (~|keypresses1[0]) key_status[1][3] <= 'b0;
            else if (&keypresses1[3]) key_status[1][3] <= 'b1;
        end
    end
    logic [3:0][15:0] keypresses2;
    always_ff @(posedge clk) begin
        if   (reset) begin key_status[2] <= 'b0; keypresses2 <= 'b0; end
        else if (scan_count == 'd196607 && enable) begin
            keypresses2[0][15:1] <= keypresses2[0][14:0];
            keypresses2[0][0] <= col[0];
            keypresses2[1][15:1] <= keypresses2[1][14:0];
            keypresses2[1][0] <= col[1];
            keypresses2[2][15:1] <= keypresses2[2][14:0];
            keypresses2[2][0] <= col[2];
            keypresses2[3][15:1] <= keypresses2[3][14:0];
            keypresses2[3][0] <= col[3];
            if (~|keypresses2[0]) key_status[2][0] <= 'b0;
            else if (&keypresses2[0]) key_status[2][0] <= 'b1;
            if (~|keypresses2[1]) key_status[2][1] <= 'b0;
            else if (&keypresses2[1]) key_status[2][1] <= 'b1;
            if (~|keypresses2[2]) key_status[2][2] <= 'b0;
            else if (&keypresses2[2]) key_status[2][2] <= 'b1;
            if (~|keypresses2[3]) key_status[2][3] <= 'b0;
            else if (&keypresses2[3]) key_status[2][3] <= 'b1;
        end
    end
    logic [3:0][15:0] keypresses3;
    always_ff @(posedge clk) begin
        if   (reset) begin key_status[3] <= 'b0; keypresses3 <= 'b0; end
        else if (scan_count == 'd262143 && enable) begin
            keypresses3[0][15:1] <= keypresses3[0][14:0];
            keypresses3[0][0] <= col[0];
            keypresses3[1][15:1] <= keypresses3[1][14:0];
            keypresses3[1][0] <= col[1];
            keypresses3[2][15:1] <= keypresses3[2][14:0];
            keypresses3[2][0] <= col[2];
            keypresses3[3][15:1] <= keypresses3[3][14:0];
            keypresses3[3][0] <= col[3];
            if (~|keypresses3[0]) key_status[3][0] <= 'b0;
            else if (&keypresses3[0]) key_status[3][0] <= 'b1;
            if (~|keypresses3[1]) key_status[3][1] <= 'b0;
            else if (&keypresses3[1]) key_status[3][1] <= 'b1;
            if (~|keypresses3[2]) key_status[3][2] <= 'b0;
            else if (&keypresses3[2]) key_status[3][2] <= 'b1;
            if (~|keypresses3[3]) key_status[3][3] <= 'b0;
            else if (&keypresses3[3]) key_status[3][3] <= 'b1;
        end
    end

endmodule
