module decoder2to4 (
    input  logic [1:0] code,
    input  logic       enable,
    output logic [3:0] onehot
);

    always_comb begin
        if (enable) begin
            onehot = 4'b1 << code;
        end else begin
            onehot = 4'b0;
        end
    end
    
endmodule
