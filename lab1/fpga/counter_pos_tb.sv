`timescale 1 ns/1 ns

module oscillator_varduty_sv();
    logic clk, reset, enable; // system clock
    logic signed [7:0] count; // count variable

    counter_pos #(8, 8'd24) dut(clk, reset, enable, count);
    // counts up by 1 unit every clock cycle from 0 to 24

    // generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end
  
    initial begin
        reset = 1;
        #22 reset = 0;

        #10;
        assert (count == 8'd0)
            $display("PASSED! Count is 0 when disabled after start");
        else
            $error("FAILED! Count is not 0 when counter is disabled after start. Count is %b. Time is: %0t.", count, $time);

        enable = 1;

        #10;
        assert (count == 8'd1)
            $display("PASSED! Count is 1");
        else
            $error("FAILED! Count is not 1. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd2)
            $display("PASSED! Count is 2");
        else
            $error("FAILED! Count is not 2. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd3)
            $display("PASSED! Count is 3");
        else
            $error("FAILED! Count is not 3. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd4)
            $display("PASSED! Count is 4");
        else
            $error("FAILED! Count is not 4. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd5)
            $display("PASSED! Count is 5");
        else
            $error("FAILED! Count is not 5. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd6)
            $display("PASSED! Count is 6");
        else
            $error("FAILED! Count is not 7. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd8)
            $display("PASSED! Count is 8");
        else
            $error("FAILED! Count is not 8. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd9)
            $display("PASSED! Count is 9");
        else
            $error("FAILED! Count is not 9. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd10)
            $display("PASSED! Count is 10");
        else
            $error("FAILED! Count is not 10. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd11)
            $display("PASSED! Count is 11");
        else
            $error("FAILED! Count is not 11. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd12)
            $display("PASSED! Count is 12");
        else
            $error("FAILED! Count is not 12. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd13)
            $display("PASSED! Count is 13");
        else
            $error("FAILED! Count is not 13. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd14)
            $display("PASSED! Count is 14");
        else
            $error("FAILED! Count is not 14. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd15)
            $display("PASSED! Count is 15");
        else
            $error("FAILED! Count is not 15. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd16)
            $display("PASSED! Count is 16");
        else
            $error("FAILED! Count is not 16. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd17)
            $display("PASSED! Count is 17");
        else
            $error("FAILED! Count is not 17. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd18)
            $display("PASSED! Count is 18");
        else
            $error("FAILED! Count is not 18. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd19)
            $display("PASSED! Count is 19");
        else
            $error("FAILED! Count is not 19. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd20)
            $display("PASSED! Count is 20");
        else
            $error("FAILED! Count is not 20. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd21)
            $display("PASSED! Count is 21");
        else
            $error("FAILED! Count is not 21. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd22)
            $display("PASSED! Count is 22");
        else
            $error("FAILED! Count is not 22. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd23)
            $display("PASSED! Count is 23");
        else
            $error("FAILED! Count is not 23. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd24)
            $display("PASSED! Count is 24");
        else
            $error("FAILED! Count is not 24. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd0)
            $display("PASSED! Count is 0");
        else
            $error("FAILED! Count is not 0. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd1)
            $display("PASSED! Count is 1");
        else
            $error("FAILED! Count is not 1. Count is %d. Time is: %0t.", count, $time);

        #10;
        assert (count == 8'd2)
            $display("PASSED! Count is 2");
        else
            $error("FAILED! Count is not 2. Count is %d. Time is: %0t.", count, $time);

        #10;
        reset = 1;
        #1;
        assert (count == 8'd0)
            $display("PASSED! Count is 0 after reset");
        else
            $error("FAILED! Count is not 0 after reset. Count is %d. Time is: %0t.", count, $time);

        #5;
        reset = 0;

        #30;
        enable = 0;
        #50;
        assert (count == 8'd3)
            $display("PASSED! Count is 3 (frozen) after being disabled");
        else
            $error("FAILED! Count is 3 (frozen) after being disabled. Count is %b. Time is: %0t.", count, $time);
  
        $stop;
    end
endmodule
