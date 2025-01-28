module project_tb;

    // Testbench signals
    reg clk; // System clock
    reg reset_n; // Active-low reset
    reg start; // Start condition (trigger FSM)
    reg stop; // Stop condition
    reg [7:0] data_in; // Data to send
    reg ack_in; // Acknowledge signal from slave
    wire scl; // I2C clock
    wire sda; // I2C data line
    wire busy; // Indicates that I2C is busy
    wire done; // Indicates that the I2C transfer is complete

    // Instantiate the I2C FSM module
    project_tb uut (
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .stop(stop),
        .data_in(data_in),
        .ack_in(ack_in),
        .scl(scl),
        .sda(sda),
        .busy(busy),
        .done(done)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // Toggle clock every 5 time units (100MHz clock)
    end

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        start = 0;
        stop = 0;
        data_in = 8'b0;
        ack_in = 0;

        // Apply reset
        #10 reset_n = 1; // Release reset after 10 time units

        // Test 1: Start condition and address transmission
        #10;
        start = 1; // Trigger start condition
        data_in = 8'b10101010; // Example address to send (7-bit address + R/W bit)
        ack_in = 1; // Assume slave acknowledges address
        #10;
        start = 0; // Clear start condition

        // Test 2: Data transmission
        #10;
        data_in = 8'b11001100; // Example data to send
        ack_in = 1; // Assume slave acknowledges data
        #10;

        // Test 3: Stop condition
        #10;
        stop = 1; // Trigger stop condition
        #10;
        stop = 0; // Clear stop condition

        // Test 4: No acknowledge from slave
        #10;
        start = 1; // Trigger start condition again
        data_in = 8'b11110000; // New address
        ack_in = 0; // No acknowledge from slave
        #10;
        start = 0; // Clear start condition

        // Test 5: Another data transmission after address
        #10;
        data_in = 8'b00001111; // New data
        ack_in = 1; // Slave acknowledges
        #10;

        // Test 6: Final stop condition
        #10;
        stop = 1; // Trigger stop condition again
        #10;
        stop = 0; // Clear stop condition

        // End simulation
        #10;
        $stop; // Stop the simulation
    end

    // Monitor signals
    initial begin
        $monitor("Time: %0t, clk: %b, reset_n: %b, start: %b, stop: %b, data_in: %b, ack_in: %b, scl: %b, sda: %b, busy: %b, done: %b",
                 $time, clk, reset_n, start, stop, data_in, ack_in, scl, sda, busy, done);
    end

endmodule


