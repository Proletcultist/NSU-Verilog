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

    task period_test(logic [W-1:0] t_period, logic [W-1:0] t_duty, int unsigned n);
        logic [W-1:0] t_period_eff, t_duty_eff;
        t_period_eff = t_period > 1 ? t_period : 1;
        t_duty_eff = t_duty > t_period_eff ? t_period_eff : t_duty;

        $display("START PERIOD=%d, DUTY=%d %d times TEST --------------------------------------------------------------", t_period, t_duty, n);

        enable = 1'b0;
        reset_dut();

        period = t_period;
        duty = t_duty;
        enable = 1'b1;

        #`HALF_TICK_DURATION;

        assert(pwm == (0 < t_duty_eff) && tick == 0);
        else $fatal(1, "Assertion failed, expected pwm=%b, tick=0 on the beginning of periods", (0 < t_duty_eff));

        for (int i = 0; i < n; i++) begin
            for (int j = 0; j < t_period_eff; j++) begin
                #`TICK_DURATION;
                assert(pwm == ((j + 1) % t_period_eff < t_duty_eff) && tick == (j + 1 == t_period_eff));
                else $fatal(1, "Assertion failed, expected pwm=%b, tick=%b on tick %d of period %d", ((j + 1) % t_period_eff < t_duty_eff), (j + 1 == t_period_eff), j, t_period_eff);
            end
        end

        #`HALF_TICK_DURATION;

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
        period_test('d1, 'd0, 1);
        period_test('d2, 'd0, 1);
        period_test('d5, 'd0, 1);
        period_test('d128, 'd0, 1);

        period_test('d5, 'd0, 1);
        period_test('d5, 'd1, 1);
        period_test('d5, 'd4, 1);
        period_test('d5, 'd5, 1);
        period_test('d5, 'd6, 1);

        period_test('d5, 'd0, 11);

        $finish(0);
    end

endmodule
