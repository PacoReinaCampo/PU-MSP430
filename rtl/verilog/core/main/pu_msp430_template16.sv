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

module pu_msp430_template16 (
  // OUTPUTs
  output [15:0] per_dout,    // Peripheral data output
  output [15:0] cntrl2_16b,
  output [15:0] cntrl4_16b,

  // INPUTs
  input        mclk,      // Main system clock
  input [13:0] per_addr,  // Peripheral address
  input [15:0] per_din,   // Peripheral data input
  input        per_en,    // Peripheral enable (high active)
  input [ 1:0] per_we,    // Peripheral write enable (high active)
  input        puc_rst    // Main system reset
);

  //////////////////////////////////////////////////////////////////////////////
  // 1)  PARAMETER DECLARATION
  //////////////////////////////////////////////////////////////////////////////

  // Register base address (must be aligned to decoder bit width)
  parameter [14:0] BASE_ADDR = 15'h0190;

  // Decoder bit width (defines how many bits are considered for address decoding)
  parameter DEC_WD = 3;

  // Register addresses offset
  parameter [DEC_WD-1:0] CNTRL1 = 'h0;
  parameter [DEC_WD-1:0] CNTRL2 = 'h2;
  parameter [DEC_WD-1:0] CNTRL3 = 'h4;
  parameter [DEC_WD-1:0] CNTRL4 = 'h6;

  // Register one-hot decoder utilities
  parameter DEC_SZ = (1 << DEC_WD);
  parameter [DEC_SZ-1:0] BASE_REG = {{DEC_SZ - 1{1'b0}}, 1'b1};

  // Register one-hot decoder
  parameter [DEC_SZ-1:0] CNTRL1_D = (BASE_REG << CNTRL1);
  parameter [DEC_SZ-1:0] CNTRL2_D = (BASE_REG << CNTRL2);
  parameter [DEC_SZ-1:0] CNTRL3_D = (BASE_REG << CNTRL3);
  parameter [DEC_SZ-1:0] CNTRL4_D = (BASE_REG << CNTRL4);

  //////////////////////////////////////////////////////////////////////////////
  // 2)  REGISTER DECODER
  //////////////////////////////////////////////////////////////////////////////

  // Local register selection
  wire              reg_sel = per_en & (per_addr[13:DEC_WD-1] == BASE_ADDR[14:DEC_WD]);

  // Register local address
  wire [DEC_WD-1:0] reg_addr = {per_addr[DEC_WD-2:0], 1'b0};

  // Register address decode
  wire [DEC_SZ-1:0] reg_dec = (CNTRL1_D & {DEC_SZ{(reg_addr == CNTRL1)}}) | (CNTRL2_D & {DEC_SZ{(reg_addr == CNTRL2)}}) | (CNTRL3_D & {DEC_SZ{(reg_addr == CNTRL3)}}) | (CNTRL4_D & {DEC_SZ{(reg_addr == CNTRL4)}});

  // Read/Write probes
  wire              reg_write = |per_we & reg_sel;
  wire              reg_read = ~|per_we & reg_sel;

  // Read/Write vectors
  wire [DEC_SZ-1:0] reg_wr = reg_dec & {DEC_SZ{reg_write}};
  wire [DEC_SZ-1:0] reg_rd = reg_dec & {DEC_SZ{reg_read}};

  //////////////////////////////////////////////////////////////////////////////
  // 3) REGISTERS
  //////////////////////////////////////////////////////////////////////////////

  // CNTRL1 Register
  reg  [      15:0] cntrl1;

  wire              cntrl1_wr = reg_wr[CNTRL1];

  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      cntrl1 <= 16'h0000;
    end else if (cntrl1_wr) begin
      cntrl1 <= per_din;
    end
  end

  // CNTRL2 Register
  reg  [15:0] cntrl2;

  wire        cntrl2_wr = reg_wr[CNTRL2];

  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      cntrl2 <= 16'h0000;
    end else if (cntrl2_wr) begin
      cntrl2 <= per_din;
    end
  end

  // CNTRL3 Register
  reg  [15:0] cntrl3;

  wire        cntrl3_wr = reg_wr[CNTRL3];

  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      cntrl3 <= 16'h0000;
    end else if (cntrl3_wr) begin
      cntrl3 <= per_din;
    end
  end

  // CNTRL4 Register
  reg  [15:0] cntrl4;

  wire        cntrl4_wr = reg_wr[CNTRL4];

  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      cntrl4 <= 16'h0000;
    end else if (cntrl4_wr) begin
      cntrl4 <= per_din;
    end
  end

  //////////////////////////////////////////////////////////////////////////////
  // 4) DATA OUTPUT GENERATION
  //////////////////////////////////////////////////////////////////////////////

  // Data output mux
  wire [15:0] cntrl1_rd = cntrl1 & {16{reg_rd[CNTRL1]}};
  wire [15:0] cntrl2_rd = cntrl2 & {16{reg_rd[CNTRL2]}};
  wire [15:0] cntrl3_rd = cntrl3 & {16{reg_rd[CNTRL3]}};
  wire [15:0] cntrl4_rd = cntrl4 & {16{reg_rd[CNTRL4]}};

  assign per_dout   = cntrl1_rd | cntrl2_rd | cntrl3_rd | cntrl4_rd;

  assign cntrl2_16b = cntrl2;
  assign cntrl4_16b = cntrl4;
endmodule  // pu_msp430_template16
