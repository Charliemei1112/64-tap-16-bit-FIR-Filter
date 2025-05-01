// CMEM module that holds the coefficient memory
module cmem (
    input clk2,
    input cen,
    input wen,
    input [5:0] caddr,
    input [15:0] din,
    output [15:0] dout
);

    RF1SHD memory ( .CLK(clk2), .CEN(cen), .WEN(wen), .A(caddr), .D(din), .Q(dout) );

endmodule