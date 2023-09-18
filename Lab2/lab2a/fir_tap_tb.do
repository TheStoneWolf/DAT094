restart -f -nowave
config wave -signalnamewidth 1

add wave -divider "Binary Representation"
add wave -radix binary data
add wave -radix binary coefficient
add wave -radix binary prev_result
add wave -radix binary result 
add wave -divider "Signed Representation"
add wave -radix decimal data
add wave -radix decimal coefficient
add wave -radix decimal prev_result
add wave -radix decimal result 

run 1200ns

view signals wave
wave zoom full