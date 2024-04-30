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
EXPECTED_ARGS=7
if [ $# -ne $EXPECTED_ARGS ]; then
  echo "ERROR    : wrong number of arguments"
  echo "USAGE    : asm2ihex.sh <test name> <test assembler file> <linker script> <assembler define>  <prog mem size> <data mem size> <peripheral addr space size>"
  echo "Example  : asm2ihex.sh c-jump_jge  ../src/c-jump_jge.s43 ../bin/template.x ../bin/pmem.h 2048            128             512"
  exit 1
fi


###############################################################################
#               Check if definition & assembler files exist                   #
###############################################################################

if [ ! -e $2 ]; then
    echo "Assembler file doesn't exist: $2"
    exit 1
fi
if [ ! -e $3 ]; then
    echo "Linker definition file template doesn't exist: $3"
    exit 1
fi
if [ ! -e $4 ]; then
    echo "Assembler definition file template doesn't exist: $4"
    exit 1
fi


###############################################################################
#               Generate the linker definition file                           #
###############################################################################

PER_SIZE=$7
DMEM_SIZE=$6
PMEM_SIZE=$5
PMEM_BASE=$((0x10000-$PMEM_SIZE))
STACK_INIT=$((PER_SIZE+0x0080))

cp  $3  ./pmem.x
cp  $4  ./pmem_defs.asm
sed -i "s/PMEM_BASE/$PMEM_BASE/g"    pmem.x
sed -i "s/PMEM_SIZE/$PMEM_SIZE/g"    pmem.x
sed -i "s/DMEM_SIZE/$DMEM_SIZE/g"    pmem.x
sed -i "s/PER_SIZE/$PER_SIZE/g"      pmem.x
sed -i "s/STACK_INIT/$STACK_INIT/g"  pmem.x

sed -i "s/PER_SIZE/$PER_SIZE/g"      pmem_defs.asm
sed -i "s/PMEM_SIZE/$PMEM_SIZE/g"    pmem_defs.asm


###############################################################################
#                  Compile, link & generate IHEX file                         #
###############################################################################
msp430-as      -alsm         $2     -o $1.o     > $1.l43
msp430-objdump -xdsStr       $1.o              >> $1.l43
msp430-ld      -T ./pmem.x   $1.o   -o $1.elf
msp430-objcopy -O ihex       $1.elf    $1.ihex
