// 64 16-bit shift register instruction memory

module imem(
    input clk2,
    input rstn,
    input update,
    input [5:0] iaddr,
    input [15:0] din,
    output reg [15:0] dout
);

    integer i;
    reg [15:0] IMEM [0:63];

    always @(posedge clk2 or negedge rstn) begin
        if (~rstn) begin
            // Initialize IMEM to zeros
            for (i = 0; i < 64 ; i = i + 1) begin
                IMEM[i] <= 16'd0;
            end
        end
        else if (update) begin
            IMEM[0] <= din;
            for (i = 1; i < 64 ; i = i + 1) begin
                IMEM[i] <= IMEM[i-1];
            end
            dout <= din;
        end
        else begin
            dout <= IMEM[iaddr];
        end
    end


endmodule