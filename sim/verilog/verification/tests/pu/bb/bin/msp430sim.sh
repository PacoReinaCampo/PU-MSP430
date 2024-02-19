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

###############################################################################
#                            Parameter Check                                  #
###############################################################################
EXPECTED_ARGS=1
if [ $# -ne $EXPECTED_ARGS ]; then
  echo "ERROR    : wrong number of arguments"
  echo "USAGE    : msp430sim <test name>"
  echo "Example  : msp430sim c-jump_jge"
  echo ""
  echo "In order to switch the verilog simulator, the OMSP_SIMULATOR environment"
  echo "variable can be set to the following values:"
  echo ""
  echo "                  - iverilog  : Icarus Verilog  (default)"
  echo "                  - msim      : ModelSim"
  echo "                  - xsim      : Xilinx Simulator"
  echo ""
  exit 1
fi


###############################################################################
#                     Check if the required files exist                       #
###############################################################################
asmfile=../../../../../../../software/tests/asm/$1.s43;
verfile=../../../../../../../bench/verilog/tests/cases/$1.sv;
incfile=../../../../../../../rtl/verilog/pkg/pu_msp430_defines.sv;
linkfile=../bin/template.x;
headfile=../bin/template_defs.asm;
if [ $OMSP_SIMULATOR == "iverilog" ]; then
    submit=../src/submit.f;
fi
if [ $OMSP_SIMULATOR == "msim" ]; then
    submit=../src/submit.f;
fi
if [ $OMSP_SIMULATOR == "xsim" ]; then
    submit=../src/submit.prj;
fi

if [ ! -e $asmfile ]; then
    echo "Assembler file $asmfile doesn't exist: $asmfile"
    exit 1
fi
if [ ! -e $verfile ]; then
    echo "Verilog stimulus file $verfile doesn't exist: $verfile"
    exit 1
fi
if [ ! -e $submit ]; then
    echo "Verilog submit file $submit doesn't exist: $submit"
    exit 1
fi
if [ ! -e $linkfile ]; then
    echo "Linker definition file template doesn't exist: $linkfile"
    exit 1
fi
if [ ! -e $headfile ]; then
    echo "Assembler definition file template doesn't exist: $headfile"
    exit 1
fi


###############################################################################
#                               Cleanup                                       #
###############################################################################
echo "Cleanup..."
rm -rf *.vcd
rm -rf *.vpd
rm -rf *.trn
rm -rf *.dsn
rm -rf pmem*
rm -rf stimulus.sv


###############################################################################
#                              Run simulation                                 #
###############################################################################
echo " ======================================================="
echo "| Start simulation:             $1"
echo " ======================================================="

# Create links
if [ `uname -o` = "Cygwin" ]
then
    cp $asmfile pmem.s43
    cp $verfile stimulus.sv
else
    ln -s $asmfile pmem.s43
    ln -s $verfile stimulus.sv
fi

# Make local copy of the openMSP403 configuration file
# and prepare it for MSPGCC preprocessing
cp  $incfile  ./pmem.h
sed -i 's/`ifdef/#ifdef/g'         ./pmem.h 
sed -i 's/`else/#else/g'           ./pmem.h 
sed -i 's/`endif/#endif/g'         ./pmem.h 
sed -i 's/`define/#define/g'       ./pmem.h 
sed -i 's/`include/\/\/#include/g' ./pmem.h 
sed -i 's/`//g'                    ./pmem.h 
sed -i "s/'//g"                    ./pmem.h

# Use MSPGCC preprocessor to extract the Program, Data
# and Peripheral memory sizes
msp430-gcc -E -P -x c ../bin/omsp_config.sh > pmem.sh

# Source the extracted configuration file
source pmem.sh

# Compile assembler code
echo "Compile, link & generate IHEX file (Program Memory: $pmemsize B, Data Memory: $dmemsize B, Peripheral Space: $persize B)..."
../bin/asm2ihex.sh pmem pmem.s43 $linkfile $headfile $pmemsize $dmemsize $persize

# Generate Program memory file
echo "Convert IHEX file to Verilog MEMH format..."
../bin/ihex2mem.tcl -ihex pmem.ihex -out pmem.mem -mem_size $pmemsize

# Start verilog simulation
echo "Start Verilog simulation..."
../bin/rtlsim.sh stimulus.sv pmem.mem $submit
