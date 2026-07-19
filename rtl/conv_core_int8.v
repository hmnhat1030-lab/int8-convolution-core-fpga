// conv_core_int8.v
// Top INT8 convolution core for one 3x3 output pixel.
// Input : 9 signed INT8 pixels + 9 signed INT8 weights + INT32 bias
// Output: signed INT32 result and optional signed INT8 clipped result
// Latency: 1 clock cycle from in_valid to out_valid
// Throughput: 1 output pixel per clock if in_valid is asserted every clock

module conv_core_int8 #(
    parameter USE_RELU       = 0,
    parameter USE_QUANT_CLIP = 0,
    parameter SHIFT          = 0
)(
    input clk,
    input rst_n,
    input in_valid,

    input signed [7:0] p00, input signed [7:0] p01, input signed [7:0] p02,
    input signed [7:0] p10, input signed [7:0] p11, input signed [7:0] p12,
    input signed [7:0] p20, input signed [7:0] p21, input signed [7:0] p22,

    input signed [7:0] w00, input signed [7:0] w01, input signed [7:0] w02,
    input signed [7:0] w10, input signed [7:0] w11, input signed [7:0] w12,
    input signed [7:0] w20, input signed [7:0] w21, input signed [7:0] w22,

    input signed [31:0] bias,

    output reg out_valid,
    output reg signed [31:0] out_int32,
    output reg signed [7:0] out_int8,
    output reg signed [31:0] sum_before_relu
);

    wire signed [31:0] mac_product_sum;
    wire signed [31:0] mac_sum;
    wire signed [31:0] relu_out;
    wire signed [31:0] selected_int32;
    wire signed [7:0] clipped_int8;

    mac_3x3 u_mac_3x3 (
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),

        .w00(w00), .w01(w01), .w02(w02),
        .w10(w10), .w11(w11), .w12(w12),
        .w20(w20), .w21(w21), .w22(w22),

        .bias(bias),
        .product_sum(mac_product_sum),
        .sum(mac_sum)
    );

    relu #(.WIDTH(32)) u_relu (
        .din(mac_sum),
        .dout(relu_out)
    );

    assign selected_int32 = (USE_RELU != 0) ? relu_out : mac_sum;

    quant_clip #(.SHIFT(SHIFT)) u_quant_clip (
        .din(selected_int32),
        .dout(clipped_int8)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_valid       <= 1'b0;
            out_int32       <= 32'sd0;
            out_int8        <= 8'sd0;
            sum_before_relu <= 32'sd0;
        end else begin
            out_valid <= in_valid;

            if (in_valid) begin
                sum_before_relu <= mac_sum;
                out_int32       <= selected_int32;

                if (USE_QUANT_CLIP != 0)
                    out_int8 <= clipped_int8;
                else
                    out_int8 <= selected_int32[7:0];
            end
        end
    end

endmodule
