##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

#Setup
 vlib work 
 vmap work work

#Include Netlist and Testbench
 vlog +acc -incr ../../rtl/fir/fir.v
 vlog +acc -incr ../../rtl/datapath/datapath.v
 vlog +acc -incr ../../rtl/controller/controller.v
 vlog +acc -incr test_fir.v 
 vlog +acc -incr ../../mem_comp/rf1shd/bin/RF1SHD.v

# Run Simulator 
vsim +acc -t ps -lib work testbench 
do waveformat.do   
run -all
