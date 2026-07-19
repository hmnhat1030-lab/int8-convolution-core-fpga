// relu.v
// ReLU for signed data: negative -> 0, positive -> unchanged.

module relu #(
    parameter WIDTH = 32
)(
    input  signed [WIDTH-1:0] din,
    output signed [WIDTH-1:0] dout
);
    assign dout = din[WIDTH-1] ? {WIDTH{1'b0}} : din;
endmodule
