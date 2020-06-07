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

module msp430_clock_mux (
  // OUTPUTs
  output         clk_out,        // Clock output

  // INPUTs
  input          clk_in0,        // Clock input 0
  input          clk_in1,        // Clock input 1
  input          reset,          // Reset
  input          scan_mode,      // Scan mode (clk_in0 is selected in scan mode)
  input          selection       // Clock selection
);

  //===========================================================================================================================//
  // 1)  CLOCK MUX                                                                                                             //
  //===========================================================================================================================//
  //                                                                                                                           //
  //    The following (glitch free) clock mux is implemented as following:                                                     //
  //                                                                                                                           //
  //                                                                                                                           //
  //                                                                                                                           //
  //                                                                                                                           //
  //                                   +-----.     +--------+   +--------+                                                     //
  //       select >>----+-------------O|      \    |        |   |        |          +-----.                                    //
  //                    |              |       |---| D    Q |---| D    Q |--+-------|      \                                   //
  //                    |     +-------O|      /    |        |   |        |  |       |       |O-+                               //
  //                    |     |        +-----'     |        |   |        |  |   +--O|      /   |                               //
  //                    |     |                    |   /\   |   |   /\   |  |   |   +-----'    |                               //
  //                    |     |                    +--+--+--+   +--+--+--+  |   |              |                               //
  //                    |     |                        O            |       |   |              |                               //
  //                    |     |                        |            |       |   |              |  +-----.                      //
  //       clk_in0 >>----------------------------------+------------+-----------+              +--|      \                     //
  //                    |     |                                             |                     |       |----<< clk_out      //
  //                    |     |     +---------------------------------------+                  +--|      /                     //
  //                    |     |     |                                                          |  +-----'                      //
  //                    |     +---------------------------------------------+                  |                               //
  //                    |           |                                       |                  |                               //
  //                    |           |  +-----.     +--------+   +--------+  |                  |                               //
  //                    |           +-O|      \    |        |   |        |  |       +-----.    |                               //
  //                    |              |       |---| D    Q |---| D    Q |--+-------|      \   |                               //
  //                    +--------------|      /    |        |   |        |          |       |O-+                               //
  //                                   +-----'     |        |   |        |      +--O|      /                                   //
  //                                               |   /\   |   |   /\   |      |   +-----'                                    //
  //                                               +--+--+--+   +--+--+--+      |                                              //
  //                                                   O            |           |                                              //
  //                                                   |            |           |                                              //
  //       clk_in1 >>----------------------------------+------------+-----------+                                              //
  //                                                                                                                           //
  //                                                                                                                           //
  //===========================================================================================================================//

  //-----------------------------------------------------------------------------
  // Wire declarations
  //-----------------------------------------------------------------------------

  wire in0_select;
  reg  in0_select_s;
  reg  in0_select_ss;
  wire in0_enable;

  wire in1_select;
  reg  in1_select_s;
  reg  in1_select_ss;
  wire in1_enable;

  wire clk_in0_inv;
  wire clk_in1_inv;
  wire gated_clk_in0;
  wire gated_clk_in1;

  //-----------------------------------------------------------------------------
  // CLK_IN0 Selection
  //-----------------------------------------------------------------------------

  assign in0_select = ~selection & ~in1_select_ss;

  always @ (posedge clk_in0_inv or posedge reset) begin
    if (reset) in0_select_s  <=  1'b1;
    else       in0_select_s  <=  in0_select;
  end

  always @ (posedge clk_in0     or posedge reset) begin
    if (reset) in0_select_ss <=  1'b1;
    else       in0_select_ss <=  in0_select_s;
  end

  assign in0_enable = in0_select_ss | scan_mode;

  //-----------------------------------------------------------------------------
  // CLK_IN1 Selection
  //-----------------------------------------------------------------------------

  assign in1_select =  selection & ~in0_select_ss;

  always @ (posedge clk_in1_inv or posedge reset) begin
    if (reset) in1_select_s  <=  1'b0;
    else       in1_select_s  <=  in1_select;
  end

  always @ (posedge clk_in1     or posedge reset) begin
    if (reset) in1_select_ss <=  1'b0;
    else       in1_select_ss <=  in1_select_s;
  end

  assign in1_enable = in1_select_ss & ~scan_mode;

  //-----------------------------------------------------------------------------
  // Clock MUX
  //-----------------------------------------------------------------------------
  //
  // IMPORTANT NOTE:
  //                  Because the clock network is a critical part of the design,
  //                 the following combinatorial logic should be replaced with
  //                 direct instanciation of standard cells from target library.
  //                  Don't forget the "dont_touch" attribute to make sure
  //                 synthesis won't mess it up.
  //

  // Replace with standard cell INVERTER
  assign clk_in0_inv   = ~clk_in0;
  assign clk_in1_inv   = ~clk_in1;

  // Replace with standard cell NAND2
  assign gated_clk_in0 = ~(clk_in0_inv & in0_enable);
  assign gated_clk_in1 = ~(clk_in1_inv & in1_enable);

  // Replace with standard cell AND2
  assign clk_out       =  (gated_clk_in0 & gated_clk_in1);
endmodule // msp430_clock_gate
