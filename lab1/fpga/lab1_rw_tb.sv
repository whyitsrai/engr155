`timescale 1 ns/1 ns // wonder if timescale caused things to get fucky

module lab1_rw_tb();
    logic         reset;             // unused
    logic [3:0]   s;                 // 4-bit input switches
    logic [2:0]   leds;               // 3 output leds
    logic [6:0]   segments;          // 7-segment display
    logic [31:0]  past_clk_vals = 0; // bit shifts to left and stores current internal oscillator state in LSB

    lab1_rw dut (
        .reset(~reset),      // reset is pulled-up in hardware (normally high)
        .switches(~s),       // negated as switches are pulled up in hardware
        .leds(leds),
        .segments(segments)  // negated when mentioned bc pulled down to turn on
    );

    always_ff @(posedge dut.int_osc, negedge dut.int_osc) begin
        past_clk_vals <= past_clk_vals << 1;
        past_clk_vals[0] <= dut.int_osc;
    end


    // apply stimuli and check outputs
    initial begin
        reset = 1;
        s = 4'b0;
        #22;
        reset = 0;

        #500; // decent number of full clock cycles at 24MHz

        assert (|past_clk_vals && ~&past_clk_vals) // must not be all 0's or all 1's
            $display("PASSED! There is a functional internal oscillator. The last few clock cycles look like: %b.", past_clk_vals);
        else
            $error("FAILED at time %0t! Internal oscillator not functional. Last few clock cycles produced: %b", $time, past_clk_vals);

        s = 4'b0000;
        #4;
        assert (leds == 3'b000)
            $display("PASSED! The led controller behaves as desired. Input: %b Output: %b.", s, leds);
        else 
            $display("FAILED at time %0t! The led controller does not behave as desired. Input: %b Output: %b.", $time, s, leds);
        assert (~segments == 7'b1111110)
            $display("PASSED! The seven segment displays 0");
        else 
            $display("FAILED at time %0t! The seven segment does not display 0. Input: %b Output: %b.", $time, s, ~segments);

        s = 4'b0101;
        #4;
        assert (leds == 3'b001)
            $display("PASSED! The led controller behaves as desired. Input: %b Output: %b.", s, leds);
        else 
            $display("FAILED at time %0t! The led controller does not behave as desired. Input: %b Output: %b.", $time, s, leds);
        assert (~segments == 7'b1011011)
            $display("PASSED! The seven segment displays 5");
        else 
            $display("FAILED at time %0t! The seven segment does not display 5. Input: %b Output: %b.", $time, s, ~segments);

        s = 4'b1100;
        #4;
        assert (leds == 3'b010)
            $display("PASSED! The led controller behaves as desired. Input: %b Output: %b.", s, leds);
        else 
            $display("FAILED at time %0t! The led controller does not behave as desired. Input: %b Output: %b.", $time, s, leds);
        assert (~segments == 7'b0001101)
            $display("PASSED! The seven segment displays c");
        else 
            $display("FAILED at time %0t! The seven segment does not display c. Input: %b Output: %b.", $time, s, ~segments);

        s = 4'b1101;
        #4;
        assert (leds == 3'b011)
            $display("PASSED! The led controller behaves as desired. Input: %b Output: %b.", s, leds);
        else 
            $display("FAILED at time %0t! The led controller does not behave as desired. Input: %b Output: %b.", $time, s, leds);
        assert (~segments == 7'b0111101)
            $display("PASSED! The seven segment displays d");
        else 
            $display("FAILED at time %0t! The seven segment does not display d. Input: %b Output: %b.", $time, s, ~segments);

        s = 4'b1011;
        #4;
        assert (leds == 3'b000)
            $display("PASSED! The led controller behaves as desired. Input: %b Output: %b.", s, leds);
        else 
            $display("FAILED at time %0t! The led controller does not behave as desired. Input: %b Output: %b.", $time, s, leds);
        assert (~segments == 7'b0011111)
            $display("PASSED! The seven segment displays b");
        else 
            $display("FAILED at time %0t! The seven segment does not display b. Input: %b Output: %b.", $time, s, ~segments);

        #100;
        assert (signed'(dut.counter_blink_led) > -25'd10000000)
            $display("PASSED! The counter counts up from start");
        else 
            $display("FAILED at time %0t! The counter does not count up from start", $time);

        assert (leds[2] == 1'b0)
            $display("PASSED! The LED is off during the first half of count.");
        else 
            $display("FAILED at time %0t! The LED is not off during the first half of count.", $time);

        #9;
        force dut.blink_led.count = 400;
        #1;
        release dut.blink_led.count;
        #100;
        assert (signed'(dut.counter_blink_led) > 25'd400)
            $display("PASSED! The counter counts up when positive");
        else
            $display("FAILED at time %0t! The counter does not count up when positive", $time);

        assert (leds[2] == 1'b1)
            $display("PASSED! The LED is on during the second half of count.");
        else 
            $display("FAILED at time %0t! The LED is not on during the second half of count.", $time);

      $stop;
    end
endmodule

// counter_blink_led was not getting updated at all
