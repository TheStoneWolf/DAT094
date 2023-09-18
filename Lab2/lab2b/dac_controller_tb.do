restart -f -nowave
config wave -signalnamewidth 1

add wave clk
add wave rst
add wave -divider Inputs
add wave enable
add wave channel
add wave gain
add wave shutdown
add wave data
add wave -divider Flags
add wave busy
add wave -divider SPI
add wave dac_cs
add wave dac_sck
add wave dac_sdi
add wave -divider "DUT Internal Signals"
add wave -color yellow dac_controller_inst/counter
add wave -color yellow dac_controller_inst/current_state
add wave -color yellow dac_controller_inst/next_state

run 2000ns

view signals wave