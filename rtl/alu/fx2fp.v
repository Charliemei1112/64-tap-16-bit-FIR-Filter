module fx2fp (
    input [31:0] fx_32,
    output reg [15:0] fp_16
);

    wire sign;
    wire fx_32_abs [31:0];
    wire exp [4:0];
    wire mantissa [9:0];
    integer i;

    // find the absolute value of fx_32
    assign sign = fx_32[31];
    assign fx_32_abs = sign ? -fx_32 + 1'b1 : fx_32;

    // find the first 1-bit in fx_32_abs
    for (i = 31; i >= 9 ; i = i - 1) begin
        if (fx_32_abs[i]) begin
            break;
        end
    end

    assign exp = (i > 9) ? i - 5'd9 : 5'd0;
    assign mantissa = i > 9 ? fx_32_abs[i-1:i-10] : fx_32_abs[9:0]; 
    assign fp_16 = {sign, exp, mantissa};

endmodule