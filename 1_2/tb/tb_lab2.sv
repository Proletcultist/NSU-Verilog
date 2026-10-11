module tb_lab2;
    logic [3:0] d0, d1, y;
    logic sel;

    mux2 mux (d0, d1, sel, y);

    logic [0:1] code;
    logic enable;
    logic [3:0] onehot;

    decoder2to4 dec (code, enable, onehot);

    initial begin
        for (int t_d0 = 0; t_d0 < 16; t_d0++) begin
            for (int t_d1 = 0; t_d1 < 16; t_d1++) begin
                test_mux2_4(
                    .t_d0(4'(t_d0)),
                    .t_d1(4'(t_d1)),
                    .t_sel(1'b0),
                    .e_y(4'(t_d0))
                );
                
                test_mux2_4(
                    .t_d0(4'(t_d0)),
                    .t_d1(4'(t_d1)),
                    .t_sel(1'b1),
                    .e_y(4'(t_d1))
                );
            end
        end

        for (int t_code = 0; t_code < 4; t_code++) begin
            test_decoder2to4(
                .t_code(2'(t_code)),
                .t_enable(1'b0),
                .e_onehot(4'b0)
            );

            test_decoder2to4(
                .t_code(2'(t_code)),
                .t_enable(1'b1),
                .e_onehot(4'b1 << t_code)
            );
        end

        $display("PASSED ALL TESTS");
    end

    task test_mux2_4(
        logic [3:0] t_d0,
        logic [3:0] t_d1, 
        logic t_sel,
        logic [3:0] e_y
    );
        d0 = t_d0;
        d1 = t_d1;
        sel = t_sel;

        # 10 assert(
            !$isunknown(y) &&
            y == e_y
        ) $display("Mux2 passed test for d0=%b, d1=%b, sel=%b", t_d0, t_d1, t_sel);
        else $fatal(1,
            {"Asserion for mux2 failed:\n",
            "Inputs: d0=%b, d1=%b, sel=%b\n",
            "Expected: y=%b\n",
            "Got y=%b"},
            t_d0, t_d1, t_sel, e_y, y
        );
    endtask

    task test_decoder2to4(
        logic [0:1] t_code,
        logic t_enable,
        logic [3:0] e_onehot
    );
        code = t_code;
        enable = t_enable;

        # 10 assert(
            !$isunknown(onehot) &&
            (!t_enable || $onehot(onehot)) &&
            onehot == e_onehot
        ) $display("Decoder2to4 passed test for code=%b, enable=%b", t_code, t_enable);
        else $fatal(1,
            {"Asserion for decoder2to4 fauled:\n",
            "Inputs: code=%b, enable=%b\n",
            "Expected: onehot=%b\n",
            "Got: onehot=%b"},
            t_code, t_enable, e_onehot, onehot
        );
    endtask
endmodule
