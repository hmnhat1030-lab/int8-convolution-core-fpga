// kernel_rom.v
// Simple 3x3 kernel ROM for simulation/demo.
// In the full project, these weights can come from kernel_ram instead.

module kernel_rom (
    input [1:0] kernel_sel,

    output reg signed [7:0] w00, output reg signed [7:0] w01, output reg signed [7:0] w02,
    output reg signed [7:0] w10, output reg signed [7:0] w11, output reg signed [7:0] w12,
    output reg signed [7:0] w20, output reg signed [7:0] w21, output reg signed [7:0] w22
);
    reg signed [7:0] kernel_mem [0:8];

    initial begin
        $readmemh("kernel.hex", kernel_mem);
    end

    always @(*) begin
        case (kernel_sel)
            // kernel_sel = 0: Sobel vertical edge kernel
            // [ 1  0 -1 ]
            // [ 2  0 -2 ]
            // [ 1  0 -1 ]
            2'd0: begin
                w00 = kernel_mem[0]; w01 = kernel_mem[1]; w02 = kernel_mem[2];
                w10 = kernel_mem[3]; w11 = kernel_mem[4]; w12 = kernel_mem[5];
                w20 = kernel_mem[6]; w21 = kernel_mem[7]; w22 = kernel_mem[8];
            end

            // kernel_sel = 1: all-one kernel
            // Useful for sum/blur style test. Scaling can be done later by quant_clip.
            2'd1: begin
                w00 = 8'sd1; w01 = 8'sd1; w02 = 8'sd1;
                w10 = 8'sd1; w11 = 8'sd1; w12 = 8'sd1;
                w20 = 8'sd1; w21 = 8'sd1; w22 = 8'sd1;
            end

            // kernel_sel = 2: sharpen kernel
            // [ 0 -1  0 ]
            // [-1  5 -1 ]
            // [ 0 -1  0 ]
            2'd2: begin
                w00 =  8'sd0; w01 = -8'sd1; w02 =  8'sd0;
                w10 = -8'sd1; w11 =  8'sd5; w12 = -8'sd1;
                w20 =  8'sd0; w21 = -8'sd1; w22 =  8'sd0;
            end

            // default: identity kernel
            // [ 0 0 0 ]
            // [ 0 1 0 ]
            // [ 0 0 0 ]
            default: begin
                w00 = 8'sd0; w01 = 8'sd0; w02 = 8'sd0;
                w10 = 8'sd0; w11 = 8'sd1; w12 = 8'sd0;
                w20 = 8'sd0; w21 = 8'sd0; w22 = 8'sd0;
            end
        endcase
    end
endmodule
