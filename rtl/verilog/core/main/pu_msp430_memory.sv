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

`ifdef OMSP_NO_INCLUDE
`else
`include "pu_msp430_defines.sv"
`endif

module pu_msp430_memory (
  // OUTPUTs
  output [       15:0] dbg_mem_din,   // Debug unit Memory data input
  output [`DMEM_MSB:0] dmem_addr,     // Data Memory address
  output               dmem_cen,      // Data Memory chip enable (low active)
  output [       15:0] dmem_din,      // Data Memory data input
  output [        1:0] dmem_wen,      // Data Memory write enable (low active)
  output [       15:0] eu_mdb_in,     // Execution Unit Memory data bus input
  output [       15:0] fe_mdb_in,     // Frontend Memory data bus input
  output               fe_pmem_wait,  // Frontend wait for Instruction fetch
  output [       13:0] per_addr,      // Peripheral address
  output [       15:0] per_din,       // Peripheral data input
  output [        1:0] per_we,        // Peripheral write enable (high active)
  output               per_en,        // Peripheral enable (high active)
  output [`PMEM_MSB:0] pmem_addr,     // Program Memory address
  output               pmem_cen,      // Program Memory chip enable (low active)
  output [       15:0] pmem_din,      // Program Memory data input (optional)
  output [        1:0] pmem_wen,      // Program Memory write enable (low active) (optional)

  // INPUTs
  input        dbg_halt_st,   // Halt/Run status from CPU
  input [15:0] dbg_mem_addr,  // Debug address for rd/wr access
  input [15:0] dbg_mem_dout,  // Debug unit data output
  input        dbg_mem_en,    // Debug unit memory enable
  input [ 1:0] dbg_mem_wr,    // Debug unit memory write
  input [15:0] dmem_dout,     // Data Memory data output
  input [14:0] eu_mab,        // Execution Unit Memory address bus
  input        eu_mb_en,      // Execution Unit Memory bus enable
  input [ 1:0] eu_mb_wr,      // Execution Unit Memory bus write transfer
  input [15:0] eu_mdb_out,    // Execution Unit Memory data bus output
  input [14:0] fe_mab,        // Frontend Memory address bus
  input        fe_mb_en,      // Frontend Memory bus enable
  input        mclk,          // Main system clock
  input [15:0] per_dout,      // Peripheral data output
  input [15:0] pmem_dout,     // Program Memory data output
  input        puc_rst,       // Main system reset
  input        scan_enable    // Scan enable (active during scan shifting)
);

  //////////////////////////////////////////////////////////////////////////////
  // 1)  DECODER
  //////////////////////////////////////////////////////////////////////////////

  // RAM Interface

  // Execution unit access
  wire        eu_dmem_cen = ~(eu_mb_en & (eu_mab >= (`DMEM_BASE >> 1)) & (eu_mab < ((`DMEM_BASE + `DMEM_SIZE) >> 1)));
  wire [15:0] eu_dmem_addr = {1'b0, eu_mab} - (`DMEM_BASE >> 1);

  // Debug interface access
  wire        dbg_dmem_cen = ~(dbg_mem_en & (dbg_mem_addr[15:1] >= (`DMEM_BASE >> 1)) & (dbg_mem_addr[15:1] < ((`DMEM_BASE + `DMEM_SIZE) >> 1)));
  wire [15:0] dbg_dmem_addr = {1'b0, dbg_mem_addr[15:1]} - (`DMEM_BASE >> 1);

  // RAM Interface
  assign dmem_addr = ~dbg_dmem_cen ? dbg_dmem_addr[`DMEM_MSB:0] : eu_dmem_addr[`DMEM_MSB:0];
  assign dmem_cen  = dbg_dmem_cen & eu_dmem_cen;
  assign dmem_wen  = ~(dbg_mem_wr | eu_mb_wr);
  assign dmem_din  = ~dbg_dmem_cen ? dbg_mem_dout : eu_mdb_out;

  // ROM Interface
  parameter PMEM_OFFSET = (16'hFFFF - `PMEM_SIZE + 1);

  // Execution unit access (only read access are accepted)
  wire        eu_pmem_cen = ~(eu_mb_en & ~|eu_mb_wr & (eu_mab >= (PMEM_OFFSET >> 1)));
  wire [15:0] eu_pmem_addr = eu_mab - (PMEM_OFFSET >> 1);

  // Front-end access
  wire        fe_pmem_cen = ~(fe_mb_en & (fe_mab >= (PMEM_OFFSET >> 1)));
  wire [15:0] fe_pmem_addr = fe_mab - (PMEM_OFFSET >> 1);

  // Debug interface access
  wire        dbg_pmem_cen = ~(dbg_mem_en & (dbg_mem_addr[15:1] >= (PMEM_OFFSET >> 1)));
  wire [15:0] dbg_pmem_addr = {1'b0, dbg_mem_addr[15:1]} - (PMEM_OFFSET >> 1);

  // ROM Interface (Execution unit has priority)
  assign pmem_addr    = ~dbg_pmem_cen ? dbg_pmem_addr[`PMEM_MSB:0] : ~eu_pmem_cen ? eu_pmem_addr[`PMEM_MSB:0] : fe_pmem_addr[`PMEM_MSB:0];
  assign pmem_cen     = fe_pmem_cen & eu_pmem_cen & dbg_pmem_cen;
  assign pmem_wen     = ~dbg_mem_wr;
  assign pmem_din     = dbg_mem_dout;

  assign fe_pmem_wait = (~fe_pmem_cen & ~eu_pmem_cen);

  // Peripherals
  wire dbg_per_en = dbg_mem_en & (dbg_mem_addr[15:1] < (`PER_SIZE >> 1));
  wire eu_per_en = eu_mb_en & (eu_mab < (`PER_SIZE >> 1));

  assign per_din = dbg_mem_en ? dbg_mem_dout : eu_mdb_out;
  assign per_we  = dbg_mem_en ? dbg_mem_wr : eu_mb_wr;
  assign per_en  = dbg_mem_en ? dbg_per_en : eu_per_en;
  wire [`PER_MSB:0] per_addr_mux = dbg_mem_en ? dbg_mem_addr[`PER_MSB+1:1] : eu_mab[`PER_MSB:0];
  wire [      14:0] per_addr_ful = {{15 - `PER_AWIDTH{1'b0}}, per_addr_mux};
  assign per_addr = per_addr_ful[13:0];

  reg [15:0] per_dout_val;

  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      per_dout_val <= 16'h0000;
    end else begin
      per_dout_val <= per_dout;
    end
  end

  // Frontend data Mux
  // Whenever the frontend doesn't access the ROM,  backup the data

  // Detect whenever the data should be backuped and restored
  reg fe_pmem_cen_dly;

  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      fe_pmem_cen_dly <= 1'b0;
    end else begin
      fe_pmem_cen_dly <= fe_pmem_cen;
    end
  end

  wire fe_pmem_save = (fe_pmem_cen & ~fe_pmem_cen_dly) & ~dbg_halt_st;
  wire fe_pmem_restore = (~fe_pmem_cen & fe_pmem_cen_dly) | dbg_halt_st;

`ifdef CLOCK_GATING
  wire mclk_bckup;

  pu_msp430_clock_gate clock_gate_bckup (
    .gclk       (mclk_bckup),
    .clk        (mclk),
    .enable     (fe_pmem_save),
    .scan_enable(scan_enable)
  );
`else
  wire mclk_bckup = mclk;
`endif

  reg [15:0] pmem_dout_bckup;

`ifdef CLOCK_GATING
  always @(posedge mclk_bckup or posedge puc_rst) begin
    if (puc_rst) begin
      pmem_dout_bckup <= 16'h0000;
    end else begin
      pmem_dout_bckup <= pmem_dout;
    end
  end
`else
  always @(posedge mclk_bckup or posedge puc_rst) begin
    if (puc_rst) begin
      pmem_dout_bckup <= 16'h0000;
    end else if (fe_pmem_save) begin
      pmem_dout_bckup <= pmem_dout;
    end
  end
`endif

  // Mux between the ROM data and the backup
  reg pmem_dout_bckup_sel;

  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      pmem_dout_bckup_sel <= 1'b0;
    end else if (fe_pmem_save) begin
      pmem_dout_bckup_sel <= 1'b1;
    end else if (fe_pmem_restore) begin
      pmem_dout_bckup_sel <= 1'b0;
    end
  end

  assign fe_mdb_in = pmem_dout_bckup_sel ? pmem_dout_bckup : pmem_dout;

  // Execution-Unit data Mux

  // Select between peripherals, RAM and ROM
  reg [1:0] eu_mdb_in_sel;

  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      eu_mdb_in_sel <= 2'b00;
    end else begin
      eu_mdb_in_sel <= {~eu_pmem_cen, per_en};
    end
  end

  // Mux
  assign eu_mdb_in = eu_mdb_in_sel[1] ? pmem_dout : eu_mdb_in_sel[0] ? per_dout_val : dmem_dout;

  // Debug interface  data Mux

  // Select between peripherals, RAM and ROM
`ifdef DBG_EN
  reg [1:0] dbg_mem_din_sel;

  always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst) begin
      dbg_mem_din_sel <= 2'b00;
    end else begin
      dbg_mem_din_sel <= {~dbg_pmem_cen, dbg_per_en};
    end
  end
`else
  wire [1:0] dbg_mem_din_sel = 2'b00;
`endif

  // Mux
  assign dbg_mem_din = dbg_mem_din_sel[1] ? pmem_dout : dbg_mem_din_sel[0] ? per_dout_val : dmem_dout;
endmodule  // pu_msp430_memory

`ifdef OMSP_NO_INCLUDE
`else
`include "pu_msp430_undefines.sv"
`endif
