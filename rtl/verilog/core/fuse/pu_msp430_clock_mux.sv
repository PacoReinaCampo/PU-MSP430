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
// Copyright (c) 2015-2016 by the author(s)
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the authors nor the names of its contributors
//       may be used to endorse or promote products derived from this software
//       without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
// THE POSSIBILITY OF SUCH DAMAGE
//
////////////////////////////////////////////////////////////////////////////////
// Author(s):
//   Olivier Girard <olgirard@gmail.com>
//   Paco Reina Campo <pacoreinacampo@queenfield.tech>

module pu_msp430_clock_mux (
  // OUTPUTs
  output clk_out,  // Clock output

  // INPUTs
  input clk_in0,    // Clock input 0
  input clk_in1,    // Clock input 1
  input reset,      // Reset
  input scan_mode,  // Scan mode (clk_in0 is selected in scan mode)
  input selection   // Clock selection
);

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // 1)  CLOCK MUX                                                                                                           //
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                                                                                                         //
  //    The following (glitch free) clock mux is implemented as following:                                                   //
  //                                                                                                                         //
  //                                                                                                                         //
  //                                                                                                                         //
  //                                                                                                                         //
  //                                   +-----.     +--------+   +--------+                                                   //
  //       select >>----+-------------O|      \    |        |   |        |          +-----.                                  //
  //                    |              |       |---| D    Q |---| D    Q |--+-------|      \                                 //
  //                    |     +-------O|      /    |        |   |        |  |       |       |O-+                             //
  //                    |     |        +-----'     |        |   |        |  |   +--O|      /   |                             //
  //                    |     |                    |   /\   |   |   /\   |  |   |   +-----'    |                             //
  //                    |     |                    +--+--+--+   +--+--+--+  |   |              |                             //
  //                    |     |                        O            |       |   |              |                             //
  //                    |     |                        |            |       |   |              |  +-----.                    //
  //       clk_in0 >>----------------------------------+------------+-----------+              +--|      \                   //
  //                    |     |                                             |                     |       |----<< clk_out    //
  //                    |     |     +---------------------------------------+                  +--|      /                   //
  //                    |     |     |                                                          |  +-----'                    //
  //                    |     +---------------------------------------------+                  |                             //
  //                    |           |                                       |                  |                             //
  //                    |           |  +-----.     +--------+   +--------+  |                  |                             //
  //                    |           +-O|      \    |        |   |        |  |       +-----.    |                             //
  //                    |              |       |---| D    Q |---| D    Q |--+-------|      \   |                             //
  //                    +--------------|      /    |        |   |        |          |       |O-+                             //
  //                                   +-----'     |        |   |        |      +--O|      /                                 //
  //                                               |   /\   |   |   /\   |      |   +-----'                                  //
  //                                               +--+--+--+   +--+--+--+      |                                            //
  //                                                   O            |           |                                            //
  //                                                   |            |           |                                            //
  //       clk_in1 >>----------------------------------+------------+-----------+                                            //
  //                                                                                                                         //
  //                                                                                                                         //
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////////////////////////
  // Wire declarations
  //////////////////////////////////////////////////////////////////////////////

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

  //////////////////////////////////////////////////////////////////////////////
  // CLK_IN0 Selection
  //////////////////////////////////////////////////////////////////////////////

  assign in0_select = ~selection & ~in1_select_ss;

  always @(posedge clk_in0_inv or posedge reset) begin
    if (reset) begin
      in0_select_s <= 1'b1;
    end else begin
      in0_select_s <= in0_select;
    end
  end

  always @(posedge clk_in0 or posedge reset) begin
    if (reset) begin
      in0_select_ss <= 1'b1;
    end else begin
      in0_select_ss <= in0_select_s;
    end
  end

  assign in0_enable = in0_select_ss | scan_mode;

  //////////////////////////////////////////////////////////////////////////////
  // CLK_IN1 Selection
  //////////////////////////////////////////////////////////////////////////////

  assign in1_select = selection & ~in0_select_ss;

  always @(posedge clk_in1_inv or posedge reset) begin
    if (reset) begin
      in1_select_s <= 1'b0;
    end else begin
      in1_select_s <= in1_select;
    end
  end

  always @(posedge clk_in1 or posedge reset) begin
    if (reset) begin
      in1_select_ss <= 1'b0;
    end else begin
      in1_select_ss <= in1_select_s;
    end
  end

  assign in1_enable    = in1_select_ss & ~scan_mode;

  //////////////////////////////////////////////////////////////////////////////
  // Clock MUX
  //////////////////////////////////////////////////////////////////////////////
  // IMPORTANT NOTE:
  //                 Because the clock network is a critical part of the design,
  //                 the following combinatorial logic should be replaced with
  //                 direct instanciation of standard cells from target library.
  //                 Don't forget the "dont_touch" attribute to make sure
  //                 synthesis won't mess it up.
  //

  // Replace with standard cell INVERTER
  assign clk_in0_inv   = ~clk_in0;
  assign clk_in1_inv   = ~clk_in1;

  // Replace with standard cell NAND2
  assign gated_clk_in0 = ~(clk_in0_inv & in0_enable);
  assign gated_clk_in1 = ~(clk_in1_inv & in1_enable);

  // Replace with standard cell AND2
  assign clk_out       = (gated_clk_in0 & gated_clk_in1);
endmodule  // pu_msp430_clock_gate
