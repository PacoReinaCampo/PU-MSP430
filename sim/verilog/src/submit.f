////////////////////////////////////////////////////////////////////////////////
//                                            __ _      _     _               //
//                                           / _(_)    | |   | |              //
//                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
//               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
//              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
//               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
//                  | |                                                       //
//                  |_|                                                       //
//                                                                            //
//                                                                            //
//              MSP430 CPU                                                    //
//              Processing Unit                                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/* Copyright (c) 2015-2016 by the author(s)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * =============================================================================
 * Author(s):
 *   Francisco Javier Reina Campo <frareicam@gmail.com>
 */

+incdir+../../../rtl/verilog/pkg/

//=============================================================================
// Testbench related
//=============================================================================

+incdir+../../../bench/verilog/

../../../bench/verilog/tb_openMSP430.v
../../../bench/verilog/ram.v
../../../bench/verilog/io_cell.v
../../../bench/verilog/msp_debug.v


//=============================================================================
// CPU
//=============================================================================

../../../rtl/verilog/core/fuse/msp430_and_gate.v
../../../rtl/verilog/core/fuse/msp430_clock_gate.v
../../../rtl/verilog/core/fuse/msp430_clock_mux.v
../../../rtl/verilog/core/fuse/msp430_scan_mux.v
../../../rtl/verilog/core/fuse/msp430_sync_cell.v
../../../rtl/verilog/core/fuse/msp430_sync_reset.v
../../../rtl/verilog/core/fuse/msp430_wakeup_cell.v

../../../rtl/verilog/core/omsp/msp430_alu.v
../../../rtl/verilog/core/omsp/msp430_dbg_hwbrk.v
../../../rtl/verilog/core/omsp/msp430_dbg_i2c.v
../../../rtl/verilog/core/omsp/msp430_dbg_uart.v
../../../rtl/verilog/core/omsp/msp430_register_file.v

../../../rtl/verilog/core/main/msp430_bcm.v
../../../rtl/verilog/core/main/msp430_dbg.v
../../../rtl/verilog/core/main/msp430_execution.v
../../../rtl/verilog/core/main/msp430_gpio.v
../../../rtl/verilog/core/main/msp430_memory.v
../../../rtl/verilog/core/main/msp430_multiplier.v
../../../rtl/verilog/core/main/msp430_template08.v
../../../rtl/verilog/core/main/msp430_template16.v
../../../rtl/verilog/core/main/msp430_uart.v

../../../rtl/verilog/core/main/msp430_frontend.v
../../../rtl/verilog/core/main/msp430_sfr.v
../../../rtl/verilog/core/main/msp430_ta.v
../../../rtl/verilog/core/main/msp430_watchdog.v

../../../rtl/verilog/core/msp430_pu.v
