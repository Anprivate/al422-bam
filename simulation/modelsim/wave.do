onerror {resume}
quietly WaveActivateNextPane {} 0
delete wave *
add wave -noupdate /al422_bam_vlg_tst/in_nrst
add wave -noupdate /al422_bam_vlg_tst/in_clk
add wave -noupdate /al422_bam_vlg_tst/al422_nrst
add wave -noupdate /al422_bam_vlg_tst/al422_re
add wave -noupdate -radix hexadecimal /al422_bam_vlg_tst/address
add wave -noupdate -radix hexadecimal /al422_bam_vlg_tst/memory_out
add wave -noupdate -radix hexadecimal /al422_bam_vlg_tst/al422_bam/in_data_buffer
add wave -noupdate -radix hexadecimal /al422_bam_vlg_tst/al422_bam/data_in_data_buffer_valid
add wave -noupdate -radix hexadecimal /al422_bam_vlg_tst/al422_bam/phase_cntr
add wave -noupdate /al422_bam_vlg_tst/al422_bam/last_phase
add wave -noupdate /al422_bam_vlg_tst/al422_bam/first_cycle_finished
add wave -noupdate /al422_bam_vlg_tst/al422_bam/rgb_tmp
add wave -noupdate /al422_bam_vlg_tst/rgb1
add wave -noupdate /al422_bam_vlg_tst/rgb2
add wave -noupdate /al422_bam_vlg_tst/al422_bam/out_data_valid
add wave -noupdate /al422_bam_vlg_tst/led_clk_out
add wave -noupdate -radix hexadecimal /al422_bam_vlg_tst/al422_bam/pixel_counter
add wave -noupdate /al422_bam_vlg_tst/al422_bam/last_pixel
add wave -noupdate /al422_bam_vlg_tst/al422_bam/data_in_panel_row_ready
add wave -noupdate /al422_bam_vlg_tst/cntr_nrst
add wave -noupdate /al422_bam_vlg_tst/led_lat_out
add wave -noupdate /al422_bam_vlg_tst/led_oe_out
add wave -noupdate /al422_bam_vlg_tst/led_row
add wave -noupdate -radix hexadecimal /al422_bam_vlg_tst/j
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {348 ps}
restart -force
run 20000
wave cursor time -time 0 1
wave cursor configure 1 -name default
wave cursor see 1