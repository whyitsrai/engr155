`timescale 1 ns/1 ns // wonder if timescale caused things to get fucky

module lab2_rw_tb();
    logic         reset, clk;
    logic [3:0]   sw1, sw2;                   // 4-bit input switches
    logic [3:0]   leds;                // 3 output leds
    logic [1:0]   segment_sel;            // 7-segment display
    logic [6:0]   segment_char;            // 7-segment display
    logic [3:0]   row;            
    logic [31:0]  past_hsosc_vals = 0; // bit shifts to left and stores current internal oscillator state in LSB

    lab2_rw dut (
        .reset(~reset),      // reset is pulled-up in hardware (normally high)
        .sw1(~sw1),          // negated as switches are pulled up in hardware
        .sw2(~sw2),          // negated as switches are pulled up in hardware
        .col(~sw2),          // negated as switches are pulled up in hardware
        .leds(leds),
        .segment_sel(segment_sel),
        .segment_char(segment_char),  // negated when mentioned bc pulled down to turn on
        .row(row)
    );

    // generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    always_ff @(posedge clk) begin
        past_hsosc_vals <= past_hsosc_vals << 1;
        past_hsosc_vals[0] <= dut.int_osc;
    end


    // apply stimuli and check outputs
    initial begin
        reset = 1;
        sw1 = 4'b0000;
        sw2 = 4'b1111;
        #22;
        reset = 0;

        #500; // decent number of full clock cycles at 24MHz

        assert (|past_hsosc_vals && ~&past_hsosc_vals) // must not be all 0's or all 1's
            $display("PASSED! There is a functional internal oscillator. The last few clock cycles look like: %b.", past_hsosc_vals);
        else
            $error("FAILED at time %0t! Internal oscillator not functional. Last few clock cycles produced: %b", $time, past_hsosc_vals);

        reset = 1;
        #10
        reset = 0;

        assert (dut.seg_mux_count < 'd200 && dut.row == 4'b1110)
            $display("PASSED! Reset correctly resets seg_mux_count and scanning row at time %0t", $time);
        else
            $error("FAILED at time %0t! Either seg_mux count (%0d) or scannig row (%b) did not reset", $time, dut.seg_mux_count, dut.row);

        #5;
        assert (dut.segment_sel == 2'b10)
            $display("PASSED! Correct segment 1 is illuminated at time %0t.", $time);
        else
            $error("FAILED! Incorrect segment illuminated at time %0t: Output %b", $time, dut.segment_sel);

        assert (~segment_char == 7'b1111110)
            $display("PASSED! The seven segment displays 0");
        else 
            $display("FAILED at time %0t! The seven segment does not display 0. Input: %b Output: %b.", $time, dut.sw_cur, ~segment_char);

        #10;
        force dut.seg_mux.count = 19'd240000;
        #5;
        release dut.seg_mux.count;

        assert (dut.segment_sel == 2'b01)
            $display("PASSED! Correct segment 2 is illuminated at time %0t.", $time);
        else
            $error("FAILED! Incorrect segment illuminated at time %0t: Output %b", $time, dut.segment_sel);
        assert (~segment_char == 7'b1000111)
            $display("PASSED! The seven segment displays F");
        else 
            $display("FAILED at time %0t! The seven segment does not display F. Input: %b Output: %b.", $time, dut.sw_cur, ~segment_char);

        #100;
        assert (dut.seg_mux_count > 19'd240000)
            $display("PASSED! Segment mux counter counts up at time %0t.", $time);
        else
            $display("FAILED! Segment mux counter does not acount up at time %0t: count is %d", $time, dut.seg_mux_count);

        #10;
        force dut.seg_mux.count = 19'd479999;
        #5;
        release dut.seg_mux.count;
        #100;
        assert (dut.seg_mux_count < 19'd100)
            $display("PASSED! Segment mux counter resets at correct point at time %0t.", $time);
        else
            $display("FAILED! Segment mux counter does not reset at correct point at time %0t: count is %d", $time, dut.seg_mux_count);

        #10;
        force dut.keypad.keypad_counter.count = 25'd0;
        force dut.col = 4'b1111;
        #5;
        assert (dut.row == 4'b1110)
            $display("PASSED! Correct row is scanned at time %0t.", $time);
        else
            $display("FAILED! Incorrect row %0d is scanned at time %0t.", dut.row, $time);
        assert (dut.leds == 4'b0000)
            $display("PASSED! LED's light correctly given input %b while scanning row 1 at time %0t.", dut.col, $time);
        else
            $display("FAILED! LED's don't light correctly given input %b while scanning row 1 at time %0t. Output: %b", dut.col, $time, dut.leds);
        force dut.col = 4'b0000;
        #5;
        assert (dut.leds == 4'b1111)
            $display("PASSED! LED's light correctly given input %b while scanning row 1 at time %0t.", dut.col, $time);
        else
            $display("FAILED! LED's don't light correctly given input %b while scanning row 1 at time %0t. Output: %b", dut.col, $time, dut.leds);
        force dut.col = 4'b0101;
        #5;
        assert (dut.leds == 4'b1010)
            $display("PASSED! LED's light correctly given input %b while scanning row 1 at time %0t.", dut.col, $time);
        else
            $display("FAILED! LED's don't light correctly given input %b while scanning row 1 at time %0t. Output: %b", dut.col, $time, dut.leds);
        
        #10;
        force dut.keypad.keypad_counter.count = 25'd12000000;
        force dut.col = 4'b1111;
        #5;
        assert (dut.row == 4'b1011)
            $display("PASSED! Correct row is scanned at time %0t.", $time);
        else
            $display("FAILED! Incorrect row %0d is scanned at time %0t.", dut.row, $time);
        assert (dut.leds == 4'b0000)
            $display("PASSED! LED's light correctly given input %b while scanning row 3 at time %0t.", dut.col, $time);
        else
            $display("FAILED! LED's don't light correctly given input %b while scanning row 3 at time %0t. Output: %b", dut.col, $time, dut.leds);
        force dut.col = 4'b0000;
        #5;
        assert (dut.leds == 4'b1111)
            $display("PASSED! LED's light correctly given input %b while scanning row 3 at time %0t.", dut.col, $time);
        else
            $display("FAILED! LED's don't light correctly given input %b while scanning row 3 at time %0t. Output: %b", dut.col, $time, dut.leds);
        force dut.col = 4'b0101;
        #5;
        assert (dut.leds == 4'b1010)
            $display("PASSED! LED's light correctly given input %b while scanning row 3 at time %0t.", dut.col, $time);
        else
            $display("FAILED! LED's don't light correctly given input %b while scanning row 1 at time %0t. Output: %b", dut.col, $time, dut.leds);
      $stop;
    end
endmodule
