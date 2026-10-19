module tb;
    alu_tb #(8) alu_8tb();
    alu_tb #(32) alu_32tb();

    initial begin
        int unsigned seed;

        if (!$value$plusargs("SEED=%d", seed)) begin
            seed = 1;
        end

        alu_8tb.run_checks(
            .seed(seed),
            .random_tests(1000)
        );

        alu_32tb.run_checks(
            .seed(seed),
            .random_tests(300)
        );

        $display("PASSED ALL TESTS");
        $display("Test seed: %d", seed);
    end
endmodule
