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
add wave -divider FSM1
add wave -color yellow dac_controller_inst/fsm1_inst/cur_state
add wave -color yellow dac_controller_inst/fsm1_inst/next_state
add wave -color yellow dac_controller_inst/shout_1
add wave -color yellow dac_controller_inst/fsm1_inst/count
add wave -color yellow dac_controller_inst/done

add wave -divider FSM2
add wave -color purple dac_controller_inst/fsm2_inst/cur_state
add wave -color purple dac_controller_inst/fsm2_inst/next_state
add wave -color purple dac_controller_inst/shout_2

run 2000ns

view signals wave