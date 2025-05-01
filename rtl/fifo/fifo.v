// dual-clock FIFO module
module fifo (
    input clk1,
    input clk2,
    input rstn,
    input wen, // 1: write enable, 0: write disable
    input ren, // 1: read enable, 0: read disable
    input [15:0] din,
    output reg [15:0] dout,
    output empty
    // output reg rptr, wptr
);
// wire empty;
reg rptr, wptr;


assign empty = (rptr == wptr);

    always @(posedge clk1 or negedge rstn) begin
        if (~rstn) begin
            wptr <= 0;
            dout <= 0;
        end
        else if (wen && empty) begin
            dout <= din;
            wptr <= ~wptr;
        end
        else begin
            dout <= dout;
            wptr <= wptr;
        end
    end

    always @(posedge clk2 or negedge rstn) begin
        if (~rstn)
            rptr <= 0;
        else if (ren && ~empty)
            rptr <= ~rptr;
        else
            rptr <= rptr;
    end

endmodule