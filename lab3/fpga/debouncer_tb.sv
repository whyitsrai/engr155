`timescale 1 ns/1 ns

module debouncer_tb();
    // does not test for error handling or internal logic, only for expected output functionality (bounces, no bounces, delays, etc)
    logic clk, reset, enable;
    logic bouncing, debounced;

    debouncer #(1, 4, 1, 1) dut(clk, reset, enable, bouncing, debounced);

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
        reset = 1;
        enable = 1;
        #8;
        reset = 0;
        bouncing = 0;
        #80
        assert(debounced == 0)
            $display("PASSES! Debounce output is 0 after 8 clock cycles of 0");
        else
            $error("FAILED! Debounce output is not 0 after 8 clock cycles of 0, is %0b", debounced);
        bouncing = 1;
        #40
        assert(debounced == 0)
            $display("PASSES! Debounce output is not yet 1 after 4 clock cycles of 1");
        else
            $error("FAILED! Debounce output is already 1 after 4 clock cycles of 1 (should retain old value of 0)");
        #40
        bouncing = 0;
        #20
        assert(debounced == 1)
            $display("PASSES! Debounce output is 1 after 8 clock cycles of 1 (and 2 additional clock cycles of x)");
        else
            $error("FAILED! Debounce output is not 1 after 8 clock cycles of 1 (and 2 additional clock cycles of x), is %0b", debounced);
        #20
        bouncing = 1;
        #60
        assert(debounced == 1)
            $display("PASSES! Retains old value after bounce event");
        else
            $error("FAILED! Does not retain old value after bounce event");
        enable = 0;
        #120
        assert(debounced == 1)
            $display("PASSES! Retains old value when disabled");
        else
            $error("FAILED! Does not retain old value when disabled");
        reset = 1;
        #10
        reset = 0;
        #10
        assert(debounced == 0)
            $display("PASSES! Functional reset");
        else
            $error("FAILED! Non-functional reset");

       $stop;
    end
endmodule