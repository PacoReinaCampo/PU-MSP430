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

`ifdef OMSP_NO_INCLUDE
`else
`include "msp430_defines.sv"
`endif

module msp430_wakeup_cell (
  // OUTPUTs
  output reg     wkup_out,       // Wakup signal (asynchronous)

  // INPUTs
  input          scan_clk,       // Scan clock
  input          scan_mode,      // Scan mode
  input          scan_rst,       // Scan reset
  input          wkup_clear,     // Glitch free wakeup event clear
  input          wkup_event      // Glitch free asynchronous wakeup event
);

  //=============================================================================
  // 1)  AND GATE
  //=============================================================================

  // Scan stuff for the ASIC mode
  `ifdef ASIC
  wire wkup_rst;
  msp430_scan_mux scan_mux_rst (
    .scan_mode    (scan_mode),
    .data_in_scan (scan_rst),
    .data_in_func (wkup_clear),
    .data_out     (wkup_rst)
  );

  wire wkup_clk;
  msp430_scan_mux scan_mux_clk (
    .scan_mode    (scan_mode),
    .data_in_scan (scan_clk),
    .data_in_func (wkup_event),
    .data_out     (wkup_clk)
  );

  `else
  wire wkup_rst  =  wkup_clear;
  wire wkup_clk  =  wkup_event;
  `endif

  // Wakeup capture
  always @(posedge wkup_clk or posedge wkup_rst) begin
    if (wkup_rst) wkup_out <= 1'b0;
    else          wkup_out <= 1'b1;
  end
endmodule // msp430_wakeup_cell

`ifdef OMSP_NO_INCLUDE
`else
`include "msp430_undefines.sv"
`endif
