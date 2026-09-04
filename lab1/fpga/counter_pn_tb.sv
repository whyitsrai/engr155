`timescale 1 ns/1 ns

module counter_pn_tb();
    logic clk, reset, enable; // system clock
    logic [3:0] count;        // count variable

    counter_pn #(4,4'd2) dut(clk, reset, enable, count);
    // should create a signal with a frequency of 125 MHz, period is 8 clock cycles

    // generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end
  
    initial begin
        reset = 1;
        #22 reset = 0;

        #10;
        assert (count == 4'b0)
            $display("PASSED! Count is 0 when disabled after start");
        else
            $error("FAILED! Count is not 0 when counter is disabled after start. Count is %b. Time is: %0t.", count, $time);

        enable = 1;

        #10;
        assert (count == 4'b0010)
            $display("PASSED! Count is 0b0010 after 1 clock cycle");
        else
            $error("FAILED! Count is not 0b0010 after 1 clock cycle. Count is %b. Time is: %0t.", count, $time);

        #10;
        assert (count == 4'b0100)
            $display("PASSED! Count is 0b0100 after 2 clock cycles");
        else
            $error("FAILED! Count is not 0b0100 after 2 clock cycles. Count is %b. Time is: %0t.", count, $time);

        #10;
        assert (count == 4'b0110)
            $display("PASSED! Count is 0b0110 after 3 clock cycles");
        else
            $error("FAILED! Count is not 0b0110 after 3 clock cycles. Count is %b. Time is: %0t.", count, $time);

        #10;
        assert (count == 4'b1000)
            $display("PASSED! Count is 0b1000 after 4 clock cycles");
        else
            $error("FAILED! Count is not 0b1000 after 4 clock cycles. Count is %b. Time is: %0t.", count, $time);

        #10;
        assert (count == 4'b1010)
            $display("PASSED! Count is 0b1010 after 5 clock cycles");
        else
            $error("FAILED! Count is not 0b1010 after 5 clock cycles. Count is %b. Time is: %0t.", count, $time);

        #10;
        assert (count == 4'b1100)
            $display("PASSED! Count is 0b1100 after 6 clock cycles");
        else
            $error("FAILED! Count is not 0b1100 after 6 clock cycles. Count is %b. Time is: %0t.", count, $time);

        #10;
        assert (count == 4'b1110)
            $display("PASSED! Count is 0b1110 after 7 clock cycles");
        else
            $error("FAILED! Count is not 0b1110 after 7 clock cycles. Count is %b. Time is: %0t.", count, $time);

        #10;
        assert (count == 4'b0000)
            $display("PASSED! Count is 0b0000 after 8 clock cycles");
        else
            $error("FAILED! Count is not 0b0000 after 8 clock cycles. Count is %b. Time is: %0t.", count, $time);

        #10;
        reset = 1;
        #1;
        assert (count == 4'b0000)
            $display("PASSED! Count is 0b0000 during reset");
        else
            $error("FAILED! Count is not 0b0000 during reset. Count is %b. Time is: %0t.", count, $time);
        #5;
        reset = 0;

        #10;
        enable = 0;
        #10;
        assert (count == 4'b0000)
            $display("PASSED! Count is 0b0000 after being disabled");
        else
            $error("FAILED! Count is not 0b0000 after being disabled. Count is %b. Time is: %0t.", count, $time);
  
        $stop;
    end
endmodule
