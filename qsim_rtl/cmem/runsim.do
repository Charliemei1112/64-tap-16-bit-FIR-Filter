##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

vlib work 
vmap work work

# Include Netlist and Testbench
vlog +acc -incr ../../mem_comp/rf1shd/bin/RF1SHD.v
vlog +acc -incr ../../rtl/cmem/cmem.v 
vlog +acc -incr test_cmem.v 

# Run Simulator 
vsim +acc -t ps -lib work testbench 
do waveformat.do   
run -all
