module sliding_window #(
    parameter DATA_WIDTH = 8,
    parameter IMG_WIDTH  = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] pixel_in,

    output reg                   out_valid,
    // 9  3x3
    output reg  [DATA_WIDTH-1:0] p00, p01, p02,
    output reg  [DATA_WIDTH-1:0] p10, p11, p12,
    output reg  [DATA_WIDTH-1:0] p20, p21, p22
);

    wire [DATA_WIDTH-1:0] lb0_out;
    wire [DATA_WIDTH-1:0] lb1_out;

    // Xác định3x3 hợp lệ (nạp đủ hàng/cột)
    reg [7:0] col_cnt;
    reg [7:0] row_cnt;

    // Instance Line Buffer 1
    line_buffer #(.DATA_WIDTH(DATA_WIDTH), .IMG_WIDTH(IMG_WIDTH)) lb1 (
        .clk(clk), .rst_n(rst_n), .shift_en(in_valid), .data_in(pixel_in), .data_out(lb1_out)
    );

    // Instance Line Buffer 0
    line_buffer #(.DATA_WIDTH(DATA_WIDTH), .IMG_WIDTH(IMG_WIDTH)) lb0 (
        .clk(clk), .rst_n(rst_n), .shift_en(in_valid), .data_in(lb1_out), .data_out(lb0_out)
    );

    // dịch 3x3
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {p00, p01, p02} <= 0;
            {p10, p11, p12} <= 0;
            {p20, p21, p22} <= 0;
        end else if (in_valid) begin
            p00 <= p01; p01 <= p02; p02 <= lb0_out;
            p10 <= p11; p11 <= p12; p12 <= lb1_out;
            p20 <= p21; p21 <= p22; p22 <= pixel_in;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_cnt   <= 0;
            row_cnt   <= 0;
            out_valid <= 0;
        end else if (in_valid) begin
            if (col_cnt == IMG_WIDTH - 1) begin
                col_cnt <= 0;
                row_cnt <= row_cnt + 1;
            end else begin
                col_cnt <= col_cnt + 1;
            end

            // 3x3 ok khi có ít nhất hàng thứ 2 và cột thứ 2 trở đi
            if (row_cnt >= 2 && col_cnt >= 2) begin
                out_valid <= 1;
            end else begin
                out_valid <= 0;
            end
        end else begin
            out_valid <= 0;
        end
    end
endmodule
