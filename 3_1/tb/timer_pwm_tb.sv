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

    task change_of_period_test(
        logic [W-1:0] t_period1,
        logic [W-1:0] t_duty1,
        logic [W-1:0] t_period2,
        logic [W-1:0] t_duty2
    );
        logic [W-1:0] t_period_eff, t_duty_eff;
        t_period_eff = t_period1 > 1 ? t_period1 : 1;
        t_duty_eff = t_duty1 > t_period_eff ? t_period_eff : t_duty1;

        $display("START PERIOD=%d, DUTY=%d -> PERIOD=%d, DUTY=%d TEST --------------------------------------------------------------", t_period1, t_duty1, t_period2, t_duty2);

        enable = 1'b0;
        reset_dut();

        period = t_period1;
        duty = t_duty1;
        enable = 1'b1;

        #`HALF_TICK_DURATION;

        assert(pwm == (0 < t_duty_eff) && tick == 0);
        else $fatal(1, "Assertion failed, expected pwm=%b, tick=0 on the beginning of periods", (0 < t_duty_eff));

        for (int j = 0; j < t_period_eff - 1; j++) begin
            #`TICK_DURATION;
            assert(pwm == ((j + 1) % t_period_eff < t_duty_eff) && tick == (j + 1 == t_period_eff));
            else $fatal(1, "Assertion failed, expected pwm=%b, tick=%b on tick %d of period %d", ((j + 1) % t_period_eff < t_duty_eff), (j + 1 == t_period_eff), j, t_period_eff);
        end

        #`HALF_TICK_DURATION;

        t_period_eff = t_period2 > 1 ? t_period2 : 1;
        t_duty_eff = t_duty2 > t_period_eff ? t_period_eff : t_duty2;

        period = t_period2;
        duty = t_duty2;

        #`HALF_TICK_DURATION;

        assert(pwm == (0 < t_duty_eff) && tick == 1);
        else $fatal(1, "Assertion failed, expected pwm=%b, tick=1 on the beginning of second period", (0 < t_duty_eff));

        for (int j = 0; j < t_period_eff; j++) begin
            #`TICK_DURATION;
            assert(pwm == ((j + 1) % t_period_eff < t_duty_eff) && tick == (j + 1 == t_period_eff));
            else $fatal(1, "Assertion failed, expected pwm=%b, tick=%b on tick %d of period %d", ((j + 1) % t_period_eff < t_duty_eff), (j + 1 == t_period_eff), j, t_period_eff);
        end

        #`HALF_TICK_DURATION;

        $display("PASSED");
    endtask

    task rst_test();
        const static logic [W-1:0] t_period = 5, t_duty = 2;
        const static int unsigned reset_after = 2;

        assert(reset_after > 0);
        else $fatal(1, "Running reset in the middler of the period test with resetting after 0 cycles passed makes no sense");

        $display("START RESET IN THE MIDDLE OF THE PERIOD TEST (PERIOD=%d, DUTY=%d) --------------------------------------------------------------", t_period, t_duty);

        enable = 1'b0;
        reset_dut();

        period = t_period;
        duty = t_duty;
        enable = 1'b1;

        #`HALF_TICK_DURATION;

        assert(pwm == (0 < t_duty) && tick == 0);
        else $fatal(1, "Assertion failed, expected pwm=%b, tick=0 on the beginning of periods", (0 < t_duty));

        for (int j = 0; j < reset_after - 1; j++) begin
            #`TICK_DURATION;
            assert(pwm == ((j + 1) % t_period < t_duty) && tick == (j + 1 == t_period));
            else $fatal(1, "Assertion failed, expected pwm=%b, tick=%b on tick %d of period %d", ((j + 1) % t_period < t_duty), (j + 1 == t_period), j, t_period);
        end

        #`HALF_TICK_DURATION;

        reset_dut();

        #`HALF_TICK_DURATION;

        assert(pwm == (0 < t_duty) && tick == 0);
        else $fatal(1, "Assertion failed, expected pwm=%b, tick=0 on the beginning of periods", (0 < t_duty));

        for (int j = 0; j < t_period; j++) begin
            #`TICK_DURATION;
            assert(pwm == ((j + 1) % t_period < t_duty) && tick == (j + 1 == t_period));
            else $fatal(1, "Assertion failed, expected pwm=%b, tick=%b on tick %d of period %d", ((j + 1) % t_period < t_duty), (j + 1 == t_period), j, t_period);
        end

        #`HALF_TICK_DURATION;

        $display("PASSED");
    endtask

    task disable_test();
        const static logic [W-1:0] t_period = 5, t_duty = 2;
        const static int unsigned disable_after = 2;

        assert(disable_after > 0);
        else $fatal(1, "Running disable in the middler of the period test with disabling after 0 cycles passed makes no sense");

        $display("START DISABLE IN THE MIDDLE OF THE PERIOD TEST (PERIOD=%d, DUTY=%d) --------------------------------------------------------------", t_period, t_duty);

        enable = 1'b0;
        reset_dut();

        period = t_period;
        duty = t_duty;
        enable = 1'b1;

        #`HALF_TICK_DURATION;

        assert(pwm == (0 < t_duty) && tick == 0);
        else $fatal(1, "Assertion failed, expected pwm=%b, tick=0 on the beginning of periods", (0 < t_duty));

        for (int j = 0; j < disable_after - 1; j++) begin
            #`TICK_DURATION;
            assert(pwm == ((j + 1) % t_period < t_duty) && tick == (j + 1 == t_period));
            else $fatal(1, "Assertion failed, expected pwm=%b, tick=%b on tick %d of period %d", ((j + 1) % t_period < t_duty), (j + 1 == t_period), j, t_period);
        end

        #`HALF_TICK_DURATION;

        enable = 1'b0;
        #`TICK_DURATION;
        enable = 1'b1;

        #`HALF_TICK_DURATION;

        assert(pwm == (0 < t_duty) && tick == 0);
        else $fatal(1, "Assertion failed, expected pwm=%b, tick=0 on the beginning of periods", (0 < t_duty));

        for (int j = 0; j < t_period; j++) begin
            #`TICK_DURATION;
            assert(pwm == ((j + 1) % t_period < t_duty) && tick == (j + 1 == t_period));
            else $fatal(1, "Assertion failed, expected pwm=%b, tick=%b on tick %d of period %d", ((j + 1) % t_period < t_duty), (j + 1 == t_period), j, t_period);
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
        #`HALF_TICK_DURATION;
        forever begin
            $display("[Tick %d] rst=%b, enable=%b, period=%d, duty=%d, tick=%b, pwm=%b", time_cnt, rst, enable, period, duty, tick, pwm);
            time_cnt++;
            #`TICK_DURATION;
        end
    end

    initial begin
        rst_test();
        disable_test();

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

        change_of_period_test('d5, 'd1, 'd3, 'd2);

        $finish(0);
    end

endmodule
