onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider INPUTS
add wave -noupdate -radix unsigned /mul_tb/A
add wave -noupdate -radix unsigned /mul_tb/B
add wave -noupdate -divider OUTPUTS
add wave -noupdate -radix unsigned /mul_tb/R
add wave -noupdate -divider FLAGS
add wave -noupdate /mul_tb/SF
add wave -noupdate /mul_tb/ZF
add wave -noupdate /mul_tb/EF
add wave -noupdate /mul_tb/OF
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {480000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {514500 ps}
