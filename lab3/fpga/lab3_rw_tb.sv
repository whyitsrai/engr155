`timescale 1 ns/1 ns

module lab3_rw_tb();
    logic         reset, clk;
    logic [1:0]   segment_sel;
    logic [6:0]   segment_char;            // 7-segment display
    logic [3:0]   row, col;            
    logic [31:0]  past_hsosc_vals = 0; // bit shifts to left and stores current internal oscillator state in LSB

    lab3_rw dut (
        .reset(~reset),      // reset is pulled-up in hardware (normally high)
        .col(col),
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

    assign col = (row == 'b1110) ? 4'b1110 : 4'b1111; // pressing and holding the 1 key

    // apply stimuli and check outputs
    initial begin
        reset = 1;
        #22;
        reset = 0;

        #200; // decent number of full clock cycles at 48MHz

        assert (|past_hsosc_vals && ~&past_hsosc_vals) // must not be all 0's or all 1's
            $display("PASSED! There is a functional internal oscillator. The last few clock cycles look like: %b.", past_hsosc_vals);
        else
            $error("FAILED at time %0t! Internal oscillator not functional. Last few clock cycles produced: %b", $time, past_hsosc_vals);

        reset = 1;
        assert (dut.keypad.reset == ~reset) $display("PASSED! Correct reset connection to keypad");
        else $error("FAILED! Incorrect reset connection to keypad");
        assert (dut.main_fsm.reset == ~reset) $display("PASSED! Correct reset connection to main fsm");
        else $error("FAILED! Incorrect reset connection to main fsm");
        assert (dut.display.reset == ~reset) $display("PASSED! Correct reset connection to display");
        else $error("FAILED! Incorrect reset connection to display");
        #50
        reset = 0;
        assert (dut.keypad.reset == ~reset) $display("PASSED! Correct reset connection to keypad");
        else $error("FAILED! Incorrect reset connection to keypad");
        assert (dut.main_fsm.reset == ~reset) $display("PASSED! Correct reset connection to main fsm");
        else $error("FAILED! Incorrect reset connection to main fsm");
        assert (dut.display.reset == ~reset) $display("PASSED! Correct reset connection to display");
        else $error("FAILED! Incorrect reset connection to display");

        #100000000;
        assert (dut.display.displayed_chars[0] == 'b10001) $display("PASSED! Displaying character 1 on right segment while pressing and holding key 1");
        else $error("FAILED! NOT displaying character 1 on right segment while pressing and holding key 1");
        assert (dut.main_fsm.state == 'b01) $display("PASSED! Correct FSM state while pressing and holding key 1");
        else $error("FAILED! Incorrect FSM state while pressing and holding key 1");

      $stop;
    end
endmodule
