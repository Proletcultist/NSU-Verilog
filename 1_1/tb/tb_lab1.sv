
module basic_gates_tb;
  `define CHECK(e_not_a, e_and_y, e_or_y, e_xor_y, e_nand_y, e_nor_y, e_xnor_y) \
     assert (\
       !$isunknown(not_a) && \
       !$isunknown(and_y) && \
       !$isunknown(or_y) && \
       !$isunknown(xor_y) && \
       !$isunknown(nand_y) && \
       !$isunknown(nor_y) && \
       !$isunknown(xnor_y) && \
       not_a == e_not_a && \
       and_y == e_and_y && \
       or_y == e_or_y && \
       xor_y == e_xor_y && \
       nand_y == e_nand_y && \
       nor_y == e_nor_y && \
       xnor_y == e_xnor_y \
    ) \
    else $error( \
        {"Assertion failed:\n", \
        "Inputs: a=%b, b=%b\n", \
        "Expected (not_a: %b, and_y: %b, or_y: %b, xor_y: %b, nand_y: %b, nor_y: %b, xnor_y: %b)\n", \
        "Got:     (not_a: %b, and_y: %b, or_y: %b, xor_y: %b, nand_y: %b, nor_y: %b, xnor_y: %b)"}, \
        a, b, e_not_a, e_and_y, e_or_y, e_xor_y, e_nand_y, e_nor_y, e_xnor_y, \
        not_a, and_y, or_y, xor_y, nand_y, nor_y, xnor_y);

  logic a = 0, b = 0;
  logic not_a, and_y, or_y, xor_y, nand_y, nor_y, xnor_y;
  basic_gates bg (a, b, not_a, and_y, or_y, xor_y, nand_y, nor_y, xnor_y);

  int errors = 0;

  initial begin
      a = 0;
      b = 0;
      # 10 `CHECK(1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1)

      a = 1;
      b = 0;
      # 10 `CHECK(1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0)

      a = 0;
      b = 1;
      # 10 `CHECK(1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0)

      a = 1;
      b = 1;
      # 10 `CHECK(1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1)
  end

endmodule
