`timescale 1 ns/1 ns

module onehot_to_bin_tb();
    logic [15:0] keymap;
    logic [3:0] encoded;

    onehot_to_bin dut(keymap, encoded); // tests all VALID inputs (and nothing invalid)

    initial begin
        keymap = 16'b0000_0000_0000_0001;
        #1;
        assert (encoded == 4'b0001)
            $display("PASSES! row 1 col 1 gets encoding %b", encoded);
        else
            $error("FAILED! row 1 col 1 gets encoding %b", encoded);
        keymap = 16'b0000_0000_0000_0010;
        #1;
        assert (encoded == 4'b0010)
            $display("PASSES! row 1 col 2 gets encoding %b", encoded);
        else
            $error("FAILED! row 1 col 2 gets encoding %b", encoded);
        keymap = 16'b0000_0000_0000_0100;
        #1;
        assert (encoded == 4'b0011)
            $display("PASSES! row 1 col 3 gets encoding %b", encoded);
        else
            $error("FAILED! row 1 col 3 gets encoding %b", encoded);
        keymap = 16'b0000_0000_0000_1000;
        #1;
        assert (encoded == 4'b1010)
            $display("PASSES! row 1 col 4 gets encoding %b", encoded);
        else
            $error("FAILED! row 1 col 4 gets encoding %b", encoded);

        keymap = 16'b0000_0000_0001_0000;
        #1;
        assert (encoded == 4'b0100)
            $display("PASSES! row 2 col 1 gets encoding %b", encoded);
        else
            $error("FAILED! row 2 col 1 gets encoding %b", encoded);
        keymap = 16'b0000_0000_0010_0000;
        #1;
        assert (encoded == 4'b0101)
            $display("PASSES! row 2 col 2 gets encoding %b", encoded);
        else
            $error("FAILED! row 2 col 2 gets encoding %b", encoded);
        keymap = 16'b0000_0000_0100_0000;
        #1;
        assert (encoded == 4'b0110)
            $display("PASSES! row 2 col 3 gets encoding %b", encoded);
        else
            $error("FAILED! row 2 col 3 gets encoding %b", encoded);
        keymap = 16'b0000_0000_1000_0000;
        #1;
        assert (encoded == 4'b1011)
            $display("PASSES! row 2 col 4 gets encoding %b", encoded);
        else
            $error("FAILED! row 2 col 4 gets encoding %b", encoded);

        keymap = 16'b0000_0001_0000_0000;
        #1;
        assert (encoded == 4'b0111)
            $display("PASSES! row 3 col 1 gets encoding %b", encoded);
        else
            $error("FAILED! row 3 col 1 gets encoding %b", encoded);
        keymap = 16'b0000_0010_0000_0000;
        #1;
        assert (encoded == 4'b1000)
            $display("PASSES! row 3 col 2 gets encoding %b", encoded);
        else
            $error("FAILED! row 3 col 2 gets encoding %b", encoded);
        keymap = 16'b0000_0100_0000_0000;
        #1;
        assert (encoded == 4'b1001)
            $display("PASSES! row 3 col 3 gets encoding %b", encoded);
        else
            $error("FAILED! row 3 col 3 gets encoding %b", encoded);
        keymap = 16'b0000_1000_0000_0000;
        #1;
        assert (encoded == 4'b1100)
            $display("PASSES! row 3 col 4 gets encoding %b", encoded);
        else
            $error("FAILED! row 3 col 4 gets encoding %b", encoded);

        keymap = 16'b0001_0000_0000_0000;
        #1;
        assert (encoded == 4'b1110)
            $display("PASSES! row 4 col 1 gets encoding %b", encoded);
        else
            $error("FAILED! row 4 col 1 gets encoding %b", encoded);
        keymap = 16'b0010_0000_0000_0000;
        #1;
        assert (encoded == 4'b0000)
            $display("PASSES! row 4 col 2 gets encoding %b", encoded);
        else
            $error("FAILED! row 4 col 2 gets encoding %b", encoded);
        keymap = 16'b0100_0000_0000_0000;
        #1;
        assert (encoded == 4'b1111)
            $display("PASSES! row 4 col 3 gets encoding %b", encoded);
        else
            $error("FAILED! row 4 col 3 gets encoding %b", encoded);
        keymap = 16'b1000_0000_0000_0000;
        #1;
        assert (encoded == 4'b1101)
            $display("PASSES! row 4 col 4 gets encoding %b", encoded);
        else
            $error("FAILED! row 4 col 4 gets encoding %b", encoded);

       $stop;
    end
endmodule