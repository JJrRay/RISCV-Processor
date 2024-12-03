# Fichier     : sim_syn.tcl
# Description : Compilation et simulation temporelle
# ------------------------------------------------------------
set work    "./work"
set srcD    "../sources"
set top     "riscv_core"
set tb      "${top}_tb"
set net     "../implementation/syn/base_netlist/${top}.syn"
set vcd     "${top}.syn.vcd"
set wave    "${top}_wave"
set dut     "dut"
set dpm     "dpm"

# Copie du fichier modelsim.ini et association de la librairie des cellules standards
vmap -c
vmap gsclib045 /CMC/kits/GPDK45/simlib/gsclib045_slow

# Mise à jour de la librairie de travail
if { [file exists $work] } {
    vdel -all -lib $work
}
vlib $work
vmap work $work

# Compilation
vlog -work work $net.v
vcom -2008 -work work $srcD/$dpm.vhd
vcom -2008 -work work $srcD/$tb.vhd

# Simulation
vsim -L gsclib045 -t ps -sdfmax $dut=$net.sdf work.$tb

# Enregistrement de l'activité au format VCD
vcd file $vcd
vcd add /$tb/$dut/*

# Exécution
do $wave.do
run -all
vcd flush
