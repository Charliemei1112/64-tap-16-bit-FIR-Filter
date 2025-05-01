module controller(
    input clk2, rstn, EMPTY,
    output reg WEN, VALID_OUT, CLEAR, // unconditional signals
    output reg UPDATE, 
    output reg REN, // conditional signals
    output reg [5:0] cmem_counter, imem_counter,
    output reg [2:0] state
);

// state variables
// reg [1:0] state;
reg [2:0] next_state;

// counter variable
reg [5:0] cmem_next_counter, imem_next_counter;

// Define States (S0 - S3)
parameter S0 = 3'b000; // State 0, CMEM load state
parameter S1 = 3'b001; // State 1, idle (default) state
parameter S2 = 3'b011; // State 2, FIR compute (CMEM,IMEM,ALU) state
parameter S3 = 3'b110; // State 3, Done (when output signal is ready) state
parameter S4 = 3'b111; // State 4, FIR compute (CMEM,IMEM,ALU) state

always @(*) begin
    // default values
    // Assume next_state == state unless mentioned otherwise
    next_state = state;
    cmem_next_counter = cmem_counter;
    imem_next_counter = imem_counter;
    WEN = 1;
    UPDATE = 0;
    CLEAR = 0;
    VALID_OUT = 0;
    REN = 0;

    case(state)
        S0: begin
            WEN = 0;
            if (cmem_counter < 63) begin
                cmem_next_counter = cmem_counter + 1;
            end
            else begin
                cmem_next_counter = 0;
                next_state = S1;
            end
        end
        S1: begin
            if (~EMPTY) begin
                next_state = S2;
                UPDATE = 1;
                cmem_next_counter = 0;
                imem_next_counter = 0;
                // CLEAR = 1;
                REN = 1;
            end
            else begin
                next_state = S1;
            end
        end
        S2: begin
            if (imem_counter > 0) begin
                CLEAR = 1;
            end
            if (imem_counter < 63) begin
                cmem_next_counter = cmem_counter + 1;
                imem_next_counter = imem_counter + 1;
            end
            else begin
                imem_next_counter = 0;
                cmem_next_counter = 0;
                next_state = S4;
            end
        end
        S3: begin
            VALID_OUT = 1;
            if (EMPTY) begin
                next_state = S1;
            end
            else begin
                next_state = S2;
                UPDATE = 1;
                cmem_next_counter = 0;
                imem_next_counter = 0;
                // CLEAR = 1;
                REN = 1;
            end
        end
        S4: begin
            CLEAR = 1;
            next_state = S3;
        end
        default: begin
            next_state = S1;
        end
    endcase
end

always @(posedge clk2 or negedge rstn) begin
    if (~rstn) begin
        imem_counter <= 6'd0;
        cmem_counter <= 6'd0;
        state <= S0;
    end
    else begin
        state <= next_state;
        cmem_counter <= cmem_next_counter;
        imem_counter <= imem_next_counter;
    end
end

endmodule