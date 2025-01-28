create_clock -period 10 [get_pins i2c_fsm/clk]
set_reset_signal_network i2c_fsm/reset_n

# Define the I2C SCL and SDA signals
# SCL signal, driven by the module, so no special timing constraints required on SCL pin
# SDA signal, driven by the module, so no special timing constraints required on SDA pin

# Define timing constraints for the FSM to ensure the correct operation
# We expect that the FSM should complete in several clock cycles (no strict timing requirements beyond the clock period).

# Define the constraint for the clock divider logic
# The clock divider is controlled by the clk_div signal. We will assume a high enough clock frequency
# to ensure the clk_div register operates correctly for low power mode.

# Define timing exceptions
# If you want to allow more slack on specific paths (e.g., those with long delays), you can define exceptions here.
# For example, defining a longer path delay for the I2C data lines (sda and scl) if needed:
set_max_delay 5 -from [get_pins i2c_fsm/sda] -to [get_pins i2c_fsm/scl]

# Define input delays (optional, depending on input timing characteristics)
# Here we assume a standard delay for inputs, which should be adjusted based on your actual setup:
set_input_delay -max 5 [get_pins i2c_fsm/data_in]
set_input_delay -min 1 [get_pins i2c_fsm/data_in]

# Define output delays (optional, depending on your target environment)
# Here we set standard output delays for scl and sda lines:
set_output_delay -max 3 [get_pins i2c_fsm/scl]
set_output_delay -max 3 [get_pins i2c_fsm/sda]

# Define timing exceptions for different paths if needed, based on path analysis.

# End of SDC file


