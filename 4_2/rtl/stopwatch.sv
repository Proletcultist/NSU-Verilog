// Priorities table:
// 1. rst || clear_pulse
// 2. start_stop
// 3. lap

module stopwatch_core (
    input logic clk,
    input logic rst,
    input logic tick_10ms,
    input logic start_stop_pulse,
    input logic clear_pulse,
    input logic lap_pulse,
    output logic running,
    output logic lap_active,
    output logic [3:0] d3, d2, d1, d0 // SS.hh
);

    logic [3:0] d0_cnt, d1_cnt, d2_cnt, d3_cnt;
    logic [3:0] d0_lap, d1_lap, d2_lap, d3_lap;
    logic lap, run;

    logic [3:0] next_d0_cnt, next_d1_cnt, next_d2_cnt, next_d3_cnt;
    logic [3:0] next_d0_lap, next_d1_lap, next_d2_lap, next_d3_lap;
    logic next_lap, next_run;

    logic inc_d0, inc_d1, inc_d2, inc_d3;

    always_comb begin
        d0 = lap ? d0_lap : d0_cnt;
        d1 = lap ? d1_lap : d1_cnt;
        d2 = lap ? d2_lap : d2_cnt;
        d3 = lap ? d3_lap : d3_cnt;

        lap_active = lap;
        running = run;
    end

    always_comb begin
        next_lap = lap;
        next_run = run;

        next_d0_cnt = d0_cnt;
        next_d1_cnt = d1_cnt;
        next_d2_cnt = d2_cnt;
        next_d3_cnt = d3_cnt;

        next_d0_lap = d0_lap;
        next_d1_lap = d1_lap;
        next_d2_lap = d2_lap;
        next_d3_lap = d3_lap;

        inc_d0 = tick_10ms;
        inc_d1 = inc_d0 && d0_cnt == 4'd9;
        inc_d2 = inc_d1 && d1_cnt == 4'd9;
        inc_d3 = inc_d2 && d2_cnt == 4'd9;

        if (rst || clear_pulse) begin
            next_lap = 0;
            next_run = 0;

            next_d0_cnt = 4'd0;
            next_d1_cnt = 4'd0;
            next_d2_cnt = 4'd0;
            next_d3_cnt = 4'd0;

            next_d0_lap = 4'd0;
            next_d1_lap = 4'd0;
            next_d2_lap = 4'd0;
            next_d3_lap = 4'd0;
        end else begin
            if (start_stop_pulse) begin
                next_run = !run;
            end

            if (run) begin
                if (lap_pulse) begin
                    next_lap = !lap;

                    if (!lap) begin
                        next_d0_lap = d0_cnt;
                        next_d1_lap = d1_cnt;
                        next_d2_lap = d2_cnt;
                        next_d3_lap = d3_cnt;
                    end
                end

                if (inc_d0) next_d0_cnt = (d0_cnt == 4'd9) ? 4'd0 : (d0_cnt + 4'd1);
                if (inc_d1) next_d1_cnt = (d1_cnt == 4'd9) ? 4'd0 : (d1_cnt + 4'd1);
                if (inc_d2) next_d2_cnt = (d2_cnt == 4'd9) ? 4'd0 : (d2_cnt + 4'd1);
                if (inc_d3) next_d3_cnt = (d3_cnt == 4'd9) ? 4'd0 : (d3_cnt + 4'd1);
            end
        end
    end

    always_ff @(posedge clk) begin
            lap <= next_lap;
            run <= next_run;

            d0_cnt <= next_d0_cnt;
            d1_cnt <= next_d1_cnt;
            d2_cnt <= next_d2_cnt;
            d3_cnt <= next_d3_cnt;

            d0_lap <= next_d0_lap;
            d1_lap <= next_d1_lap;
            d2_lap <= next_d2_lap;
            d3_lap <= next_d3_lap;
    end

endmodule
