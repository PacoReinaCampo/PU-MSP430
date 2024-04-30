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
##   Francisco Javier Reina Campo <pacoreinacampo@queenfield.tech>               ##
##                                                                               ##
###################################################################################

read_verilog -sv ../../../../rtl/verilog/core/fuse/msp430_and_gate.sv
read_verilog -sv ../../../../rtl/verilog/core/fuse/msp430_clock_gate.sv
read_verilog -sv ../../../../rtl/verilog/core/fuse/msp430_clock_mux.sv
read_verilog -sv ../../../../rtl/verilog/core/fuse/msp430_scan_mux.sv
read_verilog -sv ../../../../rtl/verilog/core/fuse/msp430_sync_cell.sv
read_verilog -sv ../../../../rtl/verilog/core/fuse/msp430_sync_reset.sv
read_verilog -sv ../../../../rtl/verilog/core/fuse/msp430_wakeup_cell.sv

read_verilog -sv ../../../../rtl/verilog/core/omsp/msp430_alu.sv
read_verilog -sv ../../../../rtl/verilog/core/omsp/msp430_dbg_hwbrk.sv
read_verilog -sv ../../../../rtl/verilog/core/omsp/msp430_dbg_i2c.sv
read_verilog -sv ../../../../rtl/verilog/core/omsp/msp430_dbg_uart.sv
read_verilog -sv ../../../../rtl/verilog/core/omsp/msp430_register_file.sv

read_verilog -sv ../../../../rtl/verilog/core/main/msp430_bcm.sv
read_verilog -sv ../../../../rtl/verilog/core/main/msp430_dbg.sv
read_verilog -sv ../../../../rtl/verilog/core/main/msp430_execution.sv
read_verilog -sv ../../../../rtl/verilog/core/main/msp430_gpio.sv
read_verilog -sv ../../../../rtl/verilog/core/main/msp430_memory.sv
read_verilog -sv ../../../../rtl/verilog/core/main/msp430_multiplier.sv
read_verilog -sv ../../../../rtl/verilog/core/main/msp430_template08.sv
read_verilog -sv ../../../../rtl/verilog/core/main/msp430_template16.sv
read_verilog -sv ../../../../rtl/verilog/core/main/msp430_uart.sv

read_verilog -sv ../../../../rtl/verilog/core/main/msp430_frontend.sv
read_verilog -sv ../../../../rtl/verilog/core/main/msp430_sfr.sv
read_verilog -sv ../../../../rtl/verilog/core/main/msp430_ta.sv
read_verilog -sv ../../../../rtl/verilog/core/main/msp430_watchdog.sv

read_verilog -sv ../../../../rtl/verilog/pu/msp430_core.sv

read_verilog -sv spram/core/msp430_ram.sv

read_verilog -sv msp430_synthesis.sv

read_xdc system.xdc

synth_design -part xc7z020-clg484-1 -include_dirs ../../../../rtl/verilog/pkg -top msp430_synthesis

opt_design
place_design
route_design

report_utilization
report_timing

write_bitstream -force system.bit
