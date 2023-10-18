###################################################################################
##                                            __ _      _     _                  ##
##                                           / _(_)    | |   | |                 ##
##                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |                 ##
##               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |                 ##
##              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |                 ##
##               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|                 ##
##                  | |                                                          ##
##                  |_|                                                          ##
##                                                                               ##
##                                                                               ##
##              Architecture                                                     ##
##              QueenField                                                       ##
##                                                                               ##
###################################################################################

###################################################################################
##                                                                               ##
## Copyright (c) 2019-2020 by the author(s)                                      ##
##                                                                               ##
## Permission is hereby granted, free of charge, to any person obtaining a copy  ##
## of this software and associated documentation files (the "Software"), to deal ##
## in the Software without restriction, including without limitation the rights  ##
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     ##
## copies of the Software, and to permit persons to whom the Software is         ##
## furnished to do so, subject to the following conditions:                      ##
##                                                                               ##
## The above copyright notice and this permission notice shall be included in    ##
## all copies or substantial portions of the Software.                           ##
##                                                                               ##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    ##
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      ##
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   ##
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        ##
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, ##
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN     ##
## THE SOFTWARE.                                                                 ##
##                                                                               ##
## ============================================================================= ##
## Author(s):                                                                    ##
##   Paco Reina Campo <pacoreinacampo@queenfield.tech>                           ##
##                                                                               ##
###################################################################################

#!/bin/bash
source ../../../../../../../settings64_msim.sh

# Enable/Disable waveform dumping
OMSP_NODUMP=1
export OMSP_NODUMP

# Choose simulator:
#                   - iverilog  : Icarus Verilog  (default)
#                   - msim      : ModelSim
#                   - isim      : Xilinx Simulator
OMSP_SIMULATOR=msim
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
