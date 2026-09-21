`timescale 1 ns/1 ns

module keypad_reader_tb();
    logic       clk, reset, enable;
    logic [3:0] row;
    logic [3:0] col;
    logic [3:0][3:0] key_status;

    keypad_reader #(4, 4) dut (clk, reset, enable, col, row, key_status);

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
        reset = 1;
        enable = 1;
        col = 'b0;
        #22 reset = 0;

        // TESTING INITIAL KEYPAD STATUS
        assert(key_status == 'b0)
            $display("PASSES! key status is zero at %0t after reset", $time);
        else
            $error("FAILED! key status is not zero at %0t after reset", $time);

        // TESTING KEYPAD COUNTER
        force dut.keypad_counter.count = 20;
        #1;
        release dut.keypad_counter.count;
        #200;
        assert(dut.scan_count > 20)
            $display("PASSES! Keypad counter increases at %0t", $time);
        else
            $error("FAILED! Keypad counter does not increase at %0t", $time);

        // TESTING KEYPAD ROW SCANNING BEHAVIOUR
        #10;
        assert (row == 4'b0001)
            $display("PASSES! First row is scanned at %0t", $time);
        else
            $error("FAILED! First row is not scanned at %0t. Output is: %b", $time, row);
        #10;
        force dut.keypad_counter.count = 65535;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b0001)
            $display("PASSES! First row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! First row is not scanned at count %d. Output is: %b", dut.scan_count, row);
        #10;
        force dut.keypad_counter.count = 65536;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b0010)
            $display("PASSES! Second row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! Second row is not scanned at count %d. Output is: %b", dut.scan_count, row);
        #10;
        force dut.keypad_counter.count = 131071;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b0010)
            $display("PASSES! Second row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! Second row is not scanned at count %d. Output is: %b", dut.scan_count, row);
        #10;
        force dut.keypad_counter.count = 131072;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b0100)
            $display("PASSES! Third row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! Third row is not scanned at count %d. Output is: %b", dut.scan_count, row);
        #10;
        force dut.keypad_counter.count = 196607;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b0100)
            $display("PASSES! Third row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! Third row is not scanned at count %d. Output is: %b", dut.scan_count, row);
        #10;
        force dut.keypad_counter.count = 196608;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b1000)
            $display("PASSES! Fourth row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! Fourth row is not scanned at count %d. Output is: %b", dut.scan_count, row);
        #10;
        force dut.keypad_counter.count = 262143;
        #1;
        release dut.keypad_counter.count;
        #1;
        assert (row == 4'b1000)
            $display("PASSES! Fourth row is scanned at count %d", dut.scan_count);
        else
            $error("FAILED! Fourth row is not scanned at count %d. Output is: %b", dut.scan_count, row);

        #100;

        // KEYPAD RESET AND ENABLE BEHAVIOUR
        assert(dut.scan_count > 0 && dut.scan_count < 262144)
            $display("PASSES! Keypad counter increases and also reset at %0t", $time);
        else
            $error("FAILED! Keypad counter does not increase or did not reset at %0t", $time);
        assert(row == 4'b0001)
            $display("PASSES! After reset, keypad is initialized at scanning row 1 at %0t", $time);
        else
            $error("FAILED! After reset, keypad is not at scanning row 1 at %0t: row output is %b", $time, row);
        #10;
        enable = 0;
        #100;
        assert(dut.scan_count <= $past(dut.scan_count, 10, 'b1, @(posedge clk))) // as keypad output is CL dependent on count, this shows that scan behaviour is enable-able
            $display("PASSES! Keypad counter frozen when disabled at %0t", $time);
        else
            $error("FAILED! Keypad counter not frozen when disabled at %0t: value is %0d, 100 cycles ago count was", $time, dut.scan_count, $past(dut.scan_count, 10, 'b1, @(posedge clk)));

        // SINGLE/MULTIPLE KEYPRESS TESTING
        enable = 1;
        col = 'b0001;
        force dut.scan_count = 'd65535;
        #170;
        assert(key_status == 'b0000_0000_0000_0001)
            $display("PASSES! key row 0 col 0 pressed at %0t", $time);
        else
            $display("FAILED! key row 0 col 0 not pressed at %0t. Key(s) pressed: %b", $time, key_status);
        col = 'b0000;
        #80;
        assert(key_status == 'b0000_0000_0000_0001)
            $display("PASSES! key row 0 col 0 still pressed at %0t", $time);
        else
            $display("FAILED! key row 0 col 0 not still pressed at %0t. Key(s) pressed: %b", $time, key_status);
        #90;
        assert(key_status == 'b0000_0000_0000_0000)
            $display("PASSES! key row 0 col 0 not pressed at %0t", $time);
        else
            $display("FAILED! key row 0 col 0 not not pressed at %0t. Key(s) pressed: %b", $time, key_status);
        col = 'b1111;
        #80;
        assert(key_status == 'b0000_0000_0000_0000)
            $display("PASSES! key row 0 col 0 not pressed at %0t", $time);
        else
            $display("FAILED! key row 0 col 0 not not pressed at %0t. Key(s) pressed: %b", $time, key_status);
        #90;
        assert(key_status == 'b0000_0000_0000_1111)
            $display("PASSES! key row 0 col 0..=3 pressed at %0t", $time);
        else
            $display("FAILED! key row 0 col 0..=3 not pressed at %0t. Key(s) pressed: %b", $time, key_status);
        col = 'b1001;
        force dut.scan_count = 'd65536; // expect nothing to happen
        #98;
        assert(key_status == 'b0000_0000_0000_1111)
            $display("PASSES! key row 0 col 0..=3 pressed at %0t", $time);
        else
            $display("FAILED! key row 0 col 0..=3 not pressed at %0t. Key(s) pressed: %b", $time, key_status);
        force dut.scan_count = 'd262143;
        #170;
        assert(key_status == 'b1001_0000_0000_1111)
            $display("PASSES! key row 0,3 col 0..=3,0,3 pressed at %0t", $time);
        else
            $display("FAILED! key row 0,3 col 0..=3,0,3 not pressed at %0t. Key(s) pressed: %b", $time, key_status);
        col = 'b1111;
        #80;
        assert(key_status == 'b1001_0000_0000_1111)
            $display("PASSES! key row 0,3 col 0..=3,0,3 pressed at %0t", $time);
        else
            $display("FAILED! key row 0,3 col 0..=3,0,3 not pressed at %0t. Key(s) pressed: %b", $time, key_status);
        #90;
        assert(key_status == 'b1111_0000_0000_1111)
            $display("PASSES! key row 0,3 col 0..=3 pressed at %0t", $time);
        else
            $display("FAILED! key row 0,3 col 0..=3 not pressed at %0t. Key(s) pressed: %b", $time, key_status);
        force dut.scan_count = 'd131071;
        #170;
        assert(key_status == 'b1111_0000_1111_1111)
            $display("PASSES! key row 0,1,3 col 0..=3 pressed at %0t", $time);
        else
            $display("FAILED! key row 0,1,3 col 0..=3 not pressed at %0t. Key(s) pressed: %b", $time, key_status);
        force dut.scan_count = 'd196607;
        #170;
        assert(key_status == 'b1111_1111_1111_1111)
            $display("PASSES! key row 0..=3 col 0..=3 pressed at %0t", $time);
        else
            $display("FAILED! key row 0..=3 col 0..=3 not pressed at %0t. Key(s) pressed: %b", $time, key_status);
        col = 'b0000;
        force dut.scan_count = 'd0;
        #170;
        assert(key_status == 'b1111_1111_1111_1111)
            $display("PASSES! key row 0..=3 col 0..=3 pressed at %0t", $time);
        else
            $display("FAILED! key row 0..=3 col 0..=3 not pressed at %0t. Key(s) pressed: %b", $time, key_status);
        #170;
        force dut.scan_count = 'd65535;
        #170;
        force dut.scan_count = 'd131071;
        #170;
        force dut.scan_count = 'd196607;
        #170;
        release dut.scan_count;
        assert(key_status == 'b1111_0000_0000_0000)
            $display("PASSES! key row 0..=2 col 0..=3 pressed at %0t", $time);
        else
            $display("FAILED! key row 0..=2 col 0..=3 not pressed at %0t. Key(s) pressed: %b", $time, key_status);
        reset = 1;
        #30;
        assert(key_status == 'b0)
            $display("PASSES! key status is zero at %0t after reset", $time);
        else
            $error("FAILED! key status is not zero at %0t after reset", $time);


       $stop;
    end
endmodule
