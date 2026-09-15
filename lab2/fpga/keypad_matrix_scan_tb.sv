`timescale 1 ns/1 ns

module keypad_matrix_scan_tb();
    logic       clk, reset, enable;
    logic [3:0] row; // 4 row keypad matrix

    keypad_matrix_scan #(4, 2) dut (clk, reset, enable, row);

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
        reset = 1;
        enable = 1;
        #22 reset = 0;

        force dut.keypad_counter.count = 20;
        #1;
        release dut.keypad_counter.count;

        #200;
        assert(dut.scan_count > 20)
            $display("PASSES! Keypad counter increases at %0t", $time);
        else
            $error("FAILED! Keypad counter does not increase at %0t", $time);

        #10;
        assert (row == 4'b0001)
            $display("PASSES! First row is scanned at %0t", $time);
        else
            $error("FAILED! First row is not scanned at %0t. Output is: %b", $time, row);

        #10;
        force dut.keypad_counter.count = 5999999;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b0001)
            $display("PASSES! First row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! First row is not scanned at count %d. Output is: %b", dut.scan_count, row);

        #10;
        force dut.keypad_counter.count = 6000000;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b0010)
            $display("PASSES! Second row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! Second row is not scanned at count %d. Output is: %b", dut.scan_count, row);

        #10;
        force dut.keypad_counter.count = 11999999;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b0010)
            $display("PASSES! Second row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! Second row is not scanned at count %d. Output is: %b", dut.scan_count, row);

        #10;
        force dut.keypad_counter.count = 12000000;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b0100)
            $display("PASSES! Third row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! Third row is not scanned at count %d. Output is: %b", dut.scan_count, row);

        #10;
        force dut.keypad_counter.count = 17999999;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b0100)
            $display("PASSES! Third row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! Third row is not scanned at count %d. Output is: %b", dut.scan_count, row);

        #10;
        force dut.keypad_counter.count = 18000000;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b1000)
            $display("PASSES! Fourth row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! Fourth row is not scanned at count %d. Output is: %b", dut.scan_count, row);
        
        #10;
        force dut.keypad_counter.count = 23999999;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b1000)
            $display("PASSES! Fourth row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! Fourth row is not scanned at count %d. Output is: %b", dut.scan_count, row);

        #100;
        assert(dut.scan_count > 0 && dut.scan_count < 24000000)
            $display("PASSES! Keypad counter increases and also reset at %0t", $time);
        else
            $error("FAILED! Keypad counter does not increase or did not reset at %0t", $time);
        assert(row == 4'b0001)
            $display("PASSES! After reset, keypad is initialized at scanning row 1 at %0t", $time);
        else
            $error("FAILED! After reset, keypad is not at scanning row 1 at %0t: row output is %b", $time, row);

        #10;
        enable = 0;
        force dut.keypad_counter.count = 0;
        #1;
        release dut.keypad_counter.count;
        #100;
        assert(dut.scan_count < 3) // as keypad output is CL dependent on count, this shows that scan behaviour is enable-able
            $display("PASSES! Keypad counter frozen when disabled at %0t", $time);
        else
            $error("FAILED! Keypad counter not frozen when disabled at %0t: value is %d", $time, dut.scan_count);
       $stop;
    end
endmodule
