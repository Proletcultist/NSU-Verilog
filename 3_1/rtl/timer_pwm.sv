module timer_pwm #(
    parameter int W = 16
) (
    input  logic         clk,
    input  logic         rst,
    input  logic         enable,
    input  logic [W-1:0] period,
    input  logic [W-1:0] duty,
    output logic         tick,
    output logic         pwm
);

    logic [W-1:0] cnt;

    logic [W-1:0] period_eff, duty_eff;

    always_comb begin
        period_eff = period > 1 ? period : 1;
        duty_eff = duty > period_eff ? period_eff : duty;

        pwm = enable && !rst && cnt < duty_eff;
    end

    always_ff @(posedge clk) begin
        if (!enable || rst) begin
            cnt <= 'b0;
            tick <= 1'b0;
        end else if (cnt == period_eff - 1'b1) begin
            cnt <= 'b0;
            tick <= 1'b1;
        end else begin
            cnt <= cnt + 1'b1;
            tick <= 1'b0;
        end
    end

endmodule
