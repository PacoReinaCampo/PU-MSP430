#!/bin/bash
export PATH=$PATH:/opt/intelFPGA_pro/20.2/modelsim_ase/linuxaloem/

# Disable waveform dumping
OMSP_NODUMP=1
export OMSP_NODUMP

# Choose simulator:
#                   - iverilog  : Icarus Verilog  (default)
#                   - msim      : ModelSim
#                   - isim      : Xilinx Simulator
OMSP_SIMULATOR=msim
export OMSP_SIMULATOR

rm -rf ./cov_work
rm -rf ./log/*.log
mkdir  ./log

# Peripheral templates test patterns
../bin/msp430sim template_periph_8b       | tee ./log/template_periph_8b.log
../bin/msp430sim template_periph_16b      | tee ./log/template_periph_16b.log


# Report regression results
../bin/parse.results.sh
