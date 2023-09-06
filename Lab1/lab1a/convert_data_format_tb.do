restart -f -nowave
config wave -signalnamewidth 1

add wave convert
add wave -divider "Binary Representation"
add wave -radix binary input output
add wave -divider "Signed Representation"
add wave -radix decimal input output
add wave -divider "Unsigned Representation"
add wave -radix unsigned input output

run 400ns

view signals wave