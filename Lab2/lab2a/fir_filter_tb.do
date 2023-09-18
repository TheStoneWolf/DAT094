restart -f -nowave
config wave -signalnamewidth 1

add wave clk
add wave rst
add wave enable
add wave input
add wave output
add wave -divider "Analog Style Waveforms"
add wave -radix decimal -format analog-step -height 100 -max 127 -min -128 input
add wave -radix decimal -format analog-step -height 100 -max 127 -min -128 output

run 5000ns

view signals wave
wave zoom full