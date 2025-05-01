`timescale 1ns/1ps
`define HALF_CLOCK_PERIOD_2 #500
`define MATLAB_INPUT_FN "../../matlab/fir/imem_input.txt"
`define QSIM_OUT_FN "./qsim.out"

// testbench for ../../rtl/imem/imem.v

module testbench();
    reg clk2;
    reg rstn;
    reg update;
    reg [5:0] iaddr;
    reg [15:0] din;
    wire [15:0] dout;

    integer i; // loop counter for 64 inputs
    integer error_count;
    integer written, read;
    integer input_file;
    integer qsim_out_file;
    reg [15:0] expected;

    // variables for reading the input/output files, need to be decimals
    integer ret_read;

    // instantiate the unit under test
    imem imem_0 ( .clk2(clk2), .rstn(rstn), .update(update), .iaddr(iaddr), .din(din), .dout(dout) );

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

        error_count = 0;
        written = 0;

        // register setup
        clk2 = 0;
        rstn = 0;
        update = 1;
        iaddr = 0;
        din = 16'd0;

        @ (posedge clk2);

        @ (negedge clk2);
        rstn = 1;

        @ (posedge clk2); // first cycle
        for (i=0; i<64; i=i+1) begin
            // read input from file
            ret_read = $fscanf(input_file, "%d", din);
            #10;

            // check if output matches 
            if (dout != written) begin
                $display("Error: dout = %d, expected = %d", dout, din);
                error_count = error_count + 1;
            end
            // write output to qsim output file
            $fwrite(qsim_out_file, "%d\n", dout);
            written = din;
            @ (posedge clk2);
        end

        // close MATLAB input file
        $fclose(input_file);
        // open again to reset file pointer
        input_file = $fopen(`MATLAB_INPUT_FN, "r");
        if (input_file == 0) begin
            $display("Error opening MATLAB input file");
            $finish;
        end

        @ (negedge clk2);
        update = 0;
        read = din;

        @ (posedge clk2);
        for (i = 63; i >= 0; i = i - 1) begin
            ret_read = $fscanf(input_file, "%d", expected);
            iaddr = i;
            #10;

            // check if output matches 
            if (dout != read) begin
                $display("Error: dout = %d, expected = %d", dout, expected);
                error_count = error_count + 1;
            end
            // write output to qsim output file
            $fwrite(qsim_out_file, "%d\n", dout);
            read = expected;
            @ (posedge clk2);
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

