# ============================================================
# run_alu.do  –  ModelSim script for ALU top-level testbench
# CMPS101 Logic Design – Spring 2026, Cairo University CCE
#
# Usage:  In ModelSim Tcl console:
#           do run_alu.do
# ============================================================

# Create / reset the work library
vlib work
vmap work work

# ── Compile source files ──
vlog -sv "full_adder.v"
vlog -sv "half_adder.v"
vlog -sv "add_sub.v"
vlog -sv "mul.v"
vlog -sv "alu.v"
vlog -sv "alu_tb.v"

# ── Launch simulation ──
vsim work.alu_tb

# ── Wave window setup ──

add wave -divider "CONTROL"
add wave -radix binary  -label "S[1:0]" /alu_tb/S

add wave -divider "INPUTS (DECIMAL)"
add wave -radix decimal -label "A (dec)" /alu_tb/ia
add wave -radix decimal -label "B (dec)" /alu_tb/ib

add wave -divider "INPUTS (BINARY)"
add wave -radix binary  -label "A [2:0]" /alu_tb/A
add wave -radix binary  -label "B [2:0]" /alu_tb/B

add wave -divider "RESULT"
add wave -radix binary  -label "R[4:0]" /alu_tb/R

add wave -divider "FLAGS"
add wave -label "SF (Sign)"      /alu_tb/SF
add wave -label "ZF (Zero)"      /alu_tb/ZF
add wave -label "DZF (DivZero)"  /alu_tb/DZF
add wave -label "EF (Even)"      /alu_tb/EF
add wave -label "OF (Odd)"       /alu_tb/OF

add wave -divider "INTERNAL: add_sub"
add wave -radix binary -label "add_sub_R[3:0]" /alu_tb/dut/add_sub_R

add wave -divider "INTERNAL: multip"
add wave -radix binary -label "mult_R[4:0]" /alu_tb/dut/mult_R

# ── Run until $stop ──
run -all

# ── Auto-zoom waveform ──
wave zoom full
