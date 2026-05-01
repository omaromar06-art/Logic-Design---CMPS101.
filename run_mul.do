# ============================================================
# run_mul.do  –  ModelSim script for mul module
# CMPS101 Logic Design – Spring 2026, Cairo University CCE
#
# Usage:  In ModelSim Tcl console:
#           do run_mul.do
# ============================================================

# Create / reset the work library
vlib work
vmap work work

# ── Compile all source files (order matters: primitives first) ──
vlog -sv "half_adder.v"
vlog -sv "full_adder.v"
vlog -sv "mul.v"
vlog -sv "mul_tb.v"

# ── Launch simulation ──
vsim work.mul_tb

# ── Add all signals to the wave window ──
add wave -divider "INPUTS (DECIMAL)"
add wave -radix decimal -label "A (Decimal)" /mul_tb/ia
add wave -radix decimal -label "B (Decimal)" /mul_tb/ib

add wave -divider "INPUTS (SIGN-MAGNITUDE BINARY)"
add wave -radix binary -label "A (Binary)" /mul_tb/A
add wave -radix binary -label "B (Binary)" /mul_tb/B

add wave -divider "OUTPUTS (DECIMAL)"
add wave -radix decimal -label "Result (Decimal)" /mul_tb/res_val

add wave -divider "OUTPUTS (SIGN-MAGNITUDE BINARY)"
add wave -radix binary -label "Result R (Binary)" /mul_tb/R

add wave -divider "FLAGS"
add wave /mul_tb/SF
add wave /mul_tb/ZF
add wave /mul_tb/EF
add wave /mul_tb/OF

# ── Run until testbench calls $stop or $finish ──
run -all

# ── Show waveform ──
wave zoom full
