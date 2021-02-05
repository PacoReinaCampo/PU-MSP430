#!/bin/bash
source ../../../../settings64_vivado.sh

# Enable/Disable waveform dumping
OMSP_NODUMP=0
export OMSP_NODUMP

# Choose simulator:
#                   - iverilog  : Icarus Verilog  (default)
#                   - msim      : ModelSim
#                   - xsim      : Xilinx Simulator
OMSP_SIMULATOR=xsim
export OMSP_SIMULATOR

../bin/msp430sim.sh leds
