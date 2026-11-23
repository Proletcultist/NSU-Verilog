`timescale 1ns/1ps

module stopwatch_tb;
    localparam int CLK_PERIOD = 10;
    localparam int TICK_10MS_CYCLES = 5; // 1 tick_10ms pulse every 5 clk cycles

    int clk_cnt;

    logic clk;
    logic rst;
    logic tick_10ms;
    logic start_stop_pulse;
    logic clear_pulse;
    logic lap_pulse;
    logic running;
    logic lap_active;
    logic [3:0] d3, d2, d1, d0;

    stopwatch_core dut (
        .clk(clk),
        .rst(rst),
        .tick_10ms(tick_10ms),
        .start_stop_pulse(start_stop_pulse),
        .clear_pulse(clear_pulse),
        .lap_pulse(lap_pulse),
        .running(running),
        .lap_active(lap_active),
        .d3(d3),
        .d2(d2),
        .d1(d1),
        .d0(d0)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        tick_10ms = 1'b0;
        forever begin
            repeat (TICK_10MS_CYCLES - 1) @(posedge clk);
            tick_10ms <= 1'b1;
            @(posedge clk);
            tick_10ms <= 1'b0;
        end
    end

    initial begin
        clk_cnt = 0;
        forever begin
            @(posedge clk);
            #1;
            $display("[Cycle %0d] rst=%b run=%b lap=%b tick=%b | time=%0d%0d.%0d%0d",
                     clk_cnt, rst, running, lap_active, tick_10ms, d3, d2, d1, d0);
            assert (d0 <= 4'd9 && d1 <= 4'd9 && d2 <= 4'd9 && d3 <= 4'd9)
                else $fatal(1, "Assertion failed, invalid BCD digit detected at cycle %0d: d3=%b d2=%b d1=%b d0=%b",
                            clk_cnt, d3, d2, d1, d0);
            clk_cnt++;
        end
    end

    task apply_reset(input int cycles);
        rst <= 1'b1;
        repeat (cycles) @(posedge clk);
        rst <= 1'b0;
        #1;
    endtask

    task pulse_start_stop();
        start_stop_pulse <= 1'b1;
        @(posedge clk);
        start_stop_pulse <= 1'b0;
        #1;
    endtask

    task pulse_clear();
        clear_pulse <= 1'b1;
        @(posedge clk);
        clear_pulse <= 1'b0;
        #1;
    endtask

    task pulse_lap();
        lap_pulse <= 1'b1;
        @(posedge clk);
        lap_pulse <= 1'b0;
        #1;
    endtask

    task wait_ticks(input int n);
        repeat (n) begin
            do begin
                @(posedge clk);
            end while (!tick_10ms);
            #1;
        end
    endtask

    task check_bcd_time(input int expected_ticks, input string context_msg);
        int wrapped;
        logic [3:0] exp_d3, exp_d2, exp_d1, exp_d0;
        wrapped = expected_ticks % 10000;
        exp_d0 = wrapped % 10;
        exp_d1 = (wrapped / 10) % 10;
        exp_d2 = (wrapped / 100) % 10;
        exp_d3 = (wrapped / 1000) % 10;

        assert (d3 === exp_d3 && d2 === exp_d2 && d1 === exp_d1 && d0 === exp_d0)
            else $fatal(1, "Assertion failed, (%s) expected time=%0d%0d.%0d%0d, got %0d%0d.%0d%0d",
                        context_msg, exp_d3, exp_d2, exp_d1, exp_d0, d3, d2, d1, d0);
    endtask

    task test_reset_and_clear(input int advance_ticks = 25);
        $display("START RESET_AND_CLEAR ADVANCE_TICKS=%0d TEST --------------------------------------------------------------", advance_ticks);

        apply_reset(1);
        assert (running === 1'b0 && lap_active === 1'b0)
            else $fatal(1, "Assertion failed, expected running=0, lap_active=0 after rst, got running=%b, lap_active=%b", running, lap_active);
        check_bcd_time(0, "after initial rst");

        pulse_start_stop();
        wait_ticks(advance_ticks);
        pulse_lap();
        assert (running === 1'b1 && lap_active === 1'b1)
            else $fatal(1, "Assertion failed, expected running=1, lap_active=1 before clear, got running=%b, lap_active=%b", running, lap_active);

        pulse_clear();
        assert (running === 1'b0 && lap_active === 1'b0)
            else $fatal(1, "Assertion failed, expected running=0, lap_active=0 after clear in running mode, got running=%b, lap_active=%b", running, lap_active);
        check_bcd_time(0, "after clear in running mode");

        pulse_start_stop();
        wait_ticks(advance_ticks);
        pulse_start_stop();
        assert (running === 1'b0)
            else $fatal(1, "Assertion failed, expected running=0 after stop, got running=%b", running);
        check_bcd_time(advance_ticks, "held time before clear in stopped mode");

        pulse_clear();
        assert (running === 1'b0 && lap_active === 1'b0)
            else $fatal(1, "Assertion failed, expected running=0, lap_active=0 after clear in stopped mode, got running=%b, lap_active=%b", running, lap_active);
        check_bcd_time(0, "after clear in stopped mode");

        pulse_start_stop();
        wait_ticks(advance_ticks);
        apply_reset(1);
        assert (running === 1'b0 && lap_active === 1'b0)
            else $fatal(1, "Assertion failed, expected running=0, lap_active=0 after rst in running mode, got running=%b, lap_active=%b", running, lap_active);
        check_bcd_time(0, "after rst in running mode");

        pulse_start_stop();
        wait_ticks(advance_ticks);
        pulse_start_stop();
        apply_reset(1);
        assert (running === 1'b0 && lap_active === 1'b0)
            else $fatal(1, "Assertion failed, expected running=0, lap_active=0 after rst in stopped mode, got running=%b, lap_active=%b", running, lap_active);
        check_bcd_time(0, "after rst in stopped mode");
    endtask

    task test_start_stop_cycles(input int num_cycles = 4, input int ticks_per_run = 15, input int idle_clks = 12);
        int expected_total;
        $display("START START_STOP_CYCLES CYCLES=%0d TICKS_PER_RUN=%0d IDLE_CLKS=%0d TEST --------------------------------------------------------------",
                 num_cycles, ticks_per_run, idle_clks);

        pulse_clear();
        expected_total = 0;

        for (int i = 0; i < num_cycles; i++) begin
            pulse_start_stop();
            assert (running === 1'b1)
                else $fatal(1, "Assertion failed, expected running=1 on start cycle %0d, got running=%b", i, running);

            wait_ticks(ticks_per_run);
            expected_total += ticks_per_run;
            check_bcd_time(expected_total, $sformatf("end of run cycle %0d", i));

            pulse_start_stop();
            assert (running === 1'b0)
                else $fatal(1, "Assertion failed, expected running=0 on stop cycle %0d, got running=%b", i, running);

            repeat (idle_clks) begin
                @(posedge clk);
                #1;
                assert (running === 1'b0)
                    else $fatal(1, "Assertion failed, running changed unexpectedly while stopped in cycle %0d", i);
                check_bcd_time(expected_total, $sformatf("holding while stopped in cycle %0d", i));
            end
        end
    endtask

    task test_tick_step_and_hold(input int num_ticks = 20);
        bit sampled_tick;
        $display("START TICK_STEP_AND_HOLD NUM_TICKS=%0d TEST --------------------------------------------------------------", num_ticks);

        pulse_clear();
        pulse_start_stop();

        for (int t = 1; t <= num_ticks; t++) begin
            sampled_tick = 1'b0;
            while (!sampled_tick) begin
                @(posedge clk);
                sampled_tick = tick_10ms;
                #1;
                if (!sampled_tick) begin
                    check_bcd_time(t - 1, "clock cycle without tick_10ms must not change count");
                end else begin
                    check_bcd_time(t, "clock cycle with tick_10ms must increment count by 1");
                end
            end
        end

        pulse_start_stop();
    endtask

    task test_rollover_and_long_run(input int total_ticks = 10050);
        $display("START ROLLOVER_AND_LONG_RUN TOTAL_TICKS=%0d TEST --------------------------------------------------------------", total_ticks);

        pulse_clear();
        pulse_start_stop();

        for (int t = 1; t <= total_ticks; t++) begin
            wait_ticks(1);
            check_bcd_time(t, $sformatf("tick %0d", t));

            if (t == 10 || t == 100 || t == 1000 || t == 10000 || t == total_ticks) begin
                $display("[Milestone tick %0d] Verified time = %0d%0d.%0d%0d", t, d3, d2, d1, d0);
            end
        end

        pulse_start_stop();
    endtask

    task test_lap_active_behavior(input int pre_lap_ticks = 35, input int during_lap_ticks = 42, input int post_lap_ticks = 18);
        $display("START LAP_ACTIVE PRE=%0d DURING=%0d POST=%0d TEST --------------------------------------------------------------",
                 pre_lap_ticks, during_lap_ticks, post_lap_ticks);

        pulse_clear();
        pulse_start_stop();

        wait_ticks(pre_lap_ticks);
        check_bcd_time(pre_lap_ticks, "before lap_pulse");

        pulse_lap();
        assert (lap_active === 1'b1)
            else $fatal(1, "Assertion failed, expected lap_active=1 after lap_pulse while running, got %b", lap_active);
        check_bcd_time(pre_lap_ticks, "immediately after lap_pulse");

        for (int i = 1; i <= during_lap_ticks; i++) begin
            wait_ticks(1);
            assert (lap_active === 1'b1)
                else $fatal(1, "Assertion failed, lap_active dropped unexpectedly at lap tick %0d", i);
            check_bcd_time(pre_lap_ticks, "display must stay frozen while lap_active=1");
        end

        pulse_lap();
        assert (lap_active === 1'b0)
            else $fatal(1, "Assertion failed, expected lap_active=0 after second lap_pulse, got %b", lap_active);
        check_bcd_time(pre_lap_ticks + during_lap_ticks, "after releasing lap (background count must have continued)");

        wait_ticks(post_lap_ticks);
        check_bcd_time(pre_lap_ticks + during_lap_ticks + post_lap_ticks, "continuing after lap release");

        pulse_start_stop();
    endtask

    task test_lap_ignored_when_stopped(input int run_ticks = 27, input int stopped_clks = 15);
        $display("START LAP_IGNORED_WHEN_STOPPED RUN_TICKS=%0d STOPPED_CLKS=%0d TEST --------------------------------------------------------------",
                 run_ticks, stopped_clks);

        pulse_clear();

        pulse_lap();
        assert (lap_active === 1'b0 && running === 1'b0)
            else $fatal(1, "Assertion failed, expected lap_active=0, running=0 when lap_pulse pressed at 00.00 stopped, got lap_active=%b, running=%b",
                        lap_active, running);
        check_bcd_time(0, "lap_pulse ignored while stopped at 00.00");

        pulse_start_stop();
        wait_ticks(run_ticks);
        pulse_start_stop();

        repeat (stopped_clks) @(posedge clk);
        #1;
        pulse_lap();
        assert (lap_active === 1'b0 && running === 1'b0)
            else $fatal(1, "Assertion failed, expected lap_active=0 when lap_pulse pressed while stopped, got lap_active=%b", lap_active);
        check_bcd_time(run_ticks, "lap_pulse ignored while stopped at non-zero time");

        pulse_start_stop();
        pulse_lap();
        pulse_start_stop();
        assert (lap_active === 1'b1 && running === 1'b0)
            else $fatal(1, "Assertion failed, expected lap_active=1, running=0 after stopping in lap mode");

        pulse_lap();
        assert (lap_active === 1'b1)
            else $fatal(1, "Assertion failed, expected lap_active to remain 1 when lap_pulse pressed while stopped");
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, stopwatch_tb);

        rst = 1'b1;
        start_stop_pulse = 1'b0;
        clear_pulse = 1'b0;
        lap_pulse = 1'b0;

        test_reset_and_clear(.advance_ticks(25));
        test_start_stop_cycles(.num_cycles(4), .ticks_per_run(15), .idle_clks(12));
        test_tick_step_and_hold(.num_ticks(20));
        test_rollover_and_long_run(.total_ticks(10050));
        test_lap_active_behavior(.pre_lap_ticks(35), .during_lap_ticks(42), .post_lap_ticks(18));
        test_lap_ignored_when_stopped(.run_ticks(27), .stopped_clks(15));

        $display("ALL STOPWATCH_CORE TESTS PASSED SUCCESSFULLY --------------------------------------------------------------");
        $finish;
    end

endmodule
