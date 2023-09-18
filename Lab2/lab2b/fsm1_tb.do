-- do file for fsm1_tb / ljs Sep 11 2023 

restart -f -nowave
config wave -signalnamewidth 1

add wave clk
add wave rst

add wave -divider Inputs
add wave enable 
add wave d
add wave load
add wave start

add wave -divider Outputs
add wave shout 
add wave done

run 6000ns

view signals wave
