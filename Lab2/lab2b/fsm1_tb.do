-- do file for fsm1_tb / ljs Sep 11 2023 

restart -f -nowave
config wave -signalnamewidth 1

add wave clk
add wave reset

add wave -divider Inputs 
add wave d
add wave load
add wave start

add wave -divider Outputs
add wave shout 
add wave done

add wave -divider Internal
add wave fsm1_inst/next_state
add wave fsm1_inst/cur_state
add wave fsm1_inst/count
add wave fsm1_inst/spi_clk
add wave fsm1_inst/input_buffer

run 6000ns

view signals wave
