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
##              MPSoC-SPRAM CPU                                                  ##
##              Synthesis Test Makefile                                          ##
##                                                                               ##
###################################################################################

###################################################################################
##                                                                               ##
## Copyright (c) 2018-2019 by the author(s)                                      ##
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
##   Francisco Javier Reina Campo <frareicam@gmail.com>                          ##
##                                                                               ##
###################################################################################

read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/fuse/msp430_and_gate.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/fuse/msp430_clock_gate.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/fuse/msp430_clock_mux.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/fuse/msp430_scan_mux.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/fuse/msp430_sync_cell.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/fuse/msp430_sync_reset.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/fuse/msp430_wakeup_cell.vhd

read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/omsp/msp430_alu.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/omsp/msp430_dbg_hwbrk.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/omsp/msp430_dbg_i2c.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/omsp/msp430_dbg_uart.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/omsp/msp430_register_file.vhd

read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_bcm.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_dbg.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_execution.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_gpio.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_memory.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_multiplier.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_template08.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_template16.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_uart.vhd

read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_frontend.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_sfr.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_ta.vhd
read_vhdl -vhdl2008 ../../../../rtl/vhdl/core/main/msp430_watchdog.vhd

read_vhdl -vhdl2008 ../../../../rtl/vhdl/pu/msp430_core.vhd

read_vhdl -vhdl2008 spram/core/msp430_ram.vhd

read_vhdl -vhdl2008 msp430_synthesis.vhd

read_xdc system.xdc

synth_design -part xc7z020-clg484-1 -top msp430_synthesis

opt_design
place_design
route_design

report_utilization
report_timing

write_bitstream -force system.bit
