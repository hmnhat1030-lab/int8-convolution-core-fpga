module line_buffer #(
    parameter DATA_WIDTH = 8,
    parameter IMG_WIDTH  = 8 //?nh 8x8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  shift_en,
    input  wire [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out
);
    // Sâu line buffer b?ng IMG_WIDTH
    localparam DEPTH = IMG_WIDTH;

    reg [DATA_WIDTH-1:0] buffer [0:DEPTH-1];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                buffer[i] <= 0;
            end
        end else if (shift_en) begin
            // D?ch data buffer
            for (i = DEPTH-1; i > 0; i = i - 1) begin
                buffer[i] <= buffer[i-1];
            end
            buffer[0] <= data_in;
        end
    end


    assign data_out = buffer[DEPTH-1];

endmodule
