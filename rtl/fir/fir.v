module fir(
    input clk1,
    input clk2,
    input rstn,
    input valid_in,
    input cen,
    input [15:0] din, // data input
    input [15:0] cin, // coefficient
    output valid_out, // if the output is valid
    // output [31:0] fx_out, // data output (floating type)
    output [15:0] dout, // data output (floating type)
    output [15:0] imem_out, cmem_out,
    output [5:0] cmem_counter, imem_counter
    // output EMPTY, WEN, UPDATE, REN, CLEAR,
    // output [2:0] state
);

// datapath internal signals
wire WEN, EMPTY, UPDATE, REN, CLEAR;
wire [2:0] state;
// wire [5:0] counter; // counter variable
wire [31:0] fx_out;

// Instantiate Datapath Module
    datapath datapath_0 (
        .clk1(clk1),
        .clk2(clk2),
        .rstn(rstn),
        .clr(CLEAR),
        .valid_in(valid_in),
        .ren(REN),
        .update(UPDATE),
        .caddr(cmem_counter),
        .iaddr(imem_counter),
        .cen(cen),
        .wen(WEN),
        .din(din),
        .cin(cin),
        .fx_out(fx_out),
        .dout(dout),
        .imem_out(imem_out),
        .cmem_out(cmem_out),
        .fifo_empty(EMPTY)
    );

    controller controller_0 (
        .clk2(clk2),
        .rstn(rstn),
        .REN(REN),
        .WEN(WEN),
        .VALID_OUT(valid_out),
        .EMPTY(EMPTY),
        .UPDATE(UPDATE),
        .CLEAR(CLEAR),
        .cmem_counter(cmem_counter),
        .imem_counter(imem_counter),
        .state(state)
    );

endmodule