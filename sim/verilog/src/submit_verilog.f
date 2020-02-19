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

+incdir+../../../rtl/verilog/
../../../rtl/verilog/core/main/BCM.v
../../../rtl/verilog/core/main/DBG.v
../../../rtl/verilog/core/main/EXECUTION.v
../../../rtl/verilog/core/main/FRONTEND.v
../../../rtl/verilog/core/main/GPIO.v
../../../rtl/verilog/core/main/MEMORY.v
../../../rtl/verilog/core/main/MULTIPLIER.v
../../../rtl/verilog/core/main/SFR.v
../../../rtl/verilog/core/main/T_A.v
../../../rtl/verilog/core/main/T_WATCHDOG.v
../../../rtl/verilog/core/main/TEMPLATE_08.v
../../../rtl/verilog/core/main/TEMPLATE_16.v
../../../rtl/verilog/core/main/UART.v
../../../rtl/verilog/core/MSP430_CORE.v
