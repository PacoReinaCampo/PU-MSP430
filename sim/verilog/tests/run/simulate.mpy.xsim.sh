#!/bin/bash
export PATH=$PATH:/opt/Xilinx/Vivado/2020.2/bin/

# Enable/Disable waveform dumping
OMSP_NODUMP=1
export OMSP_NODUMP

# Choose simulator:
#                   - iverilog  : Icarus Verilog  (default)
#                   - msim      : ModelSim
#                   - xsim      : Xilinx Simulator
OMSP_SIMULATOR=xsim
export OMSP_SIMULATOR

rm -rf ./log/*.log
mkdir  ./log

echo ""
echo " ===================================================="
echo "| WARNING: Complete Hardware Multiplier verification |"
echo "|         regression might take several hours.       |"
echo " ===================================================="
echo ""

# Hardware multiplier test patterns
../bin/msp430sim.sh mpy_basic   | tee  ./log/mpy_basic.log
../bin/msp430sim.sh mpy_mpy     | tee  ./log/mpy_mpy.log
../bin/msp430sim.sh mpy_mpys    | tee  ./log/mpy_mpys.log
../bin/msp430sim.sh mpy_mac     | tee  ./log/mpy_mac.log
../bin/msp430sim.sh mpy_macs    | tee  ./log/mpy_macs.log

grep SKIPPED ./log/*.log
grep FAILED  ./log/*.log
echo ""
echo " ================================"
echo -n "| Number of passed patterns : "
cat ./log/*.log | grep -c PASSED
echo -n "| Number of failed patterns : "
cat ./log/*.log | grep -c FAILED
echo -n "| Number of skipped patterns: "
cat ./log/*.log | grep -c SKIPPED
echo "|--------------------------------"
echo -n "| Number of patterns:        "
ls -1 ./log/*.log | wc -l
echo " ================================"
echo " Make sure passed == total"
echo ""
echo ""
