#restart -f -nowave
vsim -t ns test

add wave -color yellow in_data
add wave -color green out_data

force in_data 10
run 100 ns
force in_data 100
run 50 ns
force in_data 101011
run 100 ns


