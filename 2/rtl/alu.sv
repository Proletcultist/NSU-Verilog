module alu #(
    parameter int W = 8
) (
    input  logic [W-1:0] a,
    input  logic [W-1:0] b,
    input  logic [2:0]   op,
    output logic [W-1:0] y,
    output logic         zero,
    output logic         negative,
    output logic         carry,
    output logic         overflow
);
    parameter int SHW = $clog2(W);

    const logic [2:0] ADD_OP = 3'b000;
    const logic [2:0] SUB_OP = 3'b001;
    const logic [2:0] AND_OP = 3'b010;
    const logic [2:0] OR_OP  = 3'b011;
    const logic [2:0] XOR_OP = 3'b100;
    const logic [2:0] SLL_OP = 3'b101;
    const logic [2:0] SRL_OP = 3'b110;
    const logic [2:0] SLT_OP = 3'b111;

    always_comb begin
        zero = (y == 0);
        negative = y[W-1];
        y = 0;
        carry = 0;
        overflow = 0;

        case (op)
            ADD_OP: begin
                logic [W:0] res;
                res = (W+1)'(a) + (W+1)'(b);

                y = W'(res);
                carry = res[W];
                overflow = (a[W-1] == b[W-1] && a[W-1] != y[W-1]);
            end
            SUB_OP: begin
                logic [W-1:0] neg_b;
                logic [W:0] res;
                neg_b = -b;
                res = (W+1)'(a) + (W+1)'(neg_b);

                y = W'(res);
                carry = res[W];
                overflow = (a[W-1] == neg_b[W-1] && a[W-1] != y[W-1]);
            end
            AND_OP: begin
                y = a & b;
            end
            OR_OP: begin
                y = a | b;
            end
            XOR_OP: begin
                y = a ^ b;
            end
            SLL_OP: begin
                logic [SHW:0] shamt;
                shamt = b[SHW:0] % W;

                y = a << shamt;
            end
            SRL_OP: begin
                logic [SHW:0] shamt;
                shamt = b[SHW:0] % W;

                y = a >> shamt;
            end
            SLT_OP: begin
                y = $signed(a) < $signed(b);
            end
            default: begin
            end
        endcase
    end
endmodule
