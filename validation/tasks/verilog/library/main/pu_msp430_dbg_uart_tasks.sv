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

// Register B/W and addresses
parameter CPU_ID_LO = (8'h00 | 8'h00);
parameter CPU_ID_HI = (8'h00 | 8'h01);
parameter CPU_CTL = (8'h40 | 8'h02);
parameter CPU_STAT = (8'h40 | 8'h03);
parameter MEM_CTL = (8'h40 | 8'h04);
parameter MEM_ADDR = (8'h00 | 8'h05);
parameter MEM_DATA = (8'h00 | 8'h06);
parameter MEM_CNT = (8'h00 | 8'h07);
parameter BRK0_CTL = (8'h40 | 8'h08);
parameter BRK0_STAT = (8'h40 | 8'h09);
parameter BRK0_ADDR0 = (8'h00 | 8'h0A);
parameter BRK0_ADDR1 = (8'h00 | 8'h0B);
parameter BRK1_CTL = (8'h40 | 8'h0C);
parameter BRK1_STAT = (8'h40 | 8'h0D);
parameter BRK1_ADDR0 = (8'h00 | 8'h0E);
parameter BRK1_ADDR1 = (8'h00 | 8'h0F);
parameter BRK2_CTL = (8'h40 | 8'h10);
parameter BRK2_STAT = (8'h40 | 8'h11);
parameter BRK2_ADDR0 = (8'h00 | 8'h12);
parameter BRK2_ADDR1 = (8'h00 | 8'h13);
parameter BRK3_CTL = (8'h40 | 8'h14);
parameter BRK3_STAT = (8'h40 | 8'h15);
parameter BRK3_ADDR0 = (8'h00 | 8'h16);
parameter BRK3_ADDR1 = (8'h00 | 8'h17);
parameter CPU_NR = (8'h00 | 8'h18);

// Read / Write commands
parameter DBG_WR = 8'h80;
parameter DBG_RD = 8'h00;

// Synchronization value
parameter DBG_SYNC = 8'h80;

// UART COMMUNICATION DATA RATE CONFIGURATION
// If the auto synchronization mode is set, then the communication speed
// is configured by the testbench.
// If not, the values from the openMSP430.inc file are taken over.
`ifdef DBG_UART_AUTO_SYNC
parameter UART_BAUD = 4000000;
integer UART_PERIOD = 1000000000 / UART_BAUD;
`else
integer UART_PERIOD = `DBG_UART_CNT;
`endif

// Receive UART frame from CPU Debug interface (8N1)

task dbg_uart_rx;
  output [7:0] dbg_rxbuf;

  reg     [7:0] dbg_rxbuf;
  reg     [7:0] rxbuf;
  integer       rxcnt;
  begin
    #(1);
    dbg_uart_rx_busy = 1'b1;
    @(negedge dbg_uart_txd);
    dbg_rxbuf = 0;
    rxbuf     = 0;
    #(3 * UART_PERIOD / 2);
    for (rxcnt = 0; rxcnt < 8; rxcnt = rxcnt + 1) begin
      rxbuf = {dbg_uart_txd, rxbuf[7:1]};
      #(UART_PERIOD);
    end
    dbg_rxbuf        = rxbuf;
    dbg_uart_rx_busy = 1'b0;
  end
endtask

task dbg_uart_rx16;
  reg [7:0] rxbuf_lo;
  reg [7:0] rxbuf_hi;
  begin
    rxbuf_lo = 8'h00;
    rxbuf_hi = 8'h00;
    dbg_uart_rx(rxbuf_lo);
    dbg_uart_rx(rxbuf_hi);
    dbg_uart_buf = {rxbuf_hi, rxbuf_lo};
  end
endtask

task dbg_uart_rx8;
  reg [7:0] rxbuf;
  begin
    rxbuf = 8'h00;
    dbg_uart_rx(rxbuf);
    dbg_uart_buf = {8'h00, rxbuf};
  end
endtask

// Transmit UART frame to CPU Debug interface (8N1)
task dbg_uart_tx;
  input [7:0] txbuf;

  reg     [9:0] txbuf_full;
  integer       txcnt;
  begin
    #(1);
    dbg_uart_tx_busy = 1'b1;
    dbg_uart_rxd_pre = 1'b1;
    txbuf_full       = {1'b1, txbuf, 1'b0};
    for (txcnt = 0; txcnt < 10; txcnt = txcnt + 1) begin
      #(UART_PERIOD);
      dbg_uart_rxd_pre = txbuf_full[txcnt];
    end
    dbg_uart_tx_busy = 1'b0;
  end
endtask

task dbg_uart_tx16;
  input [15:0] txbuf;

  begin
    dbg_uart_tx(txbuf[7:0]);
    dbg_uart_tx(txbuf[15:8]);
  end
endtask

always @(posedge mclk or posedge dbg_rst) begin
  if (dbg_rst) begin
    dbg_uart_rxd_sel <= 1'b0;
    dbg_uart_rxd_dly <= 1'b1;
  end else if (dbg_en) begin
    dbg_uart_rxd_sel <= dbg_uart_rxd_meta ? $random : 1'b0;
    dbg_uart_rxd_dly <= dbg_uart_rxd_pre;
  end
end

assign dbg_uart_rxd = dbg_uart_rxd_sel ? dbg_uart_rxd_dly : dbg_uart_rxd_pre;

// Write to Debug register
task dbg_uart_wr;
  input [7:0] dbg_reg;
  input [15:0] dbg_data;

  begin
    dbg_uart_tx(DBG_WR | dbg_reg);
    dbg_uart_tx(dbg_data[7:0]);
    if (~dbg_reg[6]) begin
      dbg_uart_tx(dbg_data[15:8]);
    end
  end
endtask

// Read Debug register
task dbg_uart_rd;
  input [7:0] dbg_reg;

  reg [7:0] rxbuf_lo;
  reg [7:0] rxbuf_hi;
  begin
    rxbuf_lo = 8'h00;
    rxbuf_hi = 8'h00;
    dbg_uart_tx(DBG_RD | dbg_reg);
    dbg_uart_rx(rxbuf_lo);
    if (~dbg_reg[6]) begin
      dbg_uart_rx(rxbuf_hi);
    end

    dbg_uart_buf = {rxbuf_hi, rxbuf_lo};
  end
endtask

// Send synchronization frame
task dbg_uart_sync;
  begin
    dbg_uart_tx(DBG_SYNC);
    repeat (10) @(posedge mclk);
  end
endtask