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

module pu_msp430_testbench;
  wire    [       15:0] r0;
  wire    [       15:0] r1;
  wire    [       15:0] r2;
  wire    [       15:0] r3;
  wire    [       15:0] r4;
  wire    [       15:0] r5;
  wire    [       15:0] r6;
  wire    [       15:0] r7;
  wire    [       15:0] r8;
  wire    [       15:0] r9;
  wire    [       15:0] r10;
  wire    [       15:0] r11;
  wire    [       15:0] r12;
  wire    [       15:0] r13;
  wire    [       15:0] r14;
  wire    [       15:0] r15;

  wire                  dbg_clk;
  wire                  dbg_rst;
  wire                  irq_detect;
  wire                  nmi_detect;

  wire    [        2:0] i_state_bin;
  wire    [        3:0] e_state_bin;
  wire                  decode;
  wire    [       15:0] ir;
  wire    [        5:0] irq_num;
  wire    [       15:0] pc;

  wire                  nodiv_smclk;

  // Wire & Register definition

  // Data Memory interface
  wire    [`DMEM_MSB:0] dmem_addr;
  wire                  dmem_cen;
  wire    [       15:0] dmem_din;
  wire    [        1:0] dmem_wen;
  wire    [       15:0] dmem_dout;

  // Program Memory interface
  wire    [`PMEM_MSB:0] pmem_addr;
  wire                  pmem_cen;
  wire    [       15:0] pmem_din;
  wire    [        1:0] pmem_wen;
  wire    [       15:0] pmem_dout;

  // Peripherals interface
  wire    [       13:0] per_addr;
  wire    [       15:0] per_din;
  wire    [       15:0] per_dout;
  wire    [        1:0] per_we;
  wire                  per_en;

  // Digital I/O
  wire                  irq_port1;
  wire                  irq_port2;
  wire    [       15:0] per_dout_dio;
  wire    [        7:0] p1_dout;
  wire    [        7:0] p1_dout_en;
  wire    [        7:0] p1_sel;
  wire    [        7:0] p2_dout;
  wire    [        7:0] p2_dout_en;
  wire    [        7:0] p2_sel;
  wire    [        7:0] p3_dout;
  wire    [        7:0] p3_dout_en;
  wire    [        7:0] p3_sel;
  wire    [        7:0] p4_dout;
  wire    [        7:0] p4_dout_en;
  wire    [        7:0] p4_sel;
  wire    [        7:0] p5_dout;
  wire    [        7:0] p5_dout_en;
  wire    [        7:0] p5_sel;
  wire    [        7:0] p6_dout;
  wire    [        7:0] p6_dout_en;
  wire    [        7:0] p6_sel;
  reg     [        7:0] p1_din;
  reg     [        7:0] p2_din;
  reg     [        7:0] p3_din;
  reg     [        7:0] p4_din;
  reg     [        7:0] p5_din;
  reg     [        7:0] p6_din;
  wire    [        7:0] p1dir;
  wire    [        7:0] p1ifg;

  // Peripheral templates
  wire    [       15:0] per_dout_temp_8b;
  wire    [       15:0] per_dout_temp_16b;
  wire    [       15:0] cntrl2_16b;
  wire    [       15:0] cntrl4_16b;

  // Simple full duplex UART
  wire    [       15:0] per_dout_uart;
  wire                  irq_uart_rx;
  wire                  irq_uart_tx;
  wire                  uart_txd;
  reg                   uart_rxd;

  // Timer A
  wire                  irq_ta0;
  wire                  irq_ta1;
  wire    [       15:0] per_dout_timerA;
  reg                   inclk;
  reg                   taclk;
  reg                   ta_cci0a;
  reg                   ta_cci0b;
  reg                   ta_cci1a;
  reg                   ta_cci1b;
  reg                   ta_cci2a;
  reg                   ta_cci2b;
  wire                  ta_out0;
  wire                  ta_out0_en;
  wire                  ta_out1;
  wire                  ta_out1_en;
  wire                  ta_out2;
  wire                  ta_out2_en;
  wire    [       15:0] tar;
  wire    [       15:0] taccr0;

  // Clock / Reset & Interrupts
  reg                   dco_clk;
  wire                  dco_enable;
  wire                  dco_wkup;
  reg                   dco_local_enable;
  reg                   lfxt_clk;
  wire                  lfxt_enable;
  wire                  lfxt_wkup;
  reg                   lfxt_local_enable;
  wire                  mclk;
  wire                  aclk;
  wire                  aclk_en;
  wire                  smclk;
  wire                  smclk_en;
  reg                   reset_n;
  wire                  puc_rst;
  reg                   nmi;
  reg     [`IRQ_NR-3:0] irq;
  wire    [`IRQ_NR-3:0] irq_acc;
  wire    [`IRQ_NR-3:0] irq_in;
  reg                   cpu_en;
  reg     [       13:0] wkup;
  wire    [       13:0] wkup_in;

  // Scan (ASIC version only)
  reg                   scan_enable;
  reg                   scan_mode;

  // Debug interface: UART
  reg                   dbg_en;
  wire                  dbg_freeze;
  wire                  dbg_uart_txd;
  wire                  dbg_uart_rxd;
  reg                   dbg_uart_rxd_sel;
  reg                   dbg_uart_rxd_dly;
  reg                   dbg_uart_rxd_pre;
  reg                   dbg_uart_rxd_meta;
  reg     [       15:0] dbg_uart_buf;
  reg                   dbg_uart_rx_busy;
  reg                   dbg_uart_tx_busy;

  // Debug interface: I2C
  wire                  dbg_scl;
  wire                  dbg_sda;
  wire                  dbg_scl_slave;
  wire                  dbg_scl_master;
  reg                   dbg_scl_master_sel;
  reg                   dbg_scl_master_dly;
  reg                   dbg_scl_master_pre;
  reg                   dbg_scl_master_meta;
  wire                  dbg_sda_slave_out;
  wire                  dbg_sda_slave_in;
  wire                  dbg_sda_master_out;
  reg                   dbg_sda_master_out_sel;
  reg                   dbg_sda_master_out_dly;
  reg                   dbg_sda_master_out_pre;
  reg                   dbg_sda_master_out_meta;
  wire                  dbg_sda_master_in;
  reg     [       15:0] dbg_i2c_buf;
  reg     [   8*32-1:0] dbg_i2c_string;

  // Core testbench debuging signals
  wire    [   8*32-1:0] i_state;
  wire    [   8*32-1:0] e_state;
  wire    [       31:0] inst_cycle;
  wire    [   8*32-1:0] inst_full;
  wire    [       31:0] inst_number;
  wire    [       15:0] inst_pc;
  wire    [   8*32-1:0] inst_short;

  // Testbench variables
  integer               error;
  reg                   stimulus_done;

  // Include files

  // CPU & Memory registers
  `include "pu_msp430_registers.sv"

  // Debug interface tasks
  `include "pu_msp430_dbg_uart_tasks.sv"
  `include "pu_msp430_dbg_i2c_tasks.sv"

  // Simple uart tasks
  //`include "uart_tasks.sv"

  // Verilog stimulus
  `include "stimulus.sv"

  // Initialize ROM
  initial begin
    #10 $readmemh("./pmem.mem", pmem_0.mem);
  end

  // Generate Clock & Reset
  initial begin
    dco_clk          = 1'b0;
    dco_local_enable = 1'b0;
    forever begin
      #25;  // 20 MHz
      dco_local_enable = (dco_enable === 1) ? dco_enable : (dco_wkup === 1);
      if (dco_local_enable) begin
        dco_clk = ~dco_clk;
      end
    end
  end

  initial begin
    lfxt_clk          = 1'b0;
    lfxt_local_enable = 1'b0;
    forever begin
      #763;  // 655 kHz
      lfxt_local_enable = (lfxt_enable === 1) ? lfxt_enable : (lfxt_wkup === 1);
      if (lfxt_local_enable) begin
        lfxt_clk = ~lfxt_clk;
      end
    end
  end

  initial begin
    reset_n = 1'b1;
    #93;
    reset_n = 1'b0;
    #593;
    reset_n = 1'b1;
  end

  initial begin
    error                   = 0;
    stimulus_done           = 1;
    irq                     = {`IRQ_NR - 2{1'b0}};
    nmi                     = 1'b0;
    wkup                    = 14'h0000;
    cpu_en                  = 1'b1;
    dbg_en                  = 1'b0;
    dbg_uart_rxd_sel        = 1'b0;
    dbg_uart_rxd_dly        = 1'b1;
    dbg_uart_rxd_pre        = 1'b1;
    dbg_uart_rxd_meta       = 1'b0;
    dbg_uart_buf            = 16'h0000;
    dbg_uart_rx_busy        = 1'b0;
    dbg_uart_tx_busy        = 1'b0;
    dbg_scl_master_sel      = 1'b0;
    dbg_scl_master_dly      = 1'b1;
    dbg_scl_master_pre      = 1'b1;
    dbg_scl_master_meta     = 1'b0;
    dbg_sda_master_out_sel  = 1'b0;
    dbg_sda_master_out_dly  = 1'b1;
    dbg_sda_master_out_pre  = 1'b1;
    dbg_sda_master_out_meta = 1'b0;
    dbg_i2c_string          = "";
    p1_din                  = 8'h00;
    p2_din                  = 8'h00;
    p3_din                  = 8'h00;
    p4_din                  = 8'h00;
    p5_din                  = 8'h00;
    p6_din                  = 8'h00;
    inclk                   = 1'b0;
    taclk                   = 1'b0;
    ta_cci0a                = 1'b0;
    ta_cci0b                = 1'b0;
    ta_cci1a                = 1'b0;
    ta_cci1b                = 1'b0;
    ta_cci2a                = 1'b0;
    ta_cci2b                = 1'b0;
    uart_rxd                = 1'b1;
    scan_enable             = 1'b0;
    scan_mode               = 1'b0;
  end

  // Program Memory
  pu_msp430_ram #(`PMEM_MSB, `PMEM_SIZE) pmem_0 (
    // OUTPUTs
    .ram_dout(pmem_dout),  // Program Memory data output

    // INPUTs
    .ram_addr(pmem_addr),  // Program Memory address
    .ram_cen (pmem_cen),   // Program Memory chip enable (low active)
    .ram_clk (mclk),       // Program Memory clock
    .ram_din (pmem_din),   // Program Memory data input
    .ram_wen (pmem_wen)    // Program Memory write enable (low active)
  );

  // Data Memory
  pu_msp430_ram #(`DMEM_MSB, `DMEM_SIZE) dmem_0 (
    // OUTPUTs
    .ram_dout(dmem_dout),  // Data Memory data output

    // INPUTs
    .ram_addr(dmem_addr),  // Data Memory address
    .ram_cen (dmem_cen),   // Data Memory chip enable (low active)
    .ram_clk (mclk),       // Data Memory clock
    .ram_din (dmem_din),   // Data Memory data input
    .ram_wen (dmem_wen)    // Data Memory write enable (low active)
  );

  // openMSP430 Instance
  pu_msp430_core dut (
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

    .dbg_clk   (dbg_clk),
    .dbg_rst   (dbg_rst),
    .irq_detect(irq_detect),
    .nmi_detect(nmi_detect),

    .i_state(i_state_bin),
    .e_state(e_state_bin),
    .decode (decode),
    .ir     (ir),
    .irq_num(irq_num),
    .pc     (pc),

    .nodiv_smclk(nodiv_smclk),

    .aclk           (aclk),               // ASIC ONLY: ACLK
    .aclk_en        (aclk_en),            // FPGA ONLY: ACLK enable
    .dbg_freeze     (dbg_freeze),         // Freeze peripherals
    .dbg_i2c_sda_out(dbg_sda_slave_out),  // Debug interface: I2C SDA OUT
    .dbg_uart_txd   (dbg_uart_txd),       // Debug interface: UART TXD
    .dco_enable     (dco_enable),         // ASIC ONLY: Fast oscillator enable
    .dco_wkup       (dco_wkup),           // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    .dmem_addr      (dmem_addr),          // Data Memory address
    .dmem_cen       (dmem_cen),           // Data Memory chip enable (low active)
    .dmem_din       (dmem_din),           // Data Memory data input
    .dmem_wen       (dmem_wen),           // Data Memory write enable (low active)
    .irq_acc        (irq_acc),            // Interrupt request accepted (one-hot signal)
    .lfxt_enable    (lfxt_enable),        // ASIC ONLY: Low frequency oscillator enable
    .lfxt_wkup      (lfxt_wkup),          // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    .mclk           (mclk),               // Main system clock
    .per_addr       (per_addr),           // Peripheral address
    .per_din        (per_din),            // Peripheral data input
    .per_we         (per_we),             // Peripheral write enable (high active)
    .per_en         (per_en),             // Peripheral enable (high active)
    .pmem_addr      (pmem_addr),          // Program Memory address
    .pmem_cen       (pmem_cen),           // Program Memory chip enable (low active)
    .pmem_din       (pmem_din),           // Program Memory data input (optional)
    .pmem_wen       (pmem_wen),           // Program Memory write enable (low active) (optional)
    .puc_rst        (puc_rst),            // Main system reset
    .smclk          (smclk),              // ASIC ONLY: SMCLK
    .smclk_en       (smclk_en),           // FPGA ONLY: SMCLK enable

    // INPUTs
    .cpu_en           (cpu_en),            // Enable CPU code execution (asynchronous)
    .dbg_en           (dbg_en),            // Debug interface enable (asynchronous)
    .dbg_i2c_addr     (I2C_ADDR),          // Debug interface: I2C Address
    .dbg_i2c_broadcast(I2C_BROADCAST),     // Debug interface: I2C Broadcast Address (for multicore systems)
    .dbg_i2c_scl      (dbg_scl_slave),     // Debug interface: I2C SCL
    .dbg_i2c_sda_in   (dbg_sda_slave_in),  // Debug interface: I2C SDA IN
    .dbg_uart_rxd     (dbg_uart_rxd),      // Debug interface: UART RXD (asynchronous)
    .dco_clk          (dco_clk),           // Fast oscillator (fast clock)
    .dmem_dout        (dmem_dout),         // Data Memory data output
    .irq              (irq_in),            // Maskable interrupts
    .lfxt_clk         (lfxt_clk),          // Low frequency oscillator (typ 32kHz)
    .nmi              (nmi),               // Non-maskable interrupt (asynchronous)
    .per_dout         (per_dout),          // Peripheral data output
    .pmem_dout        (pmem_dout),         // Program Memory data output
    .reset_n          (reset_n),           // Reset Pin (low active, asynchronous)
    .scan_enable      (scan_enable),       // ASIC ONLY: Scan enable (active during scan shifting)
    .scan_mode        (scan_mode),         // ASIC ONLY: Scan mode
    .wkup             (|wkup_in)           // ASIC ONLY: System Wake-up (asynchronous)
  );

  // Digital I/O
  pu_msp430_gpio gpio (
    // OUTPUTs
    .irq_port1 (irq_port1),     // Port 1 interrupt
    .irq_port2 (irq_port2),     // Port 2 interrupt
    .p1_dout   (p1_dout),       // Port 1 data output
    .p1_dout_en(p1_dout_en),    // Port 1 data output enable
    .p1_sel    (p1_sel),        // Port 1 function select
    .p2_dout   (p2_dout),       // Port 2 data output
    .p2_dout_en(p2_dout_en),    // Port 2 data output enable
    .p2_sel    (p2_sel),        // Port 2 function select
    .p3_dout   (p3_dout),       // Port 3 data output
    .p3_dout_en(p3_dout_en),    // Port 3 data output enable
    .p3_sel    (p3_sel),        // Port 3 function select
    .p4_dout   (p4_dout),       // Port 4 data output
    .p4_dout_en(p4_dout_en),    // Port 4 data output enable
    .p4_sel    (p4_sel),        // Port 4 function select
    .p5_dout   (p5_dout),       // Port 5 data output
    .p5_dout_en(p5_dout_en),    // Port 5 data output enable
    .p5_sel    (p5_sel),        // Port 5 function select
    .p6_dout   (p6_dout),       // Port 6 data output
    .p6_dout_en(p6_dout_en),    // Port 6 data output enable
    .p6_sel    (p6_sel),        // Port 6 function select
    .per_dout  (per_dout_dio),  // Peripheral data output
    .p1dir     (p1dir),
    .p1ifg     (p1ifg),

    // INPUTs
    .mclk    (mclk),      // Main system clock
    .p1_din  (p1_din),    // Port 1 data input
    .p2_din  (p2_din),    // Port 2 data input
    .p3_din  (p3_din),    // Port 3 data input
    .p4_din  (p4_din),    // Port 4 data input
    .p5_din  (p5_din),    // Port 5 data input
    .p6_din  (p6_din),    // Port 6 data input
    .per_addr(per_addr),  // Peripheral address
    .per_din (per_din),   // Peripheral data input
    .per_en  (per_en),    // Peripheral enable (high active)
    .per_we  (per_we),    // Peripheral write enable (high active)
    .puc_rst (puc_rst)    // Main system reset
  );

  // Timers
  pu_msp430_ta ta (
    // OUTPUTs
    .irq_ta0   (irq_ta0),          // Timer A interrupt: TACCR0
    .irq_ta1   (irq_ta1),          // Timer A interrupt: TAIV, TACCR1, TACCR2
    .per_dout  (per_dout_timerA),  // Peripheral data output
    .ta_out0   (ta_out0),          // Timer A output 0
    .ta_out0_en(ta_out0_en),       // Timer A output 0 enable
    .ta_out1   (ta_out1),          // Timer A output 1
    .ta_out1_en(ta_out1_en),       // Timer A output 1 enable
    .ta_out2   (ta_out2),          // Timer A output 2
    .ta_out2_en(ta_out2_en),       // Timer A output 2 enable
    .tar       (tar),
    .taccr0    (taccr0),

    // INPUTs
    .aclk_en    (aclk_en),             // ACLK enable (from CPU)
    .dbg_freeze (dbg_freeze),          // Freeze Timer A counter
    .inclk      (inclk),               // INCLK external timer clock (SLOW)
    .irq_ta0_acc(irq_acc[`IRQ_NR-7]),  // Interrupt request TACCR0 accepted
    .mclk       (mclk),                // Main system clock
    .per_addr   (per_addr),            // Peripheral address
    .per_din    (per_din),             // Peripheral data input
    .per_en     (per_en),              // Peripheral enable (high active)
    .per_we     (per_we),              // Peripheral write enable (high active)
    .puc_rst    (puc_rst),             // Main system reset
    .smclk_en   (smclk_en),            // SMCLK enable (from CPU)
    .ta_cci0a   (ta_cci0a),            // Timer A compare 0 input A
    .ta_cci0b   (ta_cci0b),            // Timer A compare 0 input B
    .ta_cci1a   (ta_cci1a),            // Timer A compare 1 input A
    .ta_cci1b   (ta_cci1b),            // Timer A compare 1 input B
    .ta_cci2a   (ta_cci2a),            // Timer A compare 2 input A
    .ta_cci2b   (ta_cci2b),            // Timer A compare 2 input B
    .taclk      (taclk)                // TACLK external timer clock (SLOW)
  );

  // Simple full duplex UART (8N1 protocol)
  pu_msp430_uart uart (
    // OUTPUTs
    .irq_uart_rx(irq_uart_rx),    // UART receive interrupt
    .irq_uart_tx(irq_uart_tx),    // UART transmit interrupt
    .per_dout   (per_dout_uart),  // Peripheral data output
    .uart_txd   (uart_txd),       // UART Data Transmit (TXD)

    // INPUTs
    .mclk    (mclk),      // Main system clock
    .per_addr(per_addr),  // Peripheral address
    .per_din (per_din),   // Peripheral data input
    .per_en  (per_en),    // Peripheral enable (high active)
    .per_we  (per_we),    // Peripheral write enable (high active)
    .puc_rst (puc_rst),   // Main system reset
    .smclk_en(smclk_en),  // SMCLK enable (from CPU)
    .uart_rxd(uart_rxd)   // UART Data Receive (RXD)
  );

  // Peripheral templates
  pu_msp430_template08 template08 (
    // OUTPUTs
    .per_dout(per_dout_temp_8b),  // Peripheral data output

    // INPUTs
    .mclk    (mclk),      // Main system clock
    .per_addr(per_addr),  // Peripheral address
    .per_din (per_din),   // Peripheral data input
    .per_en  (per_en),    // Peripheral enable (high active)
    .per_we  (per_we),    // Peripheral write enable (high active)
    .puc_rst (puc_rst)    // Main system reset
  );

  pu_msp430_template16 template16 (
    // OUTPUTs
    .per_dout  (per_dout_temp_16b),  // Peripheral data output
    .cntrl2_16b(cntrl2_16b),
    .cntrl4_16b(cntrl4_16b),

    // INPUTs
    .mclk    (mclk),      // Main system clock
    .per_addr(per_addr),  // Peripheral address
    .per_din (per_din),   // Peripheral data input
    .per_en  (per_en),    // Peripheral enable (high active)
    .per_we  (per_we),    // Peripheral write enable (high active)
    .puc_rst (puc_rst)    // Main system reset
  );

  // Combine peripheral data bus
  assign per_dout = per_dout_dio | per_dout_timerA | per_dout_uart | per_dout_temp_8b | per_dout_temp_16b;

  // Map peripheral interrupts & wakeups
  assign irq_in = irq | {1'b0,  // Vector 13  (0xFFFA)
    1'b0,  // Vector 12  (0xFFF8)
    1'b0,  // Vector 11  (0xFFF6)
    1'b0,  // Vector 10  (0xFFF4) - Watchdog -
    irq_ta0,  // Vector  9  (0xFFF2)
    irq_ta1,  // Vector  8  (0xFFF0)
    irq_uart_rx,  // Vector  7  (0xFFEE)
    irq_uart_tx,  // Vector  6  (0xFFEC)
    1'b0,  // Vector  5  (0xFFEA)
    1'b0,  // Vector  4  (0xFFE8)
    irq_port2,  // Vector  3  (0xFFE6)
    irq_port1,  // Vector  2  (0xFFE4)
    1'b0,  // Vector  1  (0xFFE2)
    {`IRQ_NR - 15{1'b0}}};  // Vector  0  (0xFFE0)

  assign wkup_in = wkup | {1'b0,  // Vector 13  (0xFFFA)
    1'b0,  // Vector 12  (0xFFF8)
    1'b0,  // Vector 11  (0xFFF6)
    1'b0,  // Vector 10  (0xFFF4) - Watchdog -
    1'b0,  // Vector  9  (0xFFF2)
    1'b0,  // Vector  8  (0xFFF0)
    1'b0,  // Vector  7  (0xFFEE)
    1'b0,  // Vector  6  (0xFFEC)
    1'b0,  // Vector  5  (0xFFEA)
    1'b0,  // Vector  4  (0xFFE8)
    1'b0,  // Vector  3  (0xFFE6)
    1'b0,  // Vector  2  (0xFFE4)
    1'b0,  // Vector  1  (0xFFE2)
    1'b0};  // Vector  0  (0xFFE0)

  // I2C serial debug interface

  // I2C Bus
  pullup dbg_scl_inst (dbg_scl);
  pullup dbg_sda_inst (dbg_sda);

  // I2C Slave (openMSP430)
  pu_msp430_io_cell scl_slave_inst (
    .pad        (dbg_scl),        // I/O pad
    .data_in    (dbg_scl_slave),  // Input
    .data_out_en(1'b0),           // Output enable
    .data_out   (1'b0)            // Output
  );

  pu_msp430_io_cell sda_slave_inst (
    .pad        (dbg_sda),             // I/O pad
    .data_in    (dbg_sda_slave_in),    // Input
    .data_out_en(!dbg_sda_slave_out),  // Output enable
    .data_out   (1'b0)                 // Output
  );

  // I2C Master (Debugger)¡
  pu_msp430_io_cell scl_master_inst (
    .pad        (dbg_scl),          // I/O pad
    .data_in    (),                 // Input
    .data_out_en(!dbg_scl_master),  // Output enable
    .data_out   (1'b0)              // Output
  );

  pu_msp430_io_cell sda_master_inst (
    .pad        (dbg_sda),              // I/O pad
    .data_in    (dbg_sda_master_in),    // Input
    .data_out_en(!dbg_sda_master_out),  // Output enable
    .data_out   (1'b0)                  // Output
  );

  // Debug utility signals
  pu_msp430_debug debug (
    // OUTPUTs
    .e_state    (e_state),      // Execution state
    .i_state    (i_state),      // Instruction fetch state
    .inst_cycle (inst_cycle),   // Cycle number within current instruction
    .inst_full  (inst_full),    // Currently executed instruction (full version)
    .inst_number(inst_number),  // Instruction number since last system reset
    .inst_pc    (inst_pc),      // Instruction Program counter
    .inst_short (inst_short),   // Currently executed instruction (short version)

    // INPUTs
    .mclk   (mclk),    // Main system clock
    .puc_rst(puc_rst)  // Main system reset
  );

  // Generate Waveform
  initial begin
`ifdef NODUMP
`else
`ifdef VPD_FILE
    $vcdplusfile("pu_msp430_testbench.vpd");
    $vcdpluson();
`else
`ifdef TRN_FILE
    $recordfile("pu_msp430_testbench.trn");
    $recordvars;
`else
    $dumpfile("pu_msp430_testbench.vcd");
    $dumpvars(0, pu_msp430_testbench);
`endif
`endif
`endif
  end

  // End of simulation
  initial begin  // Timeout
`ifdef NO_TIMEOUT
`else
`ifdef VERY_LONG_TIMEOUT
    #500000000;
`else
`ifdef LONG_TIMEOUT
    #5000000;
`else
    #500000;
`endif
`endif
    $display(" ===============================================");
    $display("|               SIMULATION FAILED               |");
    $display("|              (simulation Timeout)             |");
    $display(" ===============================================");
    $finish;
`endif
  end

  initial begin  // Normal end of test
    @(negedge stimulus_done);
    wait (inst_pc == 'hffff);

    $display(" ===============================================");
    if (error != 0) begin
      $display("|               SIMULATION FAILED               |");
      $display("|     (some verilog stimulus checks failed)     |");
    end else if (~stimulus_done) begin
      $display("|               SIMULATION FAILED               |");
      $display("|     (the verilog stimulus didn't complete)    |");
    end else begin
      $display("|               SIMULATION PASSED               |");
    end
    $display(" ===============================================");
    $finish;
  end

  // Tasks Definition
  task tb_error;
    input [65*8:0] error_string;
    begin
      $display("ERROR: %s %t", error_string, $time);
      error = error + 1;
    end
  endtask
endmodule
