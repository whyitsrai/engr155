`timescale 10 ns/10 ns

module lab1_rw_tb();
    logic         reset;             // unused
    logic [3:0]   s;                 // 4-bit input switches
    logic [1:0]   led;               // 2 output leds
    logic [6:0]   segments;          // 7-segment display
    logic [31:0]  past_clk_vals = 0; // bit shifts to left and stores current internal oscillator state in LSB

    lab1_rw dut (
        .reset(reset),
        .switches(s),
        .leds(led),
        .segments(segments)
    );

    always_ff @(posedge dut.int_osc, negedge dut.int_osc) begin
        past_clk_vals <= past_clk_vals << 1;
        past_clk_vals[0] <= dut.int_osc;
    end

  
    // apply stimuli and check outputs
    initial begin
        reset = 1;
        #4 reset = 0;

        #200; // decent number of full clock cycles at 24MHz

        assert (|past_clk_vals && ~&past_clk_vals) // must not be all 0's or all 1's
            $display("PASSED! There is a functional internal oscillator. The last few clock cycles look like: %b.", past_clk_vals);
        else
            $error("FAILED at time %0t! Internal oscillator not functional. Last few clock cycles produced: %b", $time, past_clk_vals);
  
        s = 4'b0000;
        #4;
        assert (led == 3'b00)
            $display("PASSED! The led controller behaves as desired. Input: %b Output: %b.", s, led);
        else 
            $display("FAILED at time %0t! The led controller does not behave as desired. Input: %b Output: %b.", $time, s, led);

        s = 4'b0101;
        #4;
        assert (led == 3'b01)
            $display("PASSED! The led controller behaves as desired. Input: %b Output: %b.", s, led);
        else 
            $display("FAILED at time %0t! The led controller does not behave as desired. Input: %b Output: %b.", $time, s, led);

        s = 4'b1100;
        #4;
        assert (led == 3'b10)
            $display("PASSED! The led controller behaves as desired. Input: %b Output: %b.", s, led);
        else 
            $display("FAILED at time %0t! The led controller does not behave as desired. Input: %b Output: %b.", $time, s, led);

        s = 4'b1101;
        #4;
        assert (led == 3'b11)
            $display("PASSED! The led controller behaves as desired. Input: %b Output: %b.", s, led);
        else 
            $display("FAILED at time %0t! The led controller does not behave as desired. Input: %b Output: %b.", $time, s, led);

        s = 4'b1011;
        #4;
        assert (led == 3'b00)
            $display("PASSED! The led controller behaves as desired. Input: %b Output: %b.", s, led);
        else 
            $display("FAILED at time %0t! The led controller does not behave as desired. Input: %b Output: %b.", $time, s, led);

        // as of now does not test blinking LED because I am tired
  
      #100 $stop;
    end
endmodule
