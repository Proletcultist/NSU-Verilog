module alu_tb #(
    parameter int W = 8,
    parameter int SEED = 0
);
    const logic [2:0] ADD_OP = 3'b000;
    const logic [2:0] SUB_OP = 3'b001;
    const logic [2:0] AND_OP = 3'b010;
    const logic [2:0] OR_OP  = 3'b011;
    const logic [2:0] XOR_OP = 3'b100;
    const logic [2:0] SLL_OP = 3'b101;
    const logic [2:0] SRL_OP = 3'b110;
    const logic [2:0] SLT_OP = 3'b111;

    logic [W-1:0] a, b, y;
    logic [2:0]   op;
    logic zero, negative, carry, overflowl;

    alu #(W) dut(a, b, op, y, zero, negative, carry, overflow);

    task run_checks();
        int seed;
        seed = SEED;

        if (W < 2 || W > 32) begin
            $fatal(1, "Unsupported alu_tb width: %d, allowed only values from 2 to 32", W);
        end

        // Combinations of 0s and 1s
        check_case(0, 0);
        check_case(0, 1);
        check_case(1, 1);

        // All-ones
        check_case({W{1'b1}}, 0);
        check_case({W{1'b1}}, 1);
        check_case({W{1'b1}}, {W{1'b1}});

        // Min/max signed
        check_case({1'b0, {(W-1){1'b1}}}, 0);
        check_case({1'b0, {(W-1){1'b1}}}, 1);
        check_case({1'b1, {(W-1){1'b0}}}, 0);
        check_case({1'b1, {(W-1){1'b0}}}, 1);
        check_case({1'b1, {(W-1){1'b0}}}, {1'b0, {(W-1){1'b1}}});

        // Carry
        check_case({{(W-1){1'b1}}, 1'b0}, 2);
 
        // Borrow
        check_case(1, 2);
        check_case(2, 1);

        // Signed overflow
        check_case({1'b1, {(W-1){1'b0}}}, {1'b1, {(W-1){1'b0}}});
        check_case({1'b1, {(W-1){1'b0}}}, 1);

        check_case((W)'($random(seed)), (W)'($random(seed)));
    endtask

    task check_case(
        logic [W-1:0] i_a,
        logic [W-1:0] i_b
    );
        check_case_with_op(i_a, i_b, ADD_OP);
        check_case_with_op(i_a, i_b, SUB_OP);
        check_case_with_op(i_a, i_b, AND_OP);
        check_case_with_op(i_a, i_b, OR_OP);
        check_case_with_op(i_a, i_b, XOR_OP);
        check_case_with_op(i_a, i_b, SLL_OP);
        check_case_with_op(i_a, i_b, SRL_OP);
        check_case_with_op(i_a, i_b, SLT_OP);
    endtask

    task check_case_with_op(
        logic [W-1:0] i_a,
        logic [W-1:0] i_b,
        logic [2:0] i_op
    );
        logic [W-1:0] e_y;
        logic e_zero, e_negative, e_carry, e_overflow;
        
        case (i_op)
            ADD_OP: begin
                {e_carry, e_y} = i_a + i_b;
                e_zero = (e_y == 0);
                e_negative = e_y[W-1];
                e_overflow = (i_a[W-1] == i_b[W-1] && i_a[W-1] != e_y[W-1]);
            end
            SUB_OP: begin
                logic [W-1:0] neg_b;
                neg_b = -i_b;

                {e_carry, e_y} = i_a + neg_b;
                e_zero = (e_y == 0);
                e_negative = e_y[W-1];
                e_overflow = (i_a[W-1] == neg_b[W-1] && i_a[W-1] != e_y[W-1]);
            end
            AND_OP: begin
                e_y = i_a & i_b;
                e_carry = 0;
                e_zero = (e_y == 0);
                e_negative = e_y[W-1];
                e_overflow = 0;
            end
            OR_OP: begin
                e_y = i_a | i_b;
                e_carry = 0;
                e_zero = (e_y == 0);
                e_negative = e_y[W-1];
                e_overflow = 0;
            end
            XOR_OP: begin
                e_y = i_a ^ i_b;
                e_carry = 0;
                e_zero = (e_y == 0);
                e_negative = e_y[W-1];
                e_overflow = 0;
            end
            SLL_OP: begin
                int shamt;
                shamt = i_b % W;

                e_y = i_a << shamt;
                e_carry = 0;
                e_zero = (e_y == 0);
                e_negative = e_y[W-1];
                e_overflow = 0;
            end
            SRL_OP: begin
                int shamt;
                shamt = i_b % W;

                e_y = i_a >> shamt;
                e_carry = 0;
                e_zero = (e_y == 0);
                e_negative = e_y[W-1];
                e_overflow = 0;
            end
            SLT_OP: begin
                e_y = $signed(i_a) < $signed(i_b);
                e_carry = 0;
                e_zero = (e_y == 0);
                e_negative = e_y[W-1];
                e_overflow = 0;
            end
        endcase

        a = i_a;
        b = i_b;
        op = i_op;

        # 20 assert(
            e_y == y &&
            e_zero == zero &&
            e_negative == negative &&
            e_carry == carry &&
            e_overflow == overflow
        ) $display("ALU with width %d passsed test for a=%d, b=%d, op=%b", W, i_a, i_b, i_op);
        else $fatal(1,
            {"Assertion form ALU with width %d faled:\n",
            "Inputs: a=%d, b=%d, op=%b\n",
            "Expected: y=%d, zero=%b, negative=%b, carry=%b, overflow=%b\n",
            "Got:      y=%d, zero=%b, negative=%b, carry=%b, overflow=%b"},
            W, i_a, i_b, i_op, 
            e_y, e_zero, e_negative, e_carry, e_overflow,
            y, zero, negative, carry, overflow
        );
    endtask
endmodule
