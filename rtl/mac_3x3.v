// mac_3x3.v
// 3x3 INT8 signed multiply-accumulate core
// pixel  : signed INT8
// weight : signed INT8
// product: signed INT16
// product_sum: signed INT32, sum of 9 products before bias
// sum        : signed INT32, product_sum + bias

module mac_3x3 (
    input  signed [7:0]  p00, input signed [7:0]  p01, input signed [7:0]  p02,
    input  signed [7:0]  p10, input signed [7:0]  p11, input signed [7:0]  p12,
    input  signed [7:0]  p20, input signed [7:0]  p21, input signed [7:0]  p22,

    input  signed [7:0]  w00, input signed [7:0]  w01, input signed [7:0]  w02,
    input  signed [7:0]  w10, input signed [7:0]  w11, input signed [7:0]  w12,
    input  signed [7:0]  w20, input signed [7:0]  w21, input signed [7:0]  w22,

    input  signed [31:0] bias,
    output signed [31:0] product_sum,
    output signed [31:0] sum
);

    wire signed [15:0] m00 = p00 * w00;
    wire signed [15:0] m01 = p01 * w01;
    wire signed [15:0] m02 = p02 * w02;
    wire signed [15:0] m10 = p10 * w10;
    wire signed [15:0] m11 = p11 * w11;
    wire signed [15:0] m12 = p12 * w12;
    wire signed [15:0] m20 = p20 * w20;
    wire signed [15:0] m21 = p21 * w21;
    wire signed [15:0] m22 = p22 * w22;

    // Sign-extend each INT16 product to INT32 before accumulation.
    assign product_sum = {{16{m00[15]}}, m00}
                       + {{16{m01[15]}}, m01}
                       + {{16{m02[15]}}, m02}
                       + {{16{m10[15]}}, m10}
                       + {{16{m11[15]}}, m11}
                       + {{16{m12[15]}}, m12}
                       + {{16{m20[15]}}, m20}
                       + {{16{m21[15]}}, m21}
                       + {{16{m22[15]}}, m22};

    assign sum = product_sum + bias;

endmodule
