// quant_clip.v
// Optional INT32 -> INT8 clipping block.
// SHIFT can be used for fixed-point scaling before saturation.

module quant_clip #(
    parameter SHIFT = 0
)(
    input  signed [31:0] din,
    output reg signed [7:0] dout
);
    wire signed [31:0] shifted;

    assign shifted = din >>> SHIFT;

    always @(*) begin
        if (shifted > 32'sd127)
            dout = 8'sd127;
        else if (shifted < -32'sd128)
            dout = -8'sd128;
        else
            dout = shifted[7:0];
    end
endmodule
