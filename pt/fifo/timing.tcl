###################################################################### 
## Timing setup for logic synthesis
## The unit for time is ns as defined in the IBM delay-power library
## The unit for wireload is pF as defined in the IBM delay-power library
## MS 2015
###################################################################### 

# Setting variables 
set clk2_period 100.00
set clk_uncertainty 0
set clk_transition 0.010
set typical_input_delay 0.05
set typical_output_delay 0.05
set typical_wire_load 0.005

#Create real clock 2 if clock port 2 is found
if {[sizeof_collection [get_ports clk2]] > 0} {
  set clk2_name "clk2"
  set clk2_port "clk2"
  #If no waveform is specified, 50% duty cycle is assumed
  create_clock -name $clk2_name -period $clk2_period [get_ports $clk2_port] 
  set_drive 0 [get_clocks $clk2_name] 
}

#Set clock uncertainty
set_clock_uncertainty $clk_uncertainty [get_clocks $clk2_name]
set_clock_transition $clk_transition [get_clocks $clk2_name]

# Set input and output delays
set_driving_cell -lib_cell INVX1TS [all_inputs]
set_input_delay $typical_input_delay {ren} -clock $clk2_name 
remove_input_delay -clock $clk2_name [find port $clk2_port]
set_output_delay $typical_output_delay {dout} -clock $clk2_name 

# Set loading of outputs 
set_load 0.005 [all_outputs] 
