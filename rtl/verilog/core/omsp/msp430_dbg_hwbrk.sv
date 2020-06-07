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

module  msp430_dbg_hwbrk (
  // OUTPUTs
  output         brk_halt,     // Hardware breakpoint command
  output         brk_pnd,      // Hardware break/watch-point pending
  output  [15:0] brk_dout,     // Hardware break/watch-point register data input

  // INPUTs
  input    [3:0] brk_reg_rd,   // Hardware break/watch-point register read select
  input    [3:0] brk_reg_wr,   // Hardware break/watch-point register write select
  input          dbg_clk,      // Debug unit clock
  input   [15:0] dbg_din,      // Debug register data input
  input          dbg_rst,      // Debug unit reset
  input          decode_noirq, // Frontend decode instruction
  input   [15:0] eu_mab,       // Execution-Unit Memory address bus
  input          eu_mb_en,     // Execution-Unit Memory bus enable
  input    [1:0] eu_mb_wr,     // Execution-Unit Memory bus write transfer
  input   [15:0] pc            // Program counter
);

  //=============================================================================
  // 1)  WIRE & PARAMETER DECLARATION
  //=============================================================================

  wire      range_wr_set;
  wire      range_rd_set;
  wire      addr1_wr_set;
  wire      addr1_rd_set;
  wire      addr0_wr_set;
  wire      addr0_rd_set;

  parameter BRK_CTL   = 0,
            BRK_STAT  = 1,
            BRK_ADDR0 = 2,
            BRK_ADDR1 = 3;

  //=============================================================================
  // 2)  CONFIGURATION REGISTERS
  //=============================================================================

  // BRK_CTL Register
  //-----------------------------------------------------------------------------
  //       7   6   5        4            3          2            1  0
  //        Reserved    RANGE_MODE    INST_EN    BREAK_EN    ACCESS_MODE
  //
  // ACCESS_MODE: - 00 : Disabled
  //              - 01 : Detect read access
  //              - 10 : Detect write access
  //              - 11 : Detect read/write access
  //              NOTE: '10' & '11' modes are not supported on the instruction flow
  //
  // BREAK_EN:    -  0 : Watchmode enable
  //              -  1 : Break enable
  //
  // INST_EN:     -  0 : Checks are done on the execution unit (data flow)
  //              -  1 : Checks are done on the frontend (instruction flow)
  //
  // RANGE_MODE:  -  0 : Address match on BRK_ADDR0 or BRK_ADDR1
  //              -  1 : Address match on BRK_ADDR0->BRK_ADDR1 range
  //
  //-----------------------------------------------------------------------------
  reg   [4:0] brk_ctl;

  wire        brk_ctl_wr = brk_reg_wr[BRK_CTL];

  always @ (posedge dbg_clk or posedge dbg_rst) begin
    if (dbg_rst)         brk_ctl <=  5'h00;
    else if (brk_ctl_wr) brk_ctl <=  {`HWBRK_RANGE & dbg_din[4], dbg_din[3:0]};
  end

  wire  [7:0] brk_ctl_full = {3'b000, brk_ctl};

  // BRK_STAT Register
  //-----------------------------------------------------------------------------
  //     7    6       5         4         3         2         1         0
  //    Reserved  RANGE_WR  RANGE_RD  ADDR1_WR  ADDR1_RD  ADDR0_WR  ADDR0_RD
  //-----------------------------------------------------------------------------
  reg   [5:0] brk_stat;

  wire        brk_stat_wr  = brk_reg_wr[BRK_STAT];
  wire  [5:0] brk_stat_set = {range_wr_set & `HWBRK_RANGE,
                              range_rd_set & `HWBRK_RANGE,
                              addr1_wr_set, addr1_rd_set,
                              addr0_wr_set, addr0_rd_set};
  wire  [5:0] brk_stat_clr = ~dbg_din[5:0];

  always @ (posedge dbg_clk or posedge dbg_rst) begin
    if (dbg_rst)          brk_stat <=  6'h00;
    else if (brk_stat_wr) brk_stat <= ((brk_stat & brk_stat_clr) | brk_stat_set);
    else                  brk_stat <=  (brk_stat                 | brk_stat_set);
  end

  wire  [7:0] brk_stat_full = {2'b00, brk_stat};
  assign      brk_pnd       = |brk_stat;

  // BRK_ADDR0 Register
  //-----------------------------------------------------------------------------
  reg  [15:0] brk_addr0;

  wire        brk_addr0_wr = brk_reg_wr[BRK_ADDR0];

  always @ (posedge dbg_clk or posedge dbg_rst) begin
    if (dbg_rst)           brk_addr0 <=  16'h0000;
    else if (brk_addr0_wr) brk_addr0 <=  dbg_din;
  end

  // BRK_ADDR1/DATA0 Register
  //-----------------------------------------------------------------------------
  reg  [15:0] brk_addr1;

  wire        brk_addr1_wr = brk_reg_wr[BRK_ADDR1];

  always @ (posedge dbg_clk or posedge dbg_rst) begin
    if (dbg_rst)           brk_addr1 <=  16'h0000;
    else if (brk_addr1_wr) brk_addr1 <=  dbg_din;
  end

  //============================================================================
  // 3) DATA OUTPUT GENERATION
  //============================================================================

  wire [15:0] brk_ctl_rd   = {8'h00, brk_ctl_full}  & {16{brk_reg_rd[BRK_CTL]}};
  wire [15:0] brk_stat_rd  = {8'h00, brk_stat_full} & {16{brk_reg_rd[BRK_STAT]}};
  wire [15:0] brk_addr0_rd = brk_addr0              & {16{brk_reg_rd[BRK_ADDR0]}};
  wire [15:0] brk_addr1_rd = brk_addr1              & {16{brk_reg_rd[BRK_ADDR1]}};

  assign      brk_dout = brk_ctl_rd   |
                         brk_stat_rd  |
                         brk_addr0_rd |
                         brk_addr1_rd;

  //============================================================================
  // 4) BREAKPOINT / WATCHPOINT GENERATION
  //============================================================================

  // Comparators
  //---------------------------
  // Note: here the comparison logic is instanciated several times in order
  //       to improve the timings, at the cost of a bit more area.

  wire        equ_d_addr0 = eu_mb_en & (eu_mab==brk_addr0) & ~brk_ctl[`BRK_RANGE];
  wire        equ_d_addr1 = eu_mb_en & (eu_mab==brk_addr1) & ~brk_ctl[`BRK_RANGE];
  wire        equ_d_range = eu_mb_en & ((eu_mab>=brk_addr0) & (eu_mab<=brk_addr1)) & 
                            brk_ctl[`BRK_RANGE] & `HWBRK_RANGE;

  wire        equ_i_addr0 = decode_noirq & (pc==brk_addr0) & ~brk_ctl[`BRK_RANGE];
  wire        equ_i_addr1 = decode_noirq & (pc==brk_addr1) & ~brk_ctl[`BRK_RANGE];
  wire        equ_i_range = decode_noirq & ((pc>=brk_addr0) & (pc<=brk_addr1)) &
                            brk_ctl[`BRK_RANGE] & `HWBRK_RANGE;

  // Detect accesses
  //---------------------------

  // Detect Instruction read access
  wire i_addr0_rd =  equ_i_addr0 &  brk_ctl[`BRK_I_EN];
  wire i_addr1_rd =  equ_i_addr1 &  brk_ctl[`BRK_I_EN];
  wire i_range_rd =  equ_i_range &  brk_ctl[`BRK_I_EN];

  // Detect Execution-Unit write access
  wire d_addr0_wr =  equ_d_addr0 & ~brk_ctl[`BRK_I_EN] &  |eu_mb_wr;
  wire d_addr1_wr =  equ_d_addr1 & ~brk_ctl[`BRK_I_EN] &  |eu_mb_wr;
  wire d_range_wr =  equ_d_range & ~brk_ctl[`BRK_I_EN] &  |eu_mb_wr;

  // Detect DATA read access
  wire d_addr0_rd =  equ_d_addr0 & ~brk_ctl[`BRK_I_EN] & ~|eu_mb_wr;
  wire d_addr1_rd =  equ_d_addr1 & ~brk_ctl[`BRK_I_EN] & ~|eu_mb_wr;
  wire d_range_rd =  equ_d_range & ~brk_ctl[`BRK_I_EN] & ~|eu_mb_wr;

  // Set flags
  assign addr0_rd_set = brk_ctl[`BRK_MODE_RD] & (d_addr0_rd  | i_addr0_rd);
  assign addr0_wr_set = brk_ctl[`BRK_MODE_WR] &  d_addr0_wr;
  assign addr1_rd_set = brk_ctl[`BRK_MODE_RD] & (d_addr1_rd  | i_addr1_rd);
  assign addr1_wr_set = brk_ctl[`BRK_MODE_WR] &  d_addr1_wr;
  assign range_rd_set = brk_ctl[`BRK_MODE_RD] & (d_range_rd  | i_range_rd);
  assign range_wr_set = brk_ctl[`BRK_MODE_WR] &  d_range_wr;

  // Break CPU
  assign brk_halt     = brk_ctl[`BRK_EN] & |brk_stat_set;     
endmodule // msp430_dbg_hwbrk

`ifdef OMSP_NO_INCLUDE
`else
`include "msp430_undefines.sv"
`endif
