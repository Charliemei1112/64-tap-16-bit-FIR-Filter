module fx2fp (
    input [31:0] fx_32,
    output [15:0] fp_16
);

    wire sign;
    wire [31:0] fx_32_abs;
    wire [4:0] exp;
    reg [9:0] mantissa;
    integer i,j;
    reg found;

    // find the absolute value of fx_32
    assign sign = fx_32[31];
    assign fx_32_abs = sign ? ~fx_32 + 1'b1 : fx_32;

    // find the first 1-bit in fx_32_abs
    always @(*) begin
        found = 0;
        for (i = 31; i >= 9 && !found; i = i - 1) begin
            if (fx_32_abs[i]) begin
                found = 1;
            end
        end
        if (i > 9) begin
            for (j = 0; j < 10; j = j + 1) begin
                mantissa[j] = fx_32_abs[i+j-9];
            end
        end
        else begin
            for (j = 0; j < 10; j = j + 1) begin
                mantissa[j] = fx_32_abs[j];
            end
        end
    end

    assign exp = (i > 9) ? i - 5'd8 : 5'd0;
    // assign mantissa = (i > 9) ? fx_32_abs[i-1:i-10] : fx_32_abs[9:0];
    assign fp_16 = {sign, exp, mantissa};

endmodule

module alu (clk2,rstn,clr,din1,din2,dout,fp_out);
    input clk2;
    input rstn;
    input clr;
    input [15:0] din1;
    input [15:0] din2;
    output reg [15:0] fp_out;
    output reg [31:0] dout; // fixed point

    wire [15:0] din1_abs, din2_abs;
    wire sign;

    assign din1_abs = din1[15] ? ~din1 + 1'b1 : din1;
    assign din2_abs = din2[15] ? ~din2 + 1'b1 : din2;
    assign sign = din1[15] ^ din2[15];

    wire [15:0] nfp_out;
    wire [31:0] ndout;
    assign ndout = sign ? (dout - (din1_abs * din2_abs)) : dout + (din1_abs * din2_abs);
    fx2fp fx2fp_0 (.fx_32(ndout), .fp_16(nfp_out));
    
    always @(posedge clk2) begin
        if (~rstn) begin
            dout <= 32'd0;
            fp_out <= 16'd0;
        end
        else if (~clr) begin
            dout <= 32'd0;
            fp_out <= 16'd0;
        end
        else begin
            dout <= ndout;
            fp_out <= nfp_out;
        end
    end

endmodule
