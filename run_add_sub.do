# ============================================================
# run_add_sub.do  –  ModelSim script for add_sub module
# CMPS101 Logic Design – Spring 2026, Cairo University CCE
#
# Usage:  In ModelSim Tcl console:
#           do run_add_sub.do
# ============================================================

# Create / reset the work library
vlib work
vmap work work

# ── Compile all source files (order matters: primitives first) ──
vlog -sv "half_adder.v"
vlog -sv "full_adder.v"
vlog -sv "add_sub.v"
vlog -sv "add_sub_tb.v"

# ── Launch simulation ──
vsim work.add_sub_tb

# ── Add all signals to the wave window ──
add wave -divider "INPUTS (DECIMAL)"
add wave -radix decimal -label "A (Decimal)" /add_sub_tb/ia
add wave -radix decimal -label "B (Decimal)" /add_sub_tb/ib
add wave -radix binary /add_sub_tb/op

add wave -divider "INPUTS (SIGN-MAGNITUDE BINARY)"
add wave -radix binary -label "A (Binary)" /add_sub_tb/A
add wave -radix binary -label "B (Binary)" /add_sub_tb/B

add wave -divider "OUTPUTS (DECIMAL)"
add wave -radix decimal -label "Result (Decimal)" /add_sub_tb/res_val

add wave -divider "OUTPUTS (SIGN-MAGNITUDE BINARY)"
add wave -radix binary -label "Result R (Binary)" /add_sub_tb/R

add wave -divider "FLAGS"
add wave /add_sub_tb/SF
add wave /add_sub_tb/ZF
add wave /add_sub_tb/EF
add wave /add_sub_tb/OF

# ── Run until testbench calls $stop ──
run -all

# ── Show waveform ──
wave zoom full
