#!/usr/bin/env tclsh
read_hdl -vhdl riscv_pkg.vhd
read_hdl -vhdl riscv_adder.vhd 
read_hdl -vhdl riscv_pc.vhd
read_hdl -vhdl riscv_rf.vhd
read_hdl -vhdl riscv_alu.vhd
read_hdl -vhdl memory_access.vhd 
read_hdl -vhdl fetch.vhd
read_hdl -vhdl decode.vhd
read_hdl -vhdl execute.vhd
read_hdl -vhdl write_back.vhd
read_hdl -vhdl riscv_core.vhd

elaborate riscv_core.vhd
check_design -unresolved
