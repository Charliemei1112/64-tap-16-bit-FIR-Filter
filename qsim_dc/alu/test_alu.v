`timescale 1ns/1ps
// `define SD #0.010
// // clk1 = 10kHz, clk2 = 1MHz
// `define HALF_CLOCK_PERIOD_1 #50000
`define HALF_CLOCK_PERIOD_2 #500
`define MATLAB_COEF_FN "../../matlab/fir/alu_coef.txt"
`define MATLAB_INPUT_FN "../../matlab/fir/alu_input.txt"
`define MATLAB_OUT_FN "../../matlab/fir/alu_output.txt"
`define QSIM_OUT_FN "./qsim.out"

// testbench for ../../rtl/fir/alu.v

module testbench();
    reg clk2;
    reg rstn;
    reg clr;
    reg [15:0] din1;
    reg [15:0] din2;
    wire [15:0] fp_out;
    wire [31:0] dout;

    integer i; // loop counter for 64 inputs
    integer error_count;
    reg [15:0] expected;
    integer input_file;
    integer output_file;
    integer coef_file;
    integer qsim_out_file;

    // variables for reading the input/output files, need to be decimals
    integer ret_read;

    // instantiate the unit under test
    alu alu_0 ( .clk2(clk2), .rstn(rstn), .clr(clr), .din1(din1), .din2(din2), .dout(dout), .fp_out(fp_out));

    always begin
        `HALF_CLOCK_PERIOD_2;
        clk2 = ~clk2;
    end

    // open MATLAB coefficient file

    initial begin
        // open MATLAB coefficient file
        coef_file = $fopen(`MATLAB_COEF_FN, "r");
        if (coef_file == 0) begin
            $display("Error opening MATLAB coefficient file");
            $finish;
        end

        // open MATLAB input file
        input_file = $fopen(`MATLAB_INPUT_FN, "r");
        if (input_file == 0) begin
            $display("Error opening MATLAB input file");
            $finish;
        end

        // open MATLAB output file
        output_file = $fopen(`MATLAB_OUT_FN, "r");
        if (output_file == 0) begin
            $display("Error opening MATLAB output file");
            $finish;
        end

        // open qsim output file
        qsim_out_file = $fopen(`QSIM_OUT_FN, "w");
        if (qsim_out_file == 0) begin
            $display("Error opening qsim output file");
            $finish;
        end

        $dumpfile("./alu.vcd");
        $dumpvars(0, testbench.alu_0);

        // register setup
        clk2 = 0;
        rstn = 0;
        clr = 0;
        din1 = 0;
        din2 = 0;
        expected = 0;

        error_count = 0;

        @ (posedge clk2);
        
        @ (negedge clk2);
        rstn = 1;
        clr = 1;

        @ (posedge clk2);
        for (i=0; i<64; i=i+1) begin
            // read coefficient from file
            ret_read = $fscanf(input_file, "%b\n", din1);
            // read input from file file
            ret_read = $fscanf(coef_file, "%b\n", din2);
            #100;
            $fwrite(qsim_out_file, "%b\n", fp_out);
            if (fp_out != expected) begin
                $display("Error: expected %b, got %b", expected, fp_out);
                error_count = error_count + 1;
            end
            ret_read = $fscanf(output_file, "%b\n", expected);
            @ (posedge clk2);
        end

        if (error_count == 0) begin
            $display("All tests passed");
        end else begin
            $display("Error: %d tests failed", error_count);
        end

        $fclose(input_file);
        $fclose(output_file);
        $fclose(coef_file);
        $fclose(qsim_out_file);

        $dumpall;
        $dumpflush;

        $finish;

    end

endmodule

