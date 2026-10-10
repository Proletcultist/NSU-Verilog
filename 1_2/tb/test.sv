module tb();
    logic [1:0] code;
    logic enable;
    logic [3:0] onehot;
    decoder2to4 dec (code, enable, onehot);

    initial begin
        code = 2;
        enable = 1;
        
        # 10 $display("Output: %b", onehot);
    end
endmodule
