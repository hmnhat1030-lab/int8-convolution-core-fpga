`timescale 1ns/1ps

module tb_compare_python_rtl;

    localparam IMG_W = 28;
    localparam IMG_H = 28;
    localparam OUT_W = IMG_W - 2;
    localparam OUT_H = IMG_H - 2;
    localparam IMG_SIZE = IMG_W * IMG_H;
    localparam OUT_SIZE = OUT_W * OUT_H;

    reg clk;
    reg rst_n;
    reg in_valid;
    reg [1:0] kernel_sel;

    reg signed [7:0] image_mem [0:IMG_SIZE-1];
    reg signed [7:0] expected_mem [0:OUT_SIZE-1];

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

    integer row;
    integer col;
    integer out_index;
    integer pass_count;
    integer fail_count;
    integer shown_fail_count;

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

    task load_window;
        input integer r;
        input integer c;
        begin
            p00 = image_mem[(r + 0) * IMG_W + c + 0];
            p01 = image_mem[(r + 0) * IMG_W + c + 1];
            p02 = image_mem[(r + 0) * IMG_W + c + 2];
            p10 = image_mem[(r + 1) * IMG_W + c + 0];
            p11 = image_mem[(r + 1) * IMG_W + c + 1];
            p12 = image_mem[(r + 1) * IMG_W + c + 2];
            p20 = image_mem[(r + 2) * IMG_W + c + 0];
            p21 = image_mem[(r + 2) * IMG_W + c + 1];
            p22 = image_mem[(r + 2) * IMG_W + c + 2];
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;
        shown_fail_count = 0;

        rst_n = 1'b0;
        in_valid = 1'b0;
        kernel_sel = 2'd0;
        bias = 32'sd0;

        p00 = 0; p01 = 0; p02 = 0;
        p10 = 0; p11 = 0; p12 = 0;
        p20 = 0; p21 = 0; p22 = 0;

        $readmemh("image.hex", image_mem);
        $readmemh("expected_output.hex", expected_mem);

        repeat (2) @(posedge clk);
        rst_n = 1'b1;

        $display("============================================");
        $display("Compare Python Golden Model vs RTL");
        $display("Input : image.hex, 28x28 signed INT8");
        $display("Kernel: kernel.hex, 3x3 signed INT8");
        $display("Expect: expected_output.hex, 26x26 signed INT8");
        $display("Bias  : 0");
        $display("============================================");
        $display("Kernel read by RTL:");
        $display("[%0d] [%0d] [%0d]", w00, w01, w02);
        $display("[%0d] [%0d] [%0d]", w10, w11, w12);
        $display("[%0d] [%0d] [%0d]", w20, w21, w22);
        $display("First window:");
        $display("[%0d] [%0d] [%0d]", image_mem[0], image_mem[1], image_mem[2]);
        $display("[%0d] [%0d] [%0d]", image_mem[28], image_mem[29], image_mem[30]);
        $display("[%0d] [%0d] [%0d]", image_mem[56], image_mem[57], image_mem[58]);
        $display("============================================");

        for (row = 0; row < OUT_H; row = row + 1) begin
            for (col = 0; col < OUT_W; col = col + 1) begin
                @(negedge clk);
                load_window(row, col);
                in_valid = 1'b1;

                @(posedge clk);
                #1;
                out_index = row * OUT_W + col;

                if ((out_valid == 1'b1) && (out_int8 == expected_mem[out_index])) begin
                    pass_count = pass_count + 1;
                end else begin
                    fail_count = fail_count + 1;
                    if (shown_fail_count < 20) begin
                        $display("FAIL out[%0d][%0d] index=%0d | RTL_INT32=%0d RTL_INT8=%0d EXPECT=%0d out_valid=%0b",
                                 row, col, out_index, out_int32, out_int8, expected_mem[out_index], out_valid);
                        shown_fail_count = shown_fail_count + 1;
                    end
                end

                @(negedge clk);
                in_valid = 1'b0;
            end
        end

        $display("============================================");
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);
        if ((pass_count == OUT_SIZE) && (fail_count == 0))
            $display("KET LUAN: RTL KHOP PYTHON GOLDEN MODEL 676/676.");
        else
            $display("KET LUAN: RTL CHUA KHOP PYTHON GOLDEN MODEL.");
        $display("============================================");

        #20;
        $finish;
    end

endmodule
