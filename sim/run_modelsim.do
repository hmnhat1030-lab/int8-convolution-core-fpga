vlib work
vlog -reportprogress 300 mac_3x3.v relu.v quant_clip.v kernel_rom.v conv_core_int8.v tb_compare_python_rtl.v
vsim -voptargs="+acc" work.tb_compare_python_rtl

add wave -divider "Control"
add wave sim:/tb_compare_python_rtl/clk
add wave sim:/tb_compare_python_rtl/rst_n
add wave sim:/tb_compare_python_rtl/in_valid
add wave sim:/tb_compare_python_rtl/out_valid

add wave -divider "Window Pixels"
add wave -radix decimal sim:/tb_compare_python_rtl/p00
add wave -radix decimal sim:/tb_compare_python_rtl/p01
add wave -radix decimal sim:/tb_compare_python_rtl/p02
add wave -radix decimal sim:/tb_compare_python_rtl/p10
add wave -radix decimal sim:/tb_compare_python_rtl/p11
add wave -radix decimal sim:/tb_compare_python_rtl/p12
add wave -radix decimal sim:/tb_compare_python_rtl/p20
add wave -radix decimal sim:/tb_compare_python_rtl/p21
add wave -radix decimal sim:/tb_compare_python_rtl/p22

add wave -divider "Kernel"
add wave -radix decimal sim:/tb_compare_python_rtl/w00
add wave -radix decimal sim:/tb_compare_python_rtl/w01
add wave -radix decimal sim:/tb_compare_python_rtl/w02
add wave -radix decimal sim:/tb_compare_python_rtl/w10
add wave -radix decimal sim:/tb_compare_python_rtl/w11
add wave -radix decimal sim:/tb_compare_python_rtl/w12
add wave -radix decimal sim:/tb_compare_python_rtl/w20
add wave -radix decimal sim:/tb_compare_python_rtl/w21
add wave -radix decimal sim:/tb_compare_python_rtl/w22

add wave -divider "Result"
add wave -radix decimal sim:/tb_compare_python_rtl/out_index
add wave -radix decimal sim:/tb_compare_python_rtl/out_int32
add wave -radix decimal sim:/tb_compare_python_rtl/out_int8
add wave -radix decimal sim:/tb_compare_python_rtl/pass_count
add wave -radix decimal sim:/tb_compare_python_rtl/fail_count

run -all
wave zoom full
