onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider "Control"
add wave -noupdate sim:/tb_conv_core_int8/clk
add wave -noupdate sim:/tb_conv_core_int8/rst_n
add wave -noupdate sim:/tb_conv_core_int8/in_valid
add wave -noupdate sim:/tb_conv_core_int8/out_valid

add wave -noupdate -divider "Pixels p00..p22"
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/p00
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/p01
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/p02
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/p10
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/p11
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/p12
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/p20
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/p21
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/p22

add wave -noupdate -divider "Weights w00..w22"
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/w00
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/w01
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/w02
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/w10
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/w11
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/w12
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/w20
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/w21
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/w22

add wave -noupdate -divider "MAC products m00..m22"
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/dut/u_mac_3x3/m00
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/dut/u_mac_3x3/m01
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/dut/u_mac_3x3/m02
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/dut/u_mac_3x3/m10
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/dut/u_mac_3x3/m11
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/dut/u_mac_3x3/m12
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/dut/u_mac_3x3/m20
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/dut/u_mac_3x3/m21
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/dut/u_mac_3x3/m22

add wave -noupdate -divider "Result"
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/bias
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/dut/u_mac_3x3/product_sum
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/dut/u_mac_3x3/sum
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/sum_before_relu
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/dut/relu_out
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/out_int32
add wave -noupdate -radix decimal sim:/tb_conv_core_int8/out_int16

TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 180
configure wave -valuecolwidth 96
configure wave -justifyvalue left
configure wave -signalnamewidth 0
update
WaveRestoreZoom {0 ps} {900000 ps}
