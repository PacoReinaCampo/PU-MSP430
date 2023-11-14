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

module msp430_synthesis #(
  parameter AW = 16,
  parameter DW = 16,

  parameter INST_NR  = 8'h00,  // Current oMSP instance number     (for multicore systems)
  parameter TOTAL_NR = 8'h00   // Total number of oMSP instances-1 (for multicore systems)
)
  (
    output [DW     -1:0] ir,
    input                cpu_en,            // Enable CPU code execution (asynchronous and non-glitchy)
    input  [`IRQ_NR-3:0] irq,               // Maskable interrupts (14, 30 or 62)
    input                nmi,               // Non-maskable interrupt (asynchronous and non-glitchy)
    input                reset_n,           // Reset Pin (active low, asynchronous and non-glitchy)

    output               aclk_en,           // FPGA ONLY: ACLK enable
    output               smclk_en,          // FPGA ONLY: SMCLK enable

    output               aclk,              // ASIC ONLY: ACLK
    output               lfxt_enable,       // ASIC ONLY: Low frequency oscillator enable
    output               lfxt_wkup,         // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    output               smclk,             // ASIC ONLY: SMCLK
    input                scan_enable,       // ASIC ONLY: Scan enable (active during scan shifting)
    input                scan_mode,         // ASIC ONLY: Scan mode
    input                wkup,              // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)
    
    output               dco_enable,        // ASIC ONLY: Fast oscillator enable
    output               dco_wkup,          // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    input                dco_clk,           // Fast oscillator (fast clock)

    output               dbg_clk,
    output               dbg_rst,
    output               dbg_freeze,        // Freeze peripherals
    output               dbg_i2c_sda_out,   // Debug interface: I2C SDA OUT
    output               dbg_uart_txd,      // Debug interface: UART TXD
    input                dbg_en,            // Debug interface enable (asynchronous and non-glitchy)
    input  [        6:0] dbg_i2c_addr,      // Debug interface: I2C Address
    input  [        6:0] dbg_i2c_broadcast, // Debug interface: I2C Broadcast Address (for multicore systems)
    input                dbg_i2c_scl,       // Debug interface: I2C SCL
    input                dbg_i2c_sda_in,    // Debug interface: I2C SDA IN
    input                dbg_uart_rxd       // Debug interface: UART RXD (asynchronous)
  );

  wire [`IRQ_NR-3:0] irq_in;
  wire        [13:0] wkup_in;

  // Data Memory interface
  wire [`DMEM_MSB:0] dmem_addr;
  wire               dmem_cen;
  wire        [15:0] dmem_din;
  wire         [1:0] dmem_wen;
  wire        [15:0] dmem_dout;

  // Program Memory interface
  wire [`PMEM_MSB:0] pmem_addr;
  wire               pmem_cen;
  wire        [15:0] pmem_din;
  wire         [1:0] pmem_wen;
  wire        [15:0] pmem_dout;

  // Peripherals interface
  wire        [13:0] per_addr;
  wire        [15:0] per_din;
  wire        [15:0] per_dout;
  wire         [1:0] per_we;
  wire               per_en;

  // Digital I/O
  wire               irq_port1;
  wire               irq_port2;
  wire        [15:0] per_dout_dio;
  wire         [7:0] p1_dout;
  wire         [7:0] p1_dout_en;
  wire         [7:0] p1_sel;
  wire         [7:0] p2_dout;
  wire         [7:0] p2_dout_en;
  wire         [7:0] p2_sel;
  wire         [7:0] p3_dout;
  wire         [7:0] p3_dout_en;
  wire         [7:0] p3_sel;
  wire         [7:0] p4_dout;
  wire         [7:0] p4_dout_en;
  wire         [7:0] p4_sel;
  wire         [7:0] p5_dout;
  wire         [7:0] p5_dout_en;
  wire         [7:0] p5_sel;
  wire         [7:0] p6_dout;
  wire         [7:0] p6_dout_en;
  wire         [7:0] p6_sel;
  reg          [7:0] p1_din;
  reg          [7:0] p2_din;
  reg          [7:0] p3_din;
  reg          [7:0] p4_din;
  reg          [7:0] p5_din;
  reg          [7:0] p6_din;
  wire         [7:0] p1dir;
  wire         [7:0] p1ifg;

  // Peripheral templates
  wire        [15:0] per_dout_temp_8b;
  wire        [15:0] per_dout_temp_16b;
  wire        [15:0] cntrl2_16b;
  wire        [15:0] cntrl4_16b;

  // Simple full duplex UART
  wire        [15:0] per_dout_uart;
  wire               irq_uart_rx;
  wire               irq_uart_tx;
  wire               uart_txd;
  reg                uart_rxd;

  // Timer A
  wire               irq_ta0;
  wire               irq_ta1;
  wire        [15:0] per_dout_timerA;
  reg                inclk;
  reg                taclk;
  reg                ta_cci0a;
  reg                ta_cci0b;
  reg                ta_cci1a;
  reg                ta_cci1b;
  reg                ta_cci2a;
  reg                ta_cci2b;
  wire               ta_out0;
  wire               ta_out0_en;
  wire               ta_out1;
  wire               ta_out1_en;
  wire               ta_out2;
  wire               ta_out2_en;
  wire        [15:0] tar;
  wire        [15:0] taccr0;
  
  //
  // Program Memory
  //----------------------------------

  pu_msp430_ram #(`PMEM_MSB, `PMEM_SIZE) pmem_0 (
    // OUTPUTs
    .ram_dout    (pmem_dout),          // Program Memory data output

    // INPUTs
    .ram_addr    (pmem_addr),          // Program Memory address
    .ram_cen     (pmem_cen),           // Program Memory chip enable (low active)
    .ram_clk     (mclk),               // Program Memory clock
    .ram_din     (pmem_din),           // Program Memory data input
    .ram_wen     (pmem_wen)            // Program Memory write enable (low active)
  );

  // Data Memory
  //----------------------------------

  pu_msp430_ram #(`DMEM_MSB, `DMEM_SIZE) dmem_0 (
    // OUTPUTs
    .ram_dout    (dmem_dout),          // Data Memory data output

    // INPUTs
    .ram_addr    (dmem_addr),          // Data Memory address
    .ram_cen     (dmem_cen),           // Data Memory chip enable (low active)
    .ram_clk     (mclk),               // Data Memory clock
    .ram_din     (dmem_din),           // Data Memory data input
    .ram_wen     (dmem_wen)            // Data Memory write enable (low active)
  );

  // openMSP430 Instance
  //----------------------------------

  pu_msp430_core dut (
    .irq_detect        (),
    .nmi_detect        (),
    .i_state           (),
    .e_state           (),
    .decode            (),
    .ir                (ir),
    .irq_num           (),
    .pc                (),
    .nodiv_smclk       (),
    .irq_acc           (),                  // Interrupt request accepted (one-hot signal)
    .mclk              (),                  // Main system clock
    .puc_rst           (),                  // Main system reset
    .cpu_en            (cpu_en),            // Enable CPU code execution (asynchronous)
    .irq               (irq),               // Maskable interrupts
    .lfxt_clk          (1'b0),              // Low frequency oscillator (typ 32kHz)
    .nmi               (nmi),               // Non-maskable interrupt (asynchronous)
    .reset_n           (reset_n),           // Reset Pin (low active, asynchronous)

    .aclk_en           (aclk_en),           // FPGA ONLY: ACLK enable
    .smclk_en          (smclk_en),          // FPGA ONLY: SMCLK enable

    .aclk              (aclk),              // ASIC ONLY: ACLK
    .lfxt_enable       (lfxt_enable),       // ASIC ONLY: Low frequency oscillator enable
    .lfxt_wkup         (lfxt_wkup),         // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    .smclk             (smclk),             // ASIC ONLY: SMCLK
    .scan_enable       (scan_enable),       // ASIC ONLY: Scan enable (active during scan shifting)
    .scan_mode         (scan_mode),         // ASIC ONLY: Scan mode
    .wkup              (|wkup_in),          // ASIC ONLY: System Wake-up (asynchronous)

    .dco_enable        (dco_enable),        // ASIC ONLY: Fast oscillator enable
    .dco_wkup          (dco_wkup),          // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    .dco_clk           (dco_clk),           // Fast oscillator (fast clock)

    .dbg_clk           (dbg_clk),
    .dbg_rst           (dbg_rst),
    .dbg_freeze        (dbg_freeze),        // Freeze peripherals
    .dbg_i2c_sda_out   (dbg_i2c_sda_out),   // Debug interface: I2C SDA OUT
    .dbg_uart_txd      (dbg_uart_txd),      // Debug interface: UART TXD
    .dbg_en            (dbg_en),            // Debug interface enable (asynchronous)
    .dbg_i2c_addr      (dbg_i2c_addr),      // Debug interface: I2C Address
    .dbg_i2c_broadcast (dbg_i2c_broadcast), // Debug interface: I2C Broadcast Address (for multicore systems)
    .dbg_i2c_scl       (dbg_i2c_scl),       // Debug interface: I2C SCL
    .dbg_i2c_sda_in    (dbg_i2c_sda_in),    // Debug interface: I2C SDA IN
    .dbg_uart_rxd      (dbg_uart_rxd),      // Debug interface: UART RXD (asynchronous)

    .pmem_addr         (pmem_addr),         // Program Memory address
    .pmem_cen          (pmem_cen),          // Program Memory chip enable (low active)
    .pmem_din          (pmem_din),          // Program Memory data input (optional)
    .pmem_wen          (pmem_wen),          // Program Memory write enable (low active) (optional)
    .pmem_dout         (pmem_dout),         // Program Memory data output

    .dmem_addr         (dmem_addr),         // Data Memory address
    .dmem_cen          (dmem_cen),          // Data Memory chip enable (low active)
    .dmem_din          (dmem_din),          // Data Memory data input
    .dmem_wen          (dmem_wen),          // Data Memory write enable (low active)
    .dmem_dout         (dmem_dout),         // Data Memory data output

    .per_addr          (per_addr),          // Peripheral address
    .per_din           (per_din),           // Peripheral data input
    .per_we            (per_we),            // Peripheral write enable (high active)
    .per_en            (per_en),            // Peripheral enable (high active)
    .per_dout          (per_dout),          // Peripheral data output

    .r0                (),
    .r1                (),
    .r2                (),
    .r3                (),
    .r4                (),
    .r5                (),
    .r6                (),
    .r7                (),
    .r8                (),
    .r9                (),
    .r10               (),
    .r11               (),
    .r12               (),
    .r13               (),
    .r14               (),
    .r15               ()
  );

  // Digital I/O
  //----------------------------------

  pu_msp430_gpio gpio (
    // OUTPUTs
    .irq_port1    (irq_port1),         // Port 1 interrupt
    .irq_port2    (irq_port2),         // Port 2 interrupt
    .p1_dout      (p1_dout),           // Port 1 data output
    .p1_dout_en   (p1_dout_en),        // Port 1 data output enable
    .p1_sel       (p1_sel),            // Port 1 function select
    .p2_dout      (p2_dout),           // Port 2 data output
    .p2_dout_en   (p2_dout_en),        // Port 2 data output enable
    .p2_sel       (p2_sel),            // Port 2 function select
    .p3_dout      (p3_dout),           // Port 3 data output
    .p3_dout_en   (p3_dout_en),        // Port 3 data output enable
    .p3_sel       (p3_sel),            // Port 3 function select
    .p4_dout      (p4_dout),           // Port 4 data output
    .p4_dout_en   (p4_dout_en),        // Port 4 data output enable
    .p4_sel       (p4_sel),            // Port 4 function select
    .p5_dout      (p5_dout),           // Port 5 data output
    .p5_dout_en   (p5_dout_en),        // Port 5 data output enable
    .p5_sel       (p5_sel),            // Port 5 function select
    .p6_dout      (p6_dout),           // Port 6 data output
    .p6_dout_en   (p6_dout_en),        // Port 6 data output enable
    .p6_sel       (p6_sel),            // Port 6 function select
    .per_dout     (per_dout_dio),      // Peripheral data output
    .p1dir        (p1dir),
    .p1ifg        (p1ifg),

    // INPUTs
    .mclk         (mclk),              // Main system clock
    .p1_din       (p1_din),            // Port 1 data input
    .p2_din       (p2_din),            // Port 2 data input
    .p3_din       (p3_din),            // Port 3 data input
    .p4_din       (p4_din),            // Port 4 data input
    .p5_din       (p5_din),            // Port 5 data input
    .p6_din       (p6_din),            // Port 6 data input
    .per_addr     (per_addr),          // Peripheral address
    .per_din      (per_din),           // Peripheral data input
    .per_en       (per_en),            // Peripheral enable (high active)
    .per_we       (per_we),            // Peripheral write enable (high active)
    .puc_rst      (puc_rst)            // Main system reset
  );

  // Timers
  //----------------------------------

  pu_msp430_ta ta (
    // OUTPUTs
    .irq_ta0      (irq_ta0),           // Timer A interrupt: TACCR0
    .irq_ta1      (irq_ta1),           // Timer A interrupt: TAIV, TACCR1, TACCR2
    .per_dout     (per_dout_timerA),   // Peripheral data output
    .ta_out0      (ta_out0),           // Timer A output 0
    .ta_out0_en   (ta_out0_en),        // Timer A output 0 enable
    .ta_out1      (ta_out1),           // Timer A output 1
    .ta_out1_en   (ta_out1_en),        // Timer A output 1 enable
    .ta_out2      (ta_out2),           // Timer A output 2
    .ta_out2_en   (ta_out2_en),        // Timer A output 2 enable
    .tar          (tar),
    .taccr0       (taccr0),

    // INPUTs
    .aclk_en      (aclk_en),           // ACLK enable (from CPU)
    .dbg_freeze   (dbg_freeze),        // Freeze Timer A counter
    .inclk        (inclk),             // INCLK external timer clock (SLOW)
    .irq_ta0_acc  (1'b0),              // Interrupt request TACCR0 accepted
    .mclk         (mclk),              // Main system clock
    .per_addr     (per_addr),          // Peripheral address
    .per_din      (per_din),           // Peripheral data input
    .per_en       (per_en),            // Peripheral enable (high active)
    .per_we       (per_we),            // Peripheral write enable (high active)
    .puc_rst      (puc_rst),           // Main system reset
    .smclk_en     (smclk_en),          // SMCLK enable (from CPU)
    .ta_cci0a     (ta_cci0a),          // Timer A compare 0 input A
    .ta_cci0b     (ta_cci0b),          // Timer A compare 0 input B
    .ta_cci1a     (ta_cci1a),          // Timer A compare 1 input A
    .ta_cci1b     (ta_cci1b),          // Timer A compare 1 input B
    .ta_cci2a     (ta_cci2a),          // Timer A compare 2 input A
    .ta_cci2b     (ta_cci2b),          // Timer A compare 2 input B
    .taclk        (taclk)              // TACLK external timer clock (SLOW)
  );

  // Simple full duplex UART (8N1 protocol)
  //----------------------------------------
  pu_msp430_uart uart (
    // OUTPUTs
    .irq_uart_rx  (irq_uart_rx),   // UART receive interrupt
    .irq_uart_tx  (irq_uart_tx),   // UART transmit interrupt
    .per_dout     (per_dout_uart), // Peripheral data output
    .uart_txd     (uart_txd),      // UART Data Transmit (TXD)

    // INPUTs
    .mclk         (mclk),          // Main system clock
    .per_addr     (per_addr),      // Peripheral address
    .per_din      (per_din),       // Peripheral data input
    .per_en       (per_en),        // Peripheral enable (high active)
    .per_we       (per_we),        // Peripheral write enable (high active)
    .puc_rst      (puc_rst),       // Main system reset
    .smclk_en     (smclk_en),      // SMCLK enable (from CPU)
    .uart_rxd     (uart_rxd)       // UART Data Receive (RXD)
  );

  // Peripheral templates
  //----------------------------------

  pu_msp430_template08 template08 (
    // OUTPUTs
    .per_dout     (per_dout_temp_8b),  // Peripheral data output

    // INPUTs
    .mclk         (mclk),              // Main system clock
    .per_addr     (per_addr),          // Peripheral address
    .per_din      (per_din),           // Peripheral data input
    .per_en       (per_en),            // Peripheral enable (high active)
    .per_we       (per_we),            // Peripheral write enable (high active)
    .puc_rst      (puc_rst)            // Main system reset
  );

  pu_msp430_template16 template16 (
    // OUTPUTs
    .per_dout     (per_dout_temp_16b), // Peripheral data output
    .cntrl2_16b   (cntrl2_16b),
    .cntrl4_16b   (cntrl4_16b),

    // INPUTs
    .mclk         (mclk),              // Main system clock
    .per_addr     (per_addr),          // Peripheral address
    .per_din      (per_din),           // Peripheral data input
    .per_en       (per_en),            // Peripheral enable (high active)
    .per_we       (per_we),            // Peripheral write enable (high active)
    .puc_rst      (puc_rst)            // Main system reset
  );

  // Combine peripheral data bus
  //----------------------------------

  assign per_dout = per_dout_dio       |
                    per_dout_timerA    |
                    per_dout_uart      |
                    per_dout_temp_8b   |
                    per_dout_temp_16b;


  // Map peripheral interrupts & wakeups
  //----------------------------------------

  assign irq_in  = irq  | {1'b0,                 // Vector 13  (0xFFFA)
                           1'b0,                 // Vector 12  (0xFFF8)
                           1'b0,                 // Vector 11  (0xFFF6)
                           1'b0,                 // Vector 10  (0xFFF4) - Watchdog -
                           irq_ta0,              // Vector  9  (0xFFF2)
                           irq_ta1,              // Vector  8  (0xFFF0)
                           irq_uart_rx,          // Vector  7  (0xFFEE)
                           irq_uart_tx,          // Vector  6  (0xFFEC)
                           1'b0,                 // Vector  5  (0xFFEA)
                           1'b0,                 // Vector  4  (0xFFE8)
                           irq_port2,            // Vector  3  (0xFFE6)
                           irq_port1,            // Vector  2  (0xFFE4)
                           1'b0,                 // Vector  1  (0xFFE2)
                           {`IRQ_NR-15{1'b0}}};  // Vector  0  (0xFFE0)

  assign wkup_in = wkup | {1'b0,                 // Vector 13  (0xFFFA)
                           1'b0,                 // Vector 12  (0xFFF8)
                           1'b0,                 // Vector 11  (0xFFF6)
                           1'b0,                 // Vector 10  (0xFFF4) - Watchdog -
                           1'b0,                 // Vector  9  (0xFFF2)
                           1'b0,                 // Vector  8  (0xFFF0)
                           1'b0,                 // Vector  7  (0xFFEE)
                           1'b0,                 // Vector  6  (0xFFEC)
                           1'b0,                 // Vector  5  (0xFFEA)
                           1'b0,                 // Vector  4  (0xFFE8)
                           1'b0,                 // Vector  3  (0xFFE6)
                           1'b0,                 // Vector  2  (0xFFE4)
                           1'b0,                 // Vector  1  (0xFFE2)
                           1'b0};                // Vector  0  (0xFFE0)
endmodule
