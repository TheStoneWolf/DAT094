-- do file for fsm2_tb / Sj Sep 20 2023 

restart -f -nowave
config wave -signalnamewidth 1

add wave clk
add wave reset

add wave -divider Inputs 
add wave enable
add wave done
add wave spi_clk

add wave -divider Outputs
add wave load 
add wave start
add wave shout
add wave dac_cs
add wave busy

add wave -divider Internal
add wave fsm2_inst/next_state
add wave fsm2_inst/cur_state

run 6000ns

view signals wave
