#!/bin/bash
source ../../../../settings64_msim.sh

# Enable/Disable waveform dumping
OMSP_NODUMP=0
export OMSP_NODUMP

# Choose simulator:
#                   - iverilog  : Icarus Verilog  (default)
#                   - msim      : ModelSim
#                   - isim      : Xilinx Simulator
OMSP_SIMULATOR=msim
export OMSP_SIMULATOR

../bin/msp430sim.sh leds
