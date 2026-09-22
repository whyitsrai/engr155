`timescale 1 ns/1 ns

module keypress_fsm_tb();
    logic clk, reset, enable;
    logic [3:0] key_status; // 4 key total "keypad" matrix
    logic display_next_char;

    keypress_fsm #(4) dut(clk, reset, enable, key_status, display_next_char);

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
        reset = 1;
        enable = 1;
        #8;
        reset = 0;

        key_status = 'b0000;
        #30;
        assert(dut.state == 'b10)
            $display("PASSES! FSM waiting for one key to be pressed");
        else
            $error("FAILED! FSM not waiting for one key to be pressed, state is %b", dut.state);

        key_status = 'b1001;
        #30;
        assert(dut.state == 'b10)
            $display("PASSES! FSM waiting for one key to be pressed");
        else
            $error("FAILED! FSM not waiting for one key to be pressed, state is %b", dut.state);

        key_status = 'b1011;
        #30;
        assert(dut.state == 'b10)
            $display("PASSES! FSM waiting for one key to be pressed");
        else
            $error("FAILED! FSM not waiting for one key to be pressed, state is %b", dut.state);

        key_status = 'b0001;
        #20; // one extra clock cycle of delay due to internal reg
        assert(dut.state == 'b00)
            $display("PASSES! FSM updating display because one key was pressed");
        else
            $error("FAILED! FSM not updating display because one key was pressed, state is %b", dut.state);
        #20;
        assert(dut.state == 'b01)
            $display("PASSES! FSM no longer updating display because one key is being held");
        else
            $error("FAILED! FSM not no longer updating display because one key is being held, state is %b", dut.state);

        key_status = 'b1101;
        #30;
        assert(dut.state == 'b10)
            $display("PASSES! FSM waiting for one key to be pressed");
        else
            $error("FAILED! FSM not waiting for one key to be pressed, state is %b", dut.state);

        force dut.state = 'b00; // force display state
        #1
        assert(display_next_char == 1)
            $display("PASSES! Character update asserted when in corresponding state");
        else
            $error("FAILED! Character update not asserted when in corresponding state");
        #10
        enable = 0;
        #30
        release dut.state;
        assert(display_next_char == 1)
            $display("PASSES! State frozen when not enabled");
        else
            $display("FAILED! State not frozen when not enabled");
        #10
        reset = 1;
        #10
        reset = 0;
        #5
        assert(dut.state == 'b10)
            $display("PASSES! FSM correctly reset");
        else
            $error("FAILED! FSM not reset, state is %b", dut.state);

       $stop;
    end

endmodule