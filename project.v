module Project (
    input wire clk,           // System clock
    input wire reset_n,       // Active-low reset
    input wire start,         // Start condition (trigger FSM)
    input wire stop,          // Stop condition
    input wire [7:0] data_in, // Data to send
    input wire ack_in,        // Acknowledge signal from slave
    output reg scl,           // I2C clock
    output reg sda,           // I2C data line
    output reg busy,          // Indicates that I2C is busy
    output reg done           // Indicates that the I2C transfer is complete
);

    // State Encoding using Parameters
    parameter IDLE   = 3'b000;
    parameter START  = 3'b001;
    parameter ADDR   = 3'b010;
    parameter DATA   = 3'b011;
    parameter STOP   = 3'b100;

    reg [2:0] state, next_state; // State registers

    // Clock division for low power (simplified)
    reg [15:0] clk_div; 
    wire clk_div_en = clk_div == 16'hFFFF; // Adjust for desired clock period

    // FSM transitions based on state
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= IDLE;
        else if (clk_div_en)
            state <= next_state;
    end

    // Output logic and state transitions
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            scl <= 1;
            sda <= 1;
            busy <= 0;
            done <= 0;
            clk_div <= 0;
        end else if (clk_div_en) begin
            case (state)
                IDLE: begin
                    busy <= 0;
                    done <= 0;
                    if (start) begin
                        next_state <= START;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                START: begin
                    busy <= 1;
                    sda <= 0;        // Initiate START condition
                    scl <= 0;
                    next_state <= ADDR;
                end

                ADDR: begin
                    // Send 7-bit address + R/W bit (8 bits total)
                    sda <= data_in[7];  // Send most significant bit first
                    scl <= 1;
                    // Assume clock stretching is managed here (by slave pulling clock low)
                    if (ack_in) begin
                        next_state <= DATA;
                    end else begin
                        next_state <= ADDR;  // Wait for ACK
                    end
                end

                DATA: begin
                    // Send data bits (byte)
                    sda <= data_in[7];
                    scl <= 1;
                    if (ack_in) begin
                        next_state <= STOP;
                    end else begin
                        next_state <= DATA;  // Wait for ACK
                    end
                end

                STOP: begin
                    sda <= 0;       // Initiate STOP condition
                    scl <= 1;
                    next_state <= IDLE;
                    done <= 1;
                    busy <= 0;
                end
            endcase
        end
    end

    // Clock divider logic to reduce clock rate for low-power operation
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_div <= 0;
        end else if (clk_div_en) begin
            clk_div <= 0;  // Reset clock divider
        end else begin
            clk_div <= clk_div + 1;
        end
    end

endmodule
