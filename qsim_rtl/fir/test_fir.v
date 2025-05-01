`timescale 1ns/1ps
// `define SD #0.010
// clk1 = 10kHz, clk2 = 1MHz
`define HALF_CLOCK_PERIOD_1 #50000
`define HALF_CLOCK_PERIOD_2 #500
`define MATLAB_INPUT_FN "../../matlab/fir/fir_input.txt"
`define MATLAB_COEF_FN "../../matlab/fir/coef.txt"
`define MATLAB_OUTPUT_FN "../../matlab/fir/fp_output.txt"
`define MATLAB_FX_OUTPUT_FN "../../matlab/fir/output.txt"
`define QSIM_OUT_FN "./qsim.out"

// testbench for ../../dc/fir/fifo.nl.v

module testbench();
    reg clk1;
    reg clk2;
    reg rstn;
    reg valid_in;
    reg cen;
    reg [15:0] din;
    reg [15:0] cin;
    wire valid_out;
    // wire [31:0] fx_out;
    wire [15:0] dout;
    wire [15:0] imem_out, cmem_out;
    wire [5:0] cmem_counter, imem_counter;
    // wire EMPTY, WEN, UPDATE, REN, CLEAR;
    // wire [2:0] state;   

    integer i; // loop counter for 64 inputs
    integer error_count;
    reg [15:0] expected;
    // reg [31:0] expected_fx;
    integer input_file;
    integer coef_file;
    integer qsim_out_file;
    integer output_file;
    integer fp_output_file;

    // variables for reading the input/output files, need to be decimals
    integer ret_read;

    // instantiate the unit under test
    fir fir_0 (
        .clk1(clk1),
        .clk2(clk2),
        .rstn(rstn),
        .valid_in(valid_in),
        .cen(cen),
        .din(din),
        .cin(cin),
        .valid_out(valid_out),
        // .fx_out(fx_out),
        .dout(dout),
        .imem_out(imem_out),
        .cmem_out(cmem_out),
        .cmem_counter(cmem_counter),
        .imem_counter(imem_counter)
        // .EMPTY(EMPTY),
        // .WEN(WEN),
        // .UPDATE(UPDATE),
        // .REN(REN),
        // .CLEAR(CLEAR),
        // .state(state)
    );

    always begin
        `HALF_CLOCK_PERIOD_1;
        clk1 = ~clk1;
    end

    always begin
        `HALF_CLOCK_PERIOD_2;
        clk2 = ~clk2;
    end

    initial begin
        // open MATLAB input file
        input_file = $fopen(`MATLAB_INPUT_FN, "r");
        if (input_file == 0) begin
            $display("Error opening MATLAB input file");
            $finish;
        end

        // open MATLAB coefficient file
        coef_file = $fopen(`MATLAB_COEF_FN, "r");
        if (coef_file == 0) begin
            $display("Error opening MATLAB coefficient file");
            $finish;
        end

        // open MATLAB output file
        output_file = $fopen(`MATLAB_OUTPUT_FN, "r");
        if (output_file == 0) begin
            $display("Error opening MATLAB output file");
            $finish;
        end

        // open MATLAB fixed-point output file
        fp_output_file = $fopen(`MATLAB_FX_OUTPUT_FN, "r");
        if (output_file == 0) begin
            $display("Error opening MATLAB fixed-point output file");
            $finish;
        end

        // open qsim output file
        qsim_out_file = $fopen(`QSIM_OUT_FN, "w");
        if (qsim_out_file == 0) begin
            $display("Error opening qsim output file");
            $finish;
        end

        // register setup
        clk1 = 0;
        clk2 = 0;
        rstn = 0;
        cen = 0;
        valid_in = 1;
        din = 0;
        ret_read = $fscanf(coef_file, "%b", cin);
        expected = 0;
        
        error_count = 0;

        @ (posedge clk1);

        @ (posedge clk1);
        rstn = 1;
        // write coeffcient file
        for (i=1; i<64; i=i+1) begin
            @ (posedge clk2) begin
                ret_read = $fscanf(coef_file, "%b", cin);
                #100;
            end
        end

        @ (posedge clk1);
        for (i = 0; i < 128; i = i + 1) begin
            @ (posedge clk1) begin
                ret_read = $fscanf(input_file, "%b", din);
                #100;
                // compare output with expected
                while (~valid_out) begin
                    @ (posedge clk2);
                end
                // ret_read = $fscanf(output_file, "%b", expected);
                if (dout != expected) begin
                    $display("FP Error: expected %h, got %h", expected, dout);
                    error_count = error_count + 1;
                end
                ret_read = $fscanf(output_file, "%b", expected);
                $fwrite(qsim_out_file, "%b\n", dout);
            end
        end

        if (error_count == 0) begin
            $display("All tests passed");
        end else begin
            $display("Error: %d tests failed", error_count);
        end

        $fclose(coef_file);
        $fclose(input_file);
        $fclose(output_file);
        $fclose(qsim_out_file);

        $finish;

    end

endmodule

