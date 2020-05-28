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

../../../rtl/vhdl/pkg/msp430_pkg.vhd

//=============================================================================
// Testbench related
//=============================================================================

../../../bench/vhdl/msp430_io_cell.vhd


//=============================================================================
// CPU
//=============================================================================

../../../rtl/vhdl/core/fuse/msp430_and_gate.vhd
../../../rtl/vhdl/core/fuse/msp430_clock_gate.vhd
../../../rtl/vhdl/core/fuse/msp430_clock_mux.vhd
../../../rtl/vhdl/core/fuse/msp430_scan_mux.vhd
../../../rtl/vhdl/core/fuse/msp430_sync_cell.vhd
../../../rtl/vhdl/core/fuse/msp430_sync_reset.vhd
../../../rtl/vhdl/core/fuse/msp430_wakeup_cell.vhd

../../../rtl/vhdl/core/omsp/msp430_alu.vhd
../../../rtl/vhdl/core/omsp/msp430_dbg_hwbrk.vhd
../../../rtl/vhdl/core/omsp/msp430_dbg_i2c.vhd
../../../rtl/vhdl/core/omsp/msp430_dbg_uart.vhd
../../../rtl/vhdl/core/omsp/msp430_interrupt.vhd
../../../rtl/vhdl/core/omsp/msp430_register_file.vhd
../../../rtl/vhdl/core/omsp/msp430_state_machine.vhd

../../../rtl/vhdl/core/main/msp430_bcm.vhd
../../../rtl/vhdl/core/main/msp430_dbg.vhd
../../../rtl/vhdl/core/main/msp430_execution.vhd
../../../rtl/vhdl/core/main/msp430_gpio.vhd
../../../rtl/vhdl/core/main/msp430_memory.vhd
../../../rtl/vhdl/core/main/msp430_multiplier.vhd
../../../rtl/vhdl/core/main/msp430_template08.vhd
../../../rtl/vhdl/core/main/msp430_template16.vhd
../../../rtl/vhdl/core/main/msp430_uart.vhd
