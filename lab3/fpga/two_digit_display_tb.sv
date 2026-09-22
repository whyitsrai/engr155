module two_digit_display_tb();
    // only tests the interconnections with the submodules and module functions
    logic clk, reset, update;
    logic [4:0] new_display_data;
    logic [1:0]   segment_sel;
    logic [6:0]   segment_char;

    two_digit_display dut(clk, reset, update, new_display_data, segment_sel, segment_char);

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
        reset = 1;
        #8;
        reset = 0;
        new_display_data = 'b11001;
        assert (dut.seg_mux_count < 'd200)
            $display("PASSED! Reset correctly resets seg_mux_count at time %0t", $time);
        else
            $error("FAILED at time %0t! Seg_mux count (%0d) did not reset", $time, dut.seg_mux_count);

        #10;
        assert (dut.segment_sel == 2'b00)
            $display("PASSED! Correct segment (none) is illuminated at time %0t.", $time);
        else
            $error("FAILED! Incorrect segment illuminated at time %0t: Output %b", $time, dut.segment_sel);
        #20;
        assert (segment_char == 7'b1111110)
            $display("PASSED! The seven segment displays 0 (default case no input)");
        else 
            $display("FAILED at time %0t! The seven segment does not display 0. Input: %b Output: %b.", $time, dut.display_mux_char[3:0], ~segment_char);

        #10 // add F0 to the buffer and update it accordingly
        new_display_data = 'b11111;
        #10
        update = 1;
        #10
        update = 0;
        #10
        new_display_data = 'b10000;
        #10
        update = 1;
        #10
        update = 0;
        #5;
        assert (dut.segment_sel == 2'b01)
            $display("PASSED! Correct segment 1 is illuminated at time %0t.", $time);
        else
            $error("FAILED! Incorrect segment illuminated at time %0t: Output %b", $time, dut.segment_sel);

        assert (segment_char == 7'b1111110)
            $display("PASSED! The seven segment displays 0");
        else 
            $display("FAILED at time %0t! The seven segment does not display 0. Input: %b Output: %b.", $time, dut.display_mux_char[3:0], ~segment_char);

        #10;
        force dut.seg_mux.count = 19'd240000;
        #5;
        release dut.seg_mux.count;

        assert (dut.segment_sel == 2'b10)
            $display("PASSED! Correct segment 2 is illuminated at time %0t.", $time);
        else
            $error("FAILED! Incorrect segment illuminated at time %0t: Output %b", $time, dut.segment_sel);
        assert (segment_char == 7'b1000111)
            $display("PASSED! The seven segment displays F");
        else 
            $display("FAILED at time %0t! The seven segment does not display F. Input: %b Output: %b.", $time, dut.display_mux_char[3:0], ~segment_char);

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
        assert (dut.seg_mux_count < 19'd16)
            $display("PASSED! Segment mux counter resets at correct point at time %0t.", $time);
        else
            $display("FAILED! Segment mux counter does not reset at correct point at time %0t: count is %d", $time, dut.seg_mux_count);

       $stop;
    end
endmodule