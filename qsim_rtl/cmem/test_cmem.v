`timescale 1ns/1ps
`define HALF_CLOCK_PERIOD_2 #500
`define MATLAB_INPUT_FN "../../matlab/fir/cmem_input.txt"
`define QSIM_OUT_FN "./qsim.out"

// testbench for ../../rtl/fir/cmem.v

module testbench();
    reg clk2;
    reg cen;
    reg wen;
    reg [5:0] caddr;
    reg [15:0] din;
    wire [15:0] dout;

    integer i; // loop counter for 64 inputs
    integer error_count;
    reg [15:0] expected;
    integer input_file;
    integer qsim_out_file;

    // variables for reading the input/output files, need to be decimals
    integer ret_read;

    // instantiate the unit under test
    cmem cmem_0 ( .clk2(clk2), .cen(cen), .wen(wen), .caddr(caddr), .din(din), .dout(dout));

    always begin
        `HALF_CLOCK_PERIOD_2;
        clk2 = ~clk2;
    end

    // open MATLAB coefficient file

    initial begin

        // open MATLAB input file
        input_file = $fopen(`MATLAB_INPUT_FN, "r");
        if (input_file == 0) begin
            $display("Error opening MATLAB input file");
            $finish;
        end

        // open qsim output file
        qsim_out_file = $fopen(`QSIM_OUT_FN, "w");
        if (qsim_out_file == 0) begin
            $display("Error opening qsim output file");
            $finish;
        end

        // register setup
        clk2 = 0;
        cen = 0;
        wen = 0;
        caddr = 0;
        din = 0;
        error_count = 0;

        for (i = 0; i < 64; i = i + 1) begin
            // read input from file
            @ (negedge clk2);
            begin
                caddr = i;
                ret_read = $fscanf(input_file, "%d", din);
            end

            // see if input is written into the memory
            @ (posedge clk2);
            #50;
            if (din != dout) begin
                $display("Error: Input %d not written into memory", din);
                error_count = error_count + 1;
            end

            // write output to qsim output file
            $fwrite(qsim_out_file, "%d\n", din);
        end

        $fclose(input_file);
        // open MATLAB input file
        input_file = $fopen(`MATLAB_INPUT_FN, "r");
        if (input_file == 0) begin
            $display("Error opening MATLAB input file");
            $finish;
        end

        $fwrite(qsim_out_file, "Reading from memory\n");

        // now let's see if we can read from cmem
        wen = 1;

        for (i = 0; i < 64; i = i + 1) begin
            // read input from file
            @ (negedge clk2);
            begin
                caddr = i;
                ret_read = $fscanf(input_file, "%d", expected);
            end

            // see if input is read from the memory
            @ (posedge clk2);
            #50;
            if (expected != dout) begin
                $display("Error: Expected %d, got %d", expected, dout);
                error_count = error_count + 1;
            end

            // write output to qsim output file
            $fwrite(qsim_out_file, "%d\n", dout);
        end

        if (error_count == 0) begin
            $display("All tests passed");
        end else begin
            $display("Error: %d tests failed", error_count);
        end

        $fclose(input_file);
        $fclose(qsim_out_file);

        $finish;

    end

endmodule

