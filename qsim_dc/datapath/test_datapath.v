`timescale 1ns/1ps
// `define SD #0.010
// // clk1 = 10kHz, clk2 = 1MHz
`define HALF_CLOCK_PERIOD_1 #50000
`define HALF_CLOCK_PERIOD_2 #500
`define MATLAB_INPUT_FN_CMEM "../../matlab/fir/cmem_input.txt"
`define MATLAB_INPUT_FN_IMEM "../../matlab/fir/imem_input.txt"
`define QSIM_OUT_FN "./qsim.out"

// testbench for ../../dc/fir/fifo.nl.v

module testbench();
    reg [5:0] caddr;
    reg [5:0] iaddr;
    reg [15:0] din;
    reg [15:0] cin;
    reg clk1, clk2, rstn, valid_in, ren, update, cen, wen;
    wire [15:0] dout;
    wire valid_out;

    integer i; // loop counter for 64 inputs
    integer error_count;
    reg [15:0] expected;
    integer input_file;
    integer qsim_out_file;

    // variables for reading the input/output files, need to be decimals
    integer ret_read;

    // instantiate the unit under test
    datapath datapath_0 (
        .clk1(clk1),
        .clk2(clk2),
        .rstn(rstn),
        .valid_in(valid_in),
        .ren(ren),
        .update(update),
        .caddr(caddr),
        .cen(cen),
        .wen(wen),
        .iaddr(iaddr),
        .din(din),
        .cin(cin),
        .valid_out(valid_out),
        .dout(dout)
    );

    always begin
        `HALF_CLOCK_PERIOD_1;
        clk1 = ~clk1;
    end

    always begin
        `HALF_CLOCK_PERIOD_2;
        clk2 = ~clk2;
    end

    // open MATLAB coefficient file

    initial begin
        // open MATLAB input file
        cmem_input_file = $fopen(`MATLAB_INPUT_FN_CMEM, "r");
        if (input_file == 0) begin
            $display("Error opening MATLAB input file");
            $finish;
        end

        imem_input_file = $fopen(`MATLAB_INPUT_FN_IMEM, "r");
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

        $dumpfile("./datapath.vcd");
        $dumpvars(0,testbench.datapath_0);

        // register setup
        clk1 = 0;
        clk2 = 0;
        rstn = 0;
        
        // CMEM setup
        cen = 0;
        wen = 0;
        caddr = 5'd0;
        cin = 16'd0;

        //IMEM setup
        update = 0;
        iaddr = 5'd0;

        // FIFO setup
        valid_in = 1;
        ren = 1;
        din = 16'd0;

        @ (posedge clk2);
        
        @ (negedge clk2);
        rstn = 1;

        @ (posedge clk2);
        for (i=0; i<64; i=i+1) begin
            if (empty) begin
                // read input from file file
                wen = 1;
                ret_read = $fscanf(input_file, "%b\n", din);
                $display("Read: %d", din);
                // #10;
  
                // compare with output from MATLAB
                if (dout != expected) begin
                    $display("Error: output mismatch");
                    $display("Expected: %d, Got: %d", expected, dout);
                    error_count = error_count + 1;
                end
                $fwrite(qsim_out_file, "%b\n", dout);
                expected = din;
            end
            else begin
                wen = 0;
            end
            // repeat 64(100) times
            @(posedge clk2) begin
                if (~empty)
                    ren = 1;
                else
                    ren = 0;
            end
            @ (posedge clk1);
        end

        if (error_count == 0) begin
            $display("All tests passed");
        end else begin
            $display("Error: %d tests failed", error_count);
        end

        $fclose(input_file);
        $fclose(qsim_out_file);

        $dumpall;
        $dumpflush;

        $finish;

    end

endmodule

