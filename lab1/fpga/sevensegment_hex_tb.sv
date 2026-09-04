module sevensegment_hex_tb();
    logic   [3:0]   digit;    // 4-bit input for digits
    logic   [6:0]   segments; // 7-segment display

    sevensegment_hex dut (digit, segments);

    // apply stimuli and check outputs
    initial begin
        #1;
        assert (segments == 7'b0000000) // 0
            $display("PASSES! Unknown input results in all off");
        else
            $error("Failed! Unknown input does not result in all off. Output is: %b", segments);

        digit = 4'b0000;
        #1;
        assert (segments == 7'b1111110) // 0
            $display("PASSES! Digit 0 displays properly");
        else
            $error("Failed! Digit 0 is wrong. Output is: %b", segments);

        digit = 4'b0001;
        #1;
        assert (segments == 7'b0110000) // 1
        $display("PASSES! Digit 1 displays properly");
        else
            $error("Failed! Digit 1 is wrong. Output is: %b", segments);

        digit = 4'b0010;
        #1;
        assert (segments == 7'b1101101) // 2
        $display("PASSES! Digit 2 displays properly");
        else
            $error("Failed! Digit 2 is wrong. Output is: %b", segments);

        digit = 4'b0011;
        #1;
        assert (segments == 7'b1111001) // 3
        $display("PASSES! Digit 3 displays properly");
        else
            $error("Failed! Digit 3 is wrong. Output is: %b", segments);

        digit = 4'b0100;
        #1;
        assert (segments == 7'b0110011) // 4
        $display("PASSES! Digit 4 displays properly");
        else
            $error("Failed! Digit 4 is wrong. Output is: %b", segments);

        digit = 4'b0101;
        #1;
        assert (segments == 7'b1011011) // 5
        $display("PASSES! Digit 5 displays properly");
        else
            $error("Failed! Digit 5 is wrong. Output is: %b", segments);

        digit = 4'b0110;
        #1;
        assert (segments == 7'b1011111) // 6
        $display("PASSES! Digit 6 displays properly");
        else
            $error("Failed! Digit 6 is wrong. Output is: %b", segments);

        digit = 4'b0111;
        #1;
        assert (segments == 7'b1110000) // 7
        $display("PASSES! Digit 7 displays properly");
        else
            $error("Failed! Digit 7 is wrong. Output is: %b", segments);

        digit = 4'b1000;
        #1;
        assert (segments == 7'b1111111) // 8
        $display("PASSES! Digit 8 displays properly");
        else
            $error("Failed! Digit 8 is wrong. Output is: %b", segments);

        digit = 4'b1001;
        #1;
        assert (segments == 7'b1111011) // 9
        $display("PASSES! Digit 9 displays properly");
        else
            $error("Failed! Digit 9 is wrong. Output is: %b", segments);

        digit = 4'b1010;
        #1;
        assert (segments == 7'b1110111) // A
        $display("PASSES! Digit A displays properly");
        else
            $error("Failed! Digit A is wrong. Output is: %b", segments);

        digit = 4'b1011;
        #1;
        assert (segments == 7'b0011111) // b
        $display("PASSES! Digit b displays properly");
        else
            $error("Failed! Digit b is wrong. Output is: %b", segments);

        digit = 4'b1100;
        #1;
        assert (segments == 7'b0001101) // c
        $display("PASSES! Digit c displays properly");
        else
            $error("Failed! Digit c is wrong. Output is: %b", segments);

        digit = 4'b1101;
        #1;
        assert (segments == 7'b0111101) // d
        $display("PASSES! Digit d displays properly");
        else
            $error("Failed! Digit d is wrong. Output is: %b", segments);

        digit = 4'b1110;
        #1;
        assert (segments == 7'b1001111) // E
        $display("PASSES! Digit E displays properly");
        else
            $error("Failed! Digit E is wrong. Output is: %b", segments);

        digit = 4'b1111;
        #1;
        assert (segments == 7'b1000111) // F
        $display("PASSES! Digit F displays properly");
        else
            $error("Failed! Digit F is wrong. Output is: %b", segments);

        #1;
       $stop;
    end
endmodule
