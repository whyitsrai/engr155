`timescale 1 ns/1 ns

module keypad_matrix_scan_tb();
    logic       clk, reset, enable;
    logic [2:0] row; // 3 row keypad matrix

    keypad_matrix_scan #(3, 2) dut (clk, reset, enable, row);

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
            $error("Failed! Keypad counter does not increase at %0t", $time);

        #10;
        assert (row == 3'b001)
            $display("PASSES! First row is scanned at %0t", $time);
        else
            $error("Failed! First row is not scanned at %0t. Output is: %b", $time, row);

        #10;
        force dut.keypad_counter.count = 7999999;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 3'b001)
            $display("PASSES! First row is scanned at count %d", dut.scan_count);
        else
            $error("Failed! First row is not scanned at count %d. Output is: %b", dut.scan_count, row);

        #10;
        force dut.keypad_counter.count = 8000000;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 3'b010)
            $display("PASSES! Second row is scanned at count %d", dut.scan_count);
        else
            $error("Failed! Second row is not scanned at count %d. Output is: %b", dut.scan_count, row);

        #10;
        force dut.keypad_counter.count = 15999999;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 3'b010)
            $display("PASSES! Second row is scanned at count %d", dut.scan_count);
        else
            $error("Failed! Second row is not scanned at count %d. Output is: %b", dut.scan_count, row);

        #10;
        force dut.keypad_counter.count = 16000000;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 3'b100)
            $display("PASSES! Third row is scanned at count %d", dut.scan_count);
        else
            $error("Failed! Third row is not scanned at count %d. Output is: %b", dut.scan_count, row);

        #10;
        force dut.keypad_counter.count = 23999999;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 3'b100)
            $display("PASSES! Third row is scanned at count %d", dut.scan_count);
        else
            $error("Failed! Third row is not scanned at count %d. Output is: %b", dut.scan_count, row);

        #100;
        assert(dut.scan_count > 0 && dut.scan_count < 24000000)
            $display("PASSES! Keypad counter increases and also reset at %0t", $time);
        else
            $error("Failed! Keypad counter does not increase or did not reset at %0t", $time);

        // consider testing a reset in the middle. Is count actually reset? This is a stretch item

       $stop;
    end
endmodule
