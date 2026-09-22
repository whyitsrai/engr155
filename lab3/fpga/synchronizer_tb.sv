`timescale 1 ns/1 ns

module synchronizer_tb();
    // does not test for error handling, only for expected functionality
    logic clk;
    logic async, sync;

    synchronizer #(1, 2) dut(clk, async, sync);

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
        #8;
        async = 1;
        #10
        assert(dut.intermediate_vals[0] == 1)
            $display("PASSES! Intermediate stage is 1");
        else
            $error("FAILED! Intermediate stage of synchronizer is not 1 after 1 clock cycle, is %0b", dut.intermediate_vals[0]);
        #10
        assert(sync == 1)
            $display("PASSES! Output stage is 1");
        else
            $error("FAILED! Output stage of synchronizer is not 1 after 2 clock cycles, is %0b", sync);
        async = 0;
        #10
        assert(dut.intermediate_vals[0] == 0)
            $display("PASSES! Intermediate stage is 0");
        else
            $error("FAILED! Intermediate stage of synchronizer is not 0 after 1 clock cycle, is %0b", dut.intermediate_vals[0]);
        assert(sync == 1)
            $display("PASSES! Output stage is still 1 despite input changing");
        else
            $error("FAILED! Output stage of synchronizer is not 1 despite only 1 clk of change, is %0b", sync);
        #10
        assert(sync == 0)
            $display("PASSES! Output stage is now updated to 0 afterinput changing");
        else
            $error("FAILED! Output stage of synchronizer is not updated to 0 after 2 clk of change, is %0b", sync);

       $stop;
    end
endmodule
