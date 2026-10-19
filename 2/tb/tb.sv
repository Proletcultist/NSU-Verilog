module tb;
    alu_tb #(8, 0) alu_8tb();

    initial begin
        alu_8tb.run_checks();
    end
endmodule
