`timescale 1ns/1ps

module tb_conv_core_int8;

    localparam IMG_W = 8;
    localparam IMG_H = 8;
    localparam OUT_W = IMG_W - 2;
    localparam OUT_H = IMG_H - 2;

    reg clk;
    reg rst_n;
    reg in_valid;
    reg [1:0] kernel_sel;

    reg signed [7:0] p00, p01, p02;
    reg signed [7:0] p10, p11, p12;
    reg signed [7:0] p20, p21, p22;
    reg signed [31:0] bias;

    wire signed [7:0] w00, w01, w02;
    wire signed [7:0] w10, w11, w12;
    wire signed [7:0] w20, w21, w22;

    wire out_valid;
    wire signed [31:0] out_int32;
    wire signed [7:0] out_int8;
    wire signed [31:0] sum_before_relu;

    integer pass_count;
    integer fail_count;
    integer error_value;
    integer row;
    integer col;

    reg signed [31:0] rtl_output [0:35];

    kernel_rom u_kernel_rom (
        .kernel_sel(kernel_sel),
        .w00(w00), .w01(w01), .w02(w02),
        .w10(w10), .w11(w11), .w12(w12),
        .w20(w20), .w21(w21), .w22(w22)
    );

    conv_core_int8 #(
        .USE_RELU(0),
        .USE_QUANT_CLIP(1),
        .SHIFT(0)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),

        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),

        .w00(w00), .w01(w01), .w02(w02),
        .w10(w10), .w11(w11), .w12(w12),
        .w20(w20), .w21(w21), .w22(w22),

        .bias(bias),

        .out_valid(out_valid),
        .out_int32(out_int32),
        .out_int8(out_int8),
        .sum_before_relu(sum_before_relu)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    function signed [7:0] clip_int8;
        input signed [31:0] value;
        begin
            if (value > 32'sd127)
                clip_int8 = 8'sd127;
            else if (value < -32'sd128)
                clip_int8 = -8'sd128;
            else
                clip_int8 = value[7:0];
        end
    endfunction

    task run_window_case;
        input integer out_row;
        input integer out_col;
        integer expected_product;
        integer expected_out;
        reg signed [7:0] expected_int8;
        integer out_index;
        begin
            @(negedge clk);
            p00 =  out_row      * IMG_W + out_col + 1;
            p01 =  out_row      * IMG_W + out_col + 2;
            p02 =  out_row      * IMG_W + out_col + 3;
            p10 = (out_row + 1) * IMG_W + out_col + 1;
            p11 = (out_row + 1) * IMG_W + out_col + 2;
            p12 = (out_row + 1) * IMG_W + out_col + 3;
            p20 = (out_row + 2) * IMG_W + out_col + 1;
            p21 = (out_row + 2) * IMG_W + out_col + 2;
            p22 = (out_row + 2) * IMG_W + out_col + 3;
            in_valid = 1'b1;

            expected_product = (p00 * w00) + (p01 * w01) + (p02 * w02)
                             + (p10 * w10) + (p11 * w11) + (p12 * w12)
                             + (p20 * w20) + (p21 * w21) + (p22 * w22);
            expected_out = expected_product + bias;
            expected_int8 = clip_int8(expected_out);

            @(posedge clk);
            #1;
            out_index = out_row * OUT_W + out_col;
            rtl_output[out_index] = out_int32;
            error_value = out_int32 - expected_out;

            $display("--------------------------------------------");
            $display("Window for output[%0d][%0d]:", out_row, out_col);
            $display("[%0d] [%0d] [%0d]", p00, p01, p02);
            $display("[%0d] [%0d] [%0d]", p10, p11, p12);
            $display("[%0d] [%0d] [%0d]", p20, p21, p22);
            $display("m00=%0d m01=%0d m02=%0d", dut.u_mac_3x3.m00, dut.u_mac_3x3.m01, dut.u_mac_3x3.m02);
            $display("m10=%0d m11=%0d m12=%0d", dut.u_mac_3x3.m10, dut.u_mac_3x3.m11, dut.u_mac_3x3.m12);
            $display("m20=%0d m21=%0d m22=%0d", dut.u_mac_3x3.m20, dut.u_mac_3x3.m21, dut.u_mac_3x3.m22);
            $display("product_sum=%0d | bias=%0d | sum_before_relu=%0d | relu_out=%0d | out_int32=%0d | expected=%0d | out_int8=%0d | expected_int8=%0d",
                     dut.u_mac_3x3.product_sum, bias, sum_before_relu, dut.relu_out, out_int32, expected_out, out_int8, expected_int8);

            if ((out_valid == 1'b1) && (out_int32 == expected_out) && (out_int8 == expected_int8)) begin
                pass_count = pass_count + 1;
                $display("Result: PASS | error=%0d", error_value);
            end else begin
                fail_count = fail_count + 1;
                $display("Result: FAIL | error=%0d | out_valid=%0b", error_value, out_valid);
            end

            @(negedge clk);
            in_valid = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("conv_core_int8_mac_debug.vcd");
        $dumpvars(0, tb_conv_core_int8);

        pass_count = 0;
        fail_count = 0;

        rst_n = 1'b0;
        in_valid = 1'b0;
        kernel_sel = 2'd0;     // vertical edge kernel
        bias = 32'sd0;

        p00 = 0; p01 = 0; p02 = 0;
        p10 = 0; p11 = 0; p12 = 0;
        p20 = 0; p21 = 0; p22 = 0;

        repeat (2) @(posedge clk);
        rst_n = 1'b1;

        $display("============================================");
        $display("INT8 3x3 Convolution Core Test");
        $display("Input image: 8x8, values 1..64, row-major");
        $display("Output map : 6x6 valid convolution windows");
        $display("Kernel     : [1 0 -1; 2 0 -2; 1 0 -1]");
        $display("Bias       : 0");
        $display("USE_RELU   : 0, raw INT32 and clipped INT8 outputs are checked");
        $display("============================================");

        for (row = 0; row < OUT_H; row = row + 1) begin
            for (col = 0; col < OUT_W; col = col + 1) begin
                run_window_case(row, col);
            end
        end

        $display("============================================");
        $display("RTL output matrix 6x6:");
        for (row = 0; row < OUT_H; row = row + 1) begin
            $display("%0d %0d %0d %0d %0d %0d",
                     rtl_output[row * OUT_W + 0], rtl_output[row * OUT_W + 1],
                     rtl_output[row * OUT_W + 2], rtl_output[row * OUT_W + 3],
                     rtl_output[row * OUT_W + 4], rtl_output[row * OUT_W + 5]);
        end

        $display("============================================");
        $display("PASS=%0d, FAIL=%0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("KET LUAN: Loi convolution INT8 tinh DUNG voi 36 window cua anh 8x8.");
        else
            $display("KET LUAN: Loi convolution INT8 co loi, can kiem tra lai.");
        $display("============================================");

        #20;
        $finish;
    end

endmodule
