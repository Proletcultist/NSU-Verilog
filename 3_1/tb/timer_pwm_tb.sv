module timer_pwm_tb #(
    parameter int W = 16
);
    `define HALF_TICK_DURATION 4
    `define TICK_DURATION ((`HALF_TICK_DURATION) * 2)

    logic clk, rst, enable;
    logic [W-1:0] period, duty;
    logic tick, pwm;

    timer_pwm #(W) dut (clk, rst, enable, period, duty, tick, pwm);

    int time_cnt;

    task reset_dut();
        rst = 1'b1;
        #`TICK_DURATION;
        rst = 1'b0;
    endtask

    task one_period_test(logic [W-1:0] t_period);
        logic [W-1:0] t_period_eff;
        t_period_eff = t_period > 1 ? t_period : 1;

        $display("START PERIOD %d TEST --------------------------------------------------------------", t_period_eff);

        enable = 1'b0;
        reset_dut();

        period = t_period;
        duty = '0;
        enable = 1'b1;

        for (int i = 0; i < t_period_eff - 1; i++) begin
            #`TICK_DURATION;
            assert(pwm == 0 && tick == 0);
            else $fatal(1, "Assertion failed, expected pwm=0, tick=0 on tick %d of period %d", i, t_period_eff);
        end

        #`TICK_DURATION;
        assert(pwm == 0 && tick == 1);
        else $fatal(1, "Assertion failed, expected pwm=0, tick=1 on tick %d of period %d", t_period_eff - 1, t_period_eff);

        $display("PASSED");
    endtask

    initial begin
        clk = 0;
        forever #`HALF_TICK_DURATION clk = !clk;
    end

    initial begin
        time_cnt = 0;
        forever begin
            $display("[Tick %d] rst=%b, enable=%b, period=%d, duty=%d, tick=%b, pwm=%b", time_cnt, rst, enable, period, duty, tick, pwm);
            time_cnt++;
            #`TICK_DURATION;
        end
    end

    initial begin
        rst = 0;
        enable = 0;
        period = 'd2;
        duty = 'd0;

        one_period_test('d1);
        one_period_test('d2);
        one_period_test('d5);
        one_period_test('d128);

        $finish(0);
    end

endmodule
