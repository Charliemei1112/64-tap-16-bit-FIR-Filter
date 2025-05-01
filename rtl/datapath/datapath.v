module datapath(
    input clk1,
    input clk2,
    input rstn,
    input clr,
    input valid_in,
    input ren,
    input update,
    input [5:0] caddr,
    input cen,
    input wen,
    input [5:0] iaddr,
    input [15:0] din, // data input
    input [15:0] cin, // coefficient
    output [31:0] fx_out, // fixed point output
    output [15:0] dout, // data output (floating type)
    output [15:0] imem_out, cmem_out,
    output fifo_empty
);


// alu internal signals
// wire clr;

// cmem internal signals
// wire [15:0] cmem_out;

// imem internal signals
// wire [15:0] imem_out;

// fifo internal signals
wire [15:0] fifo_out;

    alu alu_0(
        .clk2(clk2),
        .rstn(rstn),
        .clr(clr),
        .din1(imem_out),
        .din2(cmem_out),
        .dout(fx_out),
        .fp_out(dout)
    );

    cmem cmem_0(
        .clk2(clk2),
        .cen(cen),
        .wen(wen),
        .caddr(caddr),
        .din(cin),
        .dout(cmem_out)
    );

    imem imem_0(
        .clk2(clk2),
        .rstn(rstn),
        .update(update),
        .iaddr(iaddr),
        .din(fifo_out),
        .dout(imem_out)
    );

    fifo fifo_0(
        .clk1(clk1),
        .clk2(clk2),
        .rstn(rstn),
        .wen(valid_in),
        .ren(ren),
        .din(din),
        .dout(fifo_out),
        .empty(fifo_empty)
    );

endmodule