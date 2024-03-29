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

module pu_msp430_core #(
  parameter AW = 16,
  parameter DW = 16,

  parameter INST_NR  = 8'h00,  // Current oMSP instance number     (for multicore systems)
  parameter TOTAL_NR = 8'h00   // Total number of oMSP instances-1 (for multicore systems)
) (
  output               irq_detect,
  output               nmi_detect,
  output [        2:0] i_state,
  output [        3:0] e_state,
  output               decode,
  output [DW     -1:0] ir,
  output [        5:0] irq_num,
  output [DW     -1:0] pc,
  output               nodiv_smclk,
  output [`IRQ_NR-3:0] irq_acc,      // Interrupt request accepted (one-hot signal)
  output               mclk,         // Main system clock
  output               puc_rst,      // Main system reset
  input                cpu_en,       // Enable CPU code execution (asynchronous and non-glitchy)
  input  [`IRQ_NR-3:0] irq,          // Maskable interrupts (14, 30 or 62)
  input                lfxt_clk,     // Low frequency oscillator (typ 32kHz)
  input                nmi,          // Non-maskable interrupt (asynchronous and non-glitchy)
  input                reset_n,      // Reset Pin (active low, asynchronous and non-glitchy)

  output aclk_en,  // FPGA ONLY: ACLK enable
  output smclk_en, // FPGA ONLY: SMCLK enable

  output aclk,         // ASIC ONLY: ACLK
  output lfxt_enable,  // ASIC ONLY: Low frequency oscillator enable
  output lfxt_wkup,    // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
  output smclk,        // ASIC ONLY: SMCLK
  input  scan_enable,  // ASIC ONLY: Scan enable (active during scan shifting)
  input  scan_mode,    // ASIC ONLY: Scan mode
  input  wkup,         // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)

  output dco_enable,  // ASIC ONLY: Fast oscillator enable
  output dco_wkup,    // ASIC ONLY: Fast oscillator wake-up (asynchronous)
  input  dco_clk,     // Fast oscillator (fast clock)

  output       dbg_clk,
  output       dbg_rst,
  output       dbg_freeze,         // Freeze peripherals
  output       dbg_i2c_sda_out,    // Debug interface: I2C SDA OUT
  output       dbg_uart_txd,       // Debug interface: UART TXD
  input        dbg_en,             // Debug interface enable (asynchronous and non-glitchy)
  input  [6:0] dbg_i2c_addr,       // Debug interface: I2C Address
  input  [6:0] dbg_i2c_broadcast,  // Debug interface: I2C Broadcast Address (for multicore systems)
  input        dbg_i2c_scl,        // Debug interface: I2C SCL
  input        dbg_i2c_sda_in,     // Debug interface: I2C SDA IN
  input        dbg_uart_rxd,       // Debug interface: UART RXD (asynchronous)

  output [`PMEM_MSB:0] pmem_addr,  // Program Memory address
  output               pmem_cen,   // Program Memory chip enable (low active)
  output [DW     -1:0] pmem_din,   // Program Memory data input (optional)
  output [        1:0] pmem_wen,   // Program Memory write enable (low active) (optional)
  input  [DW     -1:0] pmem_dout,  // Program Memory data output

  output [`DMEM_MSB:0] dmem_addr,  // Data Memory address
  output               dmem_cen,   // Data Memory chip enable (low active)
  output [DW     -1:0] dmem_din,   // Data Memory data input
  output [        1:0] dmem_wen,   // Data Memory write enable (low active)
  input  [DW     -1:0] dmem_dout,  // Data Memory data output

  output [       13:0] per_addr,  // Peripheral address
  output [DW     -1:0] per_din,   // Peripheral data input
  output [        1:0] per_we,    // Peripheral write enable (high active)
  output               per_en,    // Peripheral enable (high active)
  input  [DW     -1:0] per_dout,  // Peripheral data output

  output [DW     -1:0] r0,
  output [DW     -1:0] r1,
  output [DW     -1:0] r2,
  output [DW     -1:0] r3,
  output [DW     -1:0] r4,
  output [DW     -1:0] r5,
  output [DW     -1:0] r6,
  output [DW     -1:0] r7,
  output [DW     -1:0] r8,
  output [DW     -1:0] r9,
  output [DW     -1:0] r10,
  output [DW     -1:0] r11,
  output [DW     -1:0] r12,
  output [DW     -1:0] r13,
  output [DW     -1:0] r14,
  output [DW     -1:0] r15
);

  //////////////////////////////////////////////////////////////////////////////
  // 1)  INTERNAL WIRES/REGISTERS/PARAMETERS DECLARATION
  //////////////////////////////////////////////////////////////////////////////
  wire [   7:0] inst_ad;
  wire [   7:0] inst_as;
  wire [  11:0] inst_alu;
  wire          inst_bw;
  wire          inst_irq_rst;
  wire          inst_mov;
  wire [DW-1:0] inst_dest;
  wire [DW-1:0] inst_dext;
  wire [DW-1:0] inst_sext;
  wire [   7:0] inst_so;
  wire [DW-1:0] inst_src;
  wire [   2:0] inst_type;
  wire [   7:0] inst_jmp;
  wire          exec_done;
  wire          decode_noirq;
  wire          cpu_en_s;
  wire          cpuoff;
  wire          oscoff;
  wire          scg0;
  wire          scg1;
  wire          por;
  wire          gie;
  wire          mclk_enable;
  wire          mclk_wkup;
  wire [  31:0] cpu_id;
  wire [   7:0] cpu_nr_inst = INST_NR;
  wire [   7:0] cpu_nr_total = TOTAL_NR;

  wire [DW-1:0] eu_mab;
  wire [DW-1:0] eu_mdb_in;
  wire [DW-1:0] eu_mdb_out;
  wire [   1:0] eu_mb_wr;
  wire          eu_mb_en;
  wire [DW-1:0] fe_mab;
  wire [DW-1:0] fe_mdb_in;
  wire          fe_mb_en;
  wire          fe_pmem_wait;

  wire          pc_sw_wr;
  wire [DW-1:0] pc_sw;
  wire [DW-1:0] pc_nxt;

  wire          nmi_acc;
  wire          nmi_pnd;
  wire          nmi_wkup;

  wire          wdtie;
  wire          wdtnmies;
  wire          wdtifg;
  wire          wdt_irq;
  wire          wdt_wkup;
  wire          wdt_reset;
  wire          wdtifg_sw_clr;
  wire          wdtifg_sw_set;

  wire          dbg_en_s;
  wire          dbg_halt_st;
  wire          dbg_halt_cmd;
  wire          dbg_mem_en;
  wire          dbg_reg_wr;
  wire          dbg_cpu_reset;
  wire [DW-1:0] dbg_mem_addr;
  wire [DW-1:0] dbg_mem_dout;
  wire [DW-1:0] dbg_mem_din;
  wire [DW-1:0] dbg_reg_din;
  wire [   1:0] dbg_mem_wr;
  wire          puc_pnd_set;

  wire [DW-1:0] per_dout_or;
  wire [DW-1:0] per_dout_sfr;
  wire [DW-1:0] per_dout_wdog;
  wire [DW-1:0] per_dout_mpy;
  wire [DW-1:0] per_dout_clk;

  //////////////////////////////////////////////////////////////////////////////
  // 2)  GLOBAL CLOCK & RESET MANAGEMENT
  //////////////////////////////////////////////////////////////////////////////
  pu_msp430_bcm bcm (
    // OUTPUTs
    .aclk       (aclk),          // ACLK
    .aclk_en    (aclk_en),       // ACLK enablex
    .cpu_en_s   (cpu_en_s),      // Enable CPU code execution (synchronous)
    .dbg_clk    (dbg_clk),       // Debug unit clock
    .dbg_en_s   (dbg_en_s),      // Debug interface enable (synchronous)
    .dbg_rst    (dbg_rst),       // Debug unit reset
    .dco_enable (dco_enable),    // Fast oscillator enable
    .dco_wkup   (dco_wkup),      // Fast oscillator wake-up (asynchronous)
    .lfxt_enable(lfxt_enable),   // Low frequency oscillator enable
    .lfxt_wkup  (lfxt_wkup),     // Low frequency oscillator wake-up (asynchronous)
    .mclk       (mclk),          // Main system clock
    .per_dout   (per_dout_clk),  // Peripheral data output
    .por        (por),           // Power-on reset
    .puc_pnd_set(puc_pnd_set),   // PUC pending set for the serial debug interface
    .puc_rst    (puc_rst),       // Main system reset
    .smclk      (smclk),         // SMCLK
    .smclk_en   (smclk_en),      // SMCLK enable

    .nodiv_smclk(nodiv_smclk),

    // INPUTs
    .cpu_en       (cpu_en),         // Enable CPU code execution (asynchronous)
    .cpuoff       (cpuoff),         // Turns off the CPU
    .dbg_cpu_reset(dbg_cpu_reset),  // Reset CPU from debug interface
    .dbg_en       (dbg_en),         // Debug interface enable (asynchronous)
    .dco_clk      (dco_clk),        // Fast oscillator (fast clock)
    .lfxt_clk     (lfxt_clk),       // Low frequency oscillator (typ 32kHz)
    .mclk_enable  (mclk_enable),    // Main System Clock enable
    .mclk_wkup    (mclk_wkup),      // Main System Clock wake-up (asynchronous)
    .oscoff       (oscoff),         // Turns off LFXT1 clock input
    .per_addr     (per_addr),       // Peripheral address
    .per_din      (per_din),        // Peripheral data input
    .per_en       (per_en),         // Peripheral enable (high active)
    .per_we       (per_we),         // Peripheral write enable (high active)
    .reset_n      (reset_n),        // Reset Pin (low active, asynchronous)
    .scan_enable  (scan_enable),    // Scan enable (active during scan shifting)
    .scan_mode    (scan_mode),      // Scan mode
    .scg0         (scg0),           // System clock generator 1. Turns off the DCO
    .scg1         (scg1),           // System clock generator 1. Turns off the SMCLK
    .wdt_reset    (wdt_reset)       // Watchdog-timer reset
  );

  //////////////////////////////////////////////////////////////////////////////
  // 3)  FRONTEND (<=> FETCH & DECODE)
  //////////////////////////////////////////////////////////////////////////////
  pu_msp430_frontend frontend (
    // OUTPUTs
    .dbg_halt_st (dbg_halt_st),   // Halt/Run status from CPU
    .decode_noirq(decode_noirq),  // Frontend decode instruction
    .e_state     (e_state),       // Execution state
    .exec_done   (exec_done),     // Execution completed
    .inst_ad     (inst_ad),       // Decoded Inst: destination addressing mode
    .inst_as     (inst_as),       // Decoded Inst: source addressing mode
    .inst_alu    (inst_alu),      // ALU control signals
    .inst_bw     (inst_bw),       // Decoded Inst: byte width
    .inst_dest   (inst_dest),     // Decoded Inst: destination (one hot)
    .inst_dext   (inst_dext),     // Decoded Inst: destination extended instruction word
    .inst_irq_rst(inst_irq_rst),  // Decoded Inst: Reset interrupt
    .inst_jmp    (inst_jmp),      // Decoded Inst: Conditional jump
    .inst_mov    (inst_mov),      // Decoded Inst: mov instruction
    .inst_sext   (inst_sext),     // Decoded Inst: source extended instruction word
    .inst_so     (inst_so),       // Decoded Inst: Single-operand arithmetic
    .inst_src    (inst_src),      // Decoded Inst: source (one hot)
    .inst_type   (inst_type),     // Decoded Instruction type
    .irq_acc     (irq_acc),       // Interrupt request accepted
    .mab         (fe_mab),        // Frontend Memory address bus
    .mb_en       (fe_mb_en),      // Frontend Memory bus enable
    .mclk_enable (mclk_enable),   // Main System Clock enable
    .mclk_wkup   (mclk_wkup),     // Main System Clock wake-up (asynchronous)
    .nmi_acc     (nmi_acc),       // Non-Maskable interrupt request accepted
    .pc          (pc),            // Program counter
    .pc_nxt      (pc_nxt),        // Next PC value (for CALL & IRQ)

    .decode    (decode),
    .irq_detect(irq_detect),
    .i_state   (i_state),
    .irq_num   (irq_num),
    .ir        (ir),

    // INPUTs
    .cpu_en_s    (cpu_en_s),           // Enable CPU code execution (synchronous)
    .cpuoff      (cpuoff),             // Turns off the CPU
    .dbg_halt_cmd(dbg_halt_cmd),       // Halt CPU command
    .dbg_reg_sel (dbg_mem_addr[3:0]),  // Debug selected register for rd/wr access
    .fe_pmem_wait(fe_pmem_wait),       // Frontend wait for Instruction fetch
    .gie         (gie),                // General interrupt enable
    .irq         (irq),                // Maskable interrupts
    .mclk        (mclk),               // Main system clock
    .mdb_in      (fe_mdb_in),          // Frontend Memory data bus input
    .nmi_pnd     (nmi_pnd),            // Non-maskable interrupt pending
    .nmi_wkup    (nmi_wkup),           // NMI Wakeup
    .pc_sw       (pc_sw),              // Program counter software value
    .pc_sw_wr    (pc_sw_wr),           // Program counter software write
    .puc_rst     (puc_rst),            // Main system reset
    .scan_enable (scan_enable),        // Scan enable (active during scan shifting)
    .wdt_irq     (wdt_irq),            // Watchdog-timer interrupt
    .wdt_wkup    (wdt_wkup),           // Watchdog Wakeup
    .wkup        (wkup)                // System Wake-up (asynchronous)
  );

  assign nmi_detect = nmi_pnd;

  //////////////////////////////////////////////////////////////////////////////
  // 4)  EXECUTION UNIT
  //////////////////////////////////////////////////////////////////////////////
  pu_msp430_execution execution (
    // OUTPUTs
    .r0 (r0),
    .r1 (r1),
    .r2 (r2),
    .r3 (r3),
    .r4 (r4),
    .r5 (r5),
    .r6 (r6),
    .r7 (r7),
    .r8 (r8),
    .r9 (r9),
    .r10(r10),
    .r11(r11),
    .r12(r12),
    .r13(r13),
    .r14(r14),
    .r15(r15),

    .cpuoff     (cpuoff),       // Turns off the CPU
    .dbg_reg_din(dbg_reg_din),  // Debug unit CPU register data input
    .mab        (eu_mab),       // Memory address bus
    .mb_en      (eu_mb_en),     // Memory bus enable
    .mb_wr      (eu_mb_wr),     // Memory bus write transfer
    .mdb_out    (eu_mdb_out),   // Memory data bus output
    .oscoff     (oscoff),       // Turns off LFXT1 clock input
    .pc_sw      (pc_sw),        // Program counter software value
    .pc_sw_wr   (pc_sw_wr),     // Program counter software write
    .scg0       (scg0),         // System clock generator 1. Turns off the DCO
    .scg1       (scg1),         // System clock generator 1. Turns off the SMCLK

    // INPUTs
    .dbg_halt_st (dbg_halt_st),   // Halt/Run status from CPU
    .dbg_mem_dout(dbg_mem_dout),  // Debug unit data output
    .dbg_reg_wr  (dbg_reg_wr),    // Debug unit CPU register write
    .e_state     (e_state),       // Execution state
    .exec_done   (exec_done),     // Execution completed
    .gie         (gie),           // General interrupt enable
    .inst_ad     (inst_ad),       // Decoded Inst: destination addressing mode
    .inst_as     (inst_as),       // Decoded Inst: source addressing mode
    .inst_alu    (inst_alu),      // ALU control signals
    .inst_bw     (inst_bw),       // Decoded Inst: byte width
    .inst_dest   (inst_dest),     // Decoded Inst: destination (one hot)
    .inst_dext   (inst_dext),     // Decoded Inst: destination extended instruction word
    .inst_irq_rst(inst_irq_rst),  // Decoded Inst: reset interrupt
    .inst_jmp    (inst_jmp),      // Decoded Inst: Conditional jump
    .inst_mov    (inst_mov),      // Decoded Inst: mov instruction
    .inst_sext   (inst_sext),     // Decoded Inst: source extended instruction word
    .inst_so     (inst_so),       // Decoded Inst: Single-operand arithmetic
    .inst_src    (inst_src),      // Decoded Inst: source (one hot)
    .inst_type   (inst_type),     // Decoded Instruction type
    .mclk        (mclk),          // Main system clock
    .mdb_in      (eu_mdb_in),     // Memory data bus input
    .pc          (pc),            // Program counter
    .pc_nxt      (pc_nxt),        // Next PC value (for CALL & IRQ)
    .puc_rst     (puc_rst),       // Main system reset
    .scan_enable (scan_enable)    // Scan enable (active during scan shifting)
  );

  //////////////////////////////////////////////////////////////////////////////
  // 5)  MEMORY BACKBONE
  //////////////////////////////////////////////////////////////////////////////
  pu_msp430_memory memory (
    // OUTPUTs
    .dbg_mem_din (dbg_mem_din),   // Debug unit Memory data input
    .dmem_addr   (dmem_addr),     // Data Memory address
    .dmem_cen    (dmem_cen),      // Data Memory chip enable (low active)
    .dmem_din    (dmem_din),      // Data Memory data input
    .dmem_wen    (dmem_wen),      // Data Memory write enable (low active)
    .eu_mdb_in   (eu_mdb_in),     // Execution Unit Memory data bus input
    .fe_mdb_in   (fe_mdb_in),     // Frontend Memory data bus input
    .fe_pmem_wait(fe_pmem_wait),  // Frontend wait for Instruction fetch
    .per_addr    (per_addr),      // Peripheral address
    .per_din     (per_din),       // Peripheral data input
    .per_we      (per_we),        // Peripheral write enable (high active)
    .per_en      (per_en),        // Peripheral enable (high active)
    .pmem_addr   (pmem_addr),     // Program Memory address
    .pmem_cen    (pmem_cen),      // Program Memory chip enable (low active)
    .pmem_din    (pmem_din),      // Program Memory data input (optional)
    .pmem_wen    (pmem_wen),      // Program Memory write enable (low active) (optional)

    // INPUTs
    .dbg_halt_st (dbg_halt_st),   // Halt/Run status from CPU
    .dbg_mem_addr(dbg_mem_addr),  // Debug address for rd/wr access
    .dbg_mem_dout(dbg_mem_dout),  // Debug unit data output
    .dbg_mem_en  (dbg_mem_en),    // Debug unit memory enable
    .dbg_mem_wr  (dbg_mem_wr),    // Debug unit memory write
    .dmem_dout   (dmem_dout),     // Data Memory data output
    .eu_mab      (eu_mab[15:1]),  // Execution Unit Memory address bus
    .eu_mb_en    (eu_mb_en),      // Execution Unit Memory bus enable
    .eu_mb_wr    (eu_mb_wr),      // Execution Unit Memory bus write transfer
    .eu_mdb_out  (eu_mdb_out),    // Execution Unit Memory data bus output
    .fe_mab      (fe_mab[15:1]),  // Frontend Memory address bus
    .fe_mb_en    (fe_mb_en),      // Frontend Memory bus enable
    .mclk        (mclk),          // Main system clock
    .per_dout    (per_dout_or),   // Peripheral data output
    .pmem_dout   (pmem_dout),     // Program Memory data output
    .puc_rst     (puc_rst),       // Main system reset
    .scan_enable (scan_enable)    // Scan enable (active during scan shifting)
  );

  //////////////////////////////////////////////////////////////////////////////
  // 6)  SPECIAL FUNCTION REGISTERS
  //////////////////////////////////////////////////////////////////////////////
  pu_msp430_sfr sfr (
    // OUTPUTs
    .cpu_id       (cpu_id),         // CPU ID
    .nmi_pnd      (nmi_pnd),        // NMI Pending
    .nmi_wkup     (nmi_wkup),       // NMI Wakeup
    .per_dout     (per_dout_sfr),   // Peripheral data output
    .wdtie        (wdtie),          // Watchdog-timer interrupt enable
    .wdtifg_sw_clr(wdtifg_sw_clr),  // Watchdog-timer interrupt flag software clear
    .wdtifg_sw_set(wdtifg_sw_set),  // Watchdog-timer interrupt flag software set

    // INPUTs
    .cpu_nr_inst (cpu_nr_inst),   // Current oMSP instance number
    .cpu_nr_total(cpu_nr_total),  // Total number of oMSP instances-1
    .mclk        (mclk),          // Main system clock
    .nmi         (nmi),           // Non-maskable interrupt (asynchronous)
    .nmi_acc     (nmi_acc),       // Non-Maskable interrupt request accepted
    .per_addr    (per_addr),      // Peripheral address
    .per_din     (per_din),       // Peripheral data input
    .per_en      (per_en),        // Peripheral enable (high active)
    .per_we      (per_we),        // Peripheral write enable (high active)
    .puc_rst     (puc_rst),       // Main system reset
    .scan_mode   (scan_mode),     // Scan mode
    .wdtifg      (wdtifg),        // Watchdog-timer interrupt flag
    .wdtnmies    (wdtnmies)       // Watchdog-timer NMI edge selection
  );

  //////////////////////////////////////////////////////////////////////////////
  // 7)  WATCHDOG TIMER
  //////////////////////////////////////////////////////////////////////////////
`ifdef WATCHDOG
  pu_msp430_watchdog watchdog (
    // OUTPUTs
    .per_dout (per_dout_wdog),  // Peripheral data output
    .wdt_irq  (wdt_irq),        // Watchdog-timer interrupt
    .wdt_reset(wdt_reset),      // Watchdog-timer reset
    .wdt_wkup (wdt_wkup),       // Watchdog Wakeup
    .wdtifg   (wdtifg),         // Watchdog-timer interrupt flag
    .wdtnmies (wdtnmies),       // Watchdog-timer NMI edge selection

    // INPUTs
    .aclk          (aclk),                // ACLK
    .aclk_en       (aclk_en),             // ACLK enable
    .dbg_freeze    (dbg_freeze),          // Freeze Watchdog counter
    .mclk          (mclk),                // Main system clock
    .per_addr      (per_addr),            // Peripheral address
    .per_din       (per_din),             // Peripheral data input
    .per_en        (per_en),              // Peripheral enable (high active)
    .per_we        (per_we),              // Peripheral write enable (high active)
    .por           (por),                 // Power-on reset
    .puc_rst       (puc_rst),             // Main system reset
    .scan_enable   (scan_enable),         // Scan enable (active during scan shifting)
    .scan_mode     (scan_mode),           // Scan mode
    .smclk         (smclk),               // SMCLK
    .smclk_en      (smclk_en),            // SMCLK enable
    .wdtie         (wdtie),               // Watchdog-timer interrupt enable
    .wdtifg_irq_clr(irq_acc[`IRQ_NR-6]),  // Clear Watchdog-timer interrupt flag
    .wdtifg_sw_clr (wdtifg_sw_clr),       // Watchdog-timer interrupt flag software clear
    .wdtifg_sw_set (wdtifg_sw_set)        // Watchdog-timer interrupt flag software set
  );
`else
  assign per_dout_wdog = 16'h0000;
  assign wdt_irq       = 1'b0;
  assign wdt_reset     = 1'b0;
  assign wdt_wkup      = 1'b0;
  assign wdtifg        = 1'b0;
  assign wdtnmies      = 1'b0;
`endif

  //////////////////////////////////////////////////////////////////////////////
  // 8)  HARDWARE MULTIPLIER
  //////////////////////////////////////////////////////////////////////////////
`ifdef MULTIPLYING
  pu_msp430_multiplier multiplier (
    // OUTPUTs
    .per_dout(per_dout_mpy),  // Peripheral data output

    // INPUTs
    .mclk       (mclk),        // Main system clock
    .per_addr   (per_addr),    // Peripheral address
    .per_din    (per_din),     // Peripheral data input
    .per_en     (per_en),      // Peripheral enable (high active)
    .per_we     (per_we),      // Peripheral write enable (high active)
    .puc_rst    (puc_rst),     // Main system reset
    .scan_enable(scan_enable)  // Scan enable (active during scan shifting)
  );
`else
  assign per_dout_mpy = 16'h0000;
`endif

  //////////////////////////////////////////////////////////////////////////////
  // 9)  PERIPHERALS' OUTPUT BUS
  //////////////////////////////////////////////////////////////////////////////
  assign per_dout_or = per_dout | per_dout_clk | per_dout_sfr | per_dout_wdog | per_dout_mpy;

  //////////////////////////////////////////////////////////////////////////////
  // 10)  DEBUG INTERFACE
  //////////////////////////////////////////////////////////////////////////////
`ifdef DBG_EN
  pu_msp430_dbg dbg (
    // OUTPUTs
    .dbg_cpu_reset  (dbg_cpu_reset),    // Reset CPU from debug interface
    .dbg_freeze     (dbg_freeze),       // Freeze peripherals
    .dbg_halt_cmd   (dbg_halt_cmd),     // Halt CPU command
    .dbg_i2c_sda_out(dbg_i2c_sda_out),  // Debug interface: I2C SDA OUT
    .dbg_mem_addr   (dbg_mem_addr),     // Debug address for rd/wr access
    .dbg_mem_dout   (dbg_mem_dout),     // Debug unit data output
    .dbg_mem_en     (dbg_mem_en),       // Debug unit memory enable
    .dbg_mem_wr     (dbg_mem_wr),       // Debug unit memory write
    .dbg_reg_wr     (dbg_reg_wr),       // Debug unit CPU register write
    .dbg_uart_txd   (dbg_uart_txd),     // Debug interface: UART TXD

    // INPUTs
    .cpu_en_s         (cpu_en_s),           // Enable CPU code execution (synchronous)
    .cpu_id           (cpu_id),             // CPU ID
    .cpu_nr_inst      (cpu_nr_inst),        // Current oMSP instance number
    .cpu_nr_total     (cpu_nr_total),       // Total number of oMSP instances-1
    .dbg_clk          (dbg_clk),            // Debug unit clock
    .dbg_en_s         (dbg_en_s),           // Debug interface enable (synchronous)
    .dbg_halt_st      (dbg_halt_st),        // Halt/Run status from CPU
    .dbg_i2c_addr     (dbg_i2c_addr),       // Debug interface: I2C Address
    .dbg_i2c_broadcast(dbg_i2c_broadcast),  // Debug interface: I2C Broadcast Address (for multicore systems)
    .dbg_i2c_scl      (dbg_i2c_scl),        // Debug interface: I2C SCL
    .dbg_i2c_sda_in   (dbg_i2c_sda_in),     // Debug interface: I2C SDA IN
    .dbg_mem_din      (dbg_mem_din),        // Debug unit Memory data input
    .dbg_reg_din      (dbg_reg_din),        // Debug unit CPU register data input
    .dbg_rst          (dbg_rst),            // Debug unit reset
    .dbg_uart_rxd     (dbg_uart_rxd),       // Debug interface: UART RXD (asynchronous)
    .decode_noirq     (decode_noirq),       // Frontend decode instruction
    .eu_mab           (eu_mab),             // Execution-Unit Memory address bus
    .eu_mb_en         (eu_mb_en),           // Execution-Unit Memory bus enable
    .eu_mb_wr         (eu_mb_wr),           // Execution-Unit Memory bus write transfer
    .fe_mdb_in        (fe_mdb_in),          // Frontend Memory data bus input
    .pc               (pc),                 // Program counter
    .puc_pnd_set      (puc_pnd_set)         // PUC pending set for the serial debug interface
  );
`else
  assign dbg_cpu_reset   = 1'b0;
  assign dbg_freeze      = ~cpu_en_s;
  assign dbg_halt_cmd    = 1'b0;
  assign dbg_i2c_sda_out = 1'b1;
  assign dbg_mem_addr    = 16'h0000;
  assign dbg_mem_dout    = 16'h0000;
  assign dbg_mem_en      = 1'b0;
  assign dbg_mem_wr      = 2'b00;
  assign dbg_reg_wr      = 1'b0;
  assign dbg_uart_txd    = 1'b1;
`endif
endmodule  // pu_msp430_core

`ifdef OMSP_NO_INCLUDE
`else
`include "pu_msp430_undefines.sv"
`endif
