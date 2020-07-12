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
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the authors nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE
 *
 * =============================================================================
 * Author(s):
 *   Olivier Girard <olgirard@gmail.com>
 *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
 */

//----------------------------------------------------------------------------
// I2C COMMUNICATION CONFIGURATION
//----------------------------------------------------------------------------

// Data rate
parameter I2C_FREQ      = 2000000;
integer   I2C_PERIOD    = 1000000000/I2C_FREQ;

// Address
parameter I2C_ADDR      = 7'h45;
parameter I2C_BROADCAST = 7'h67;

//----------------------------------------------------------------------------
// Generate START / STOP conditions
//----------------------------------------------------------------------------
task dbg_i2c_start;
  begin
    dbg_i2c_string          = "Start";
    dbg_sda_master_out_pre  = 1'b0;
    #(I2C_PERIOD/2);
    dbg_scl_master_pre      = 1'b0;
    #(I2C_PERIOD/4);
    dbg_i2c_string          = "";
  end
endtask

task dbg_i2c_stop;
  begin
    dbg_i2c_string          = "Stop";
    dbg_sda_master_out_pre  = 1'b0;
    #(I2C_PERIOD/4);
    dbg_scl_master_pre      = 1'b1;
    #(I2C_PERIOD/4);
    dbg_sda_master_out_pre  = 1'b1;
    #(I2C_PERIOD/2);
    dbg_i2c_string          = "";
  end
endtask

//----------------------------------------------------------------------------
// Send a byte on the I2C bus
//----------------------------------------------------------------------------
task dbg_i2c_send;
  input  [7:0] txbuf;

  reg [9:0] 	txbuf_full;
  integer 	txcnt;
  begin
    #(1);
    txbuf_full = txbuf;
    for (txcnt = 0; txcnt < 8; txcnt = txcnt + 1) begin
      //$sformat(dbg_i2c_string, "TX_%-d", txcnt);
      dbg_sda_master_out_pre = txbuf_full[7-txcnt];
      #(I2C_PERIOD/4);
      dbg_scl_master_pre     = 1'b1;
      #(I2C_PERIOD/2);
      dbg_scl_master_pre     = 1'b0;
      #(I2C_PERIOD/4);
    end
    dbg_sda_master_out_pre = 1'b1;
    dbg_i2c_string         = "";
  end
endtask

//----------------------------------------------------------------------------
// Read ACK / NACK
//----------------------------------------------------------------------------
task dbg_i2c_ack_rd;
  begin
    dbg_i2c_string      = "ACK (rd)";
    #(I2C_PERIOD/4);
    dbg_scl_master_pre  = 1'b1;
    #(I2C_PERIOD/2);
    dbg_scl_master_pre  = 1'b0;
    #(I2C_PERIOD/4);
    dbg_i2c_string      = "";
  end
endtask

//----------------------------------------------------------------------------
// Read a byte from the I2C bus
//----------------------------------------------------------------------------
task dbg_i2c_receive;
  output [7:0] rxbuf;

  reg [9:0] 	rxbuf_full;
  integer 	rxcnt;
  begin
    #(1);
    rxbuf_full = 0;
    for (rxcnt = 0; rxcnt < 8; rxcnt = rxcnt + 1) begin
      //$sformat(dbg_i2c_string, "RX_%-d", rxcnt);
      #(I2C_PERIOD/4);
      dbg_scl_master_pre  = 1'b1;
      #(I2C_PERIOD/4);
      rxbuf_full[7-rxcnt] = dbg_sda;
      #(I2C_PERIOD/4);
      dbg_scl_master_pre  = 1'b0;
      #(I2C_PERIOD/4);
    end
    dbg_i2c_string      = "";
    rxbuf = rxbuf_full;
  end
endtask

//----------------------------------------------------------------------------
// Write ACK
//----------------------------------------------------------------------------
task dbg_i2c_ack_wr;
  begin
    dbg_i2c_string          = "ACK (wr)";
    dbg_sda_master_out_pre  = 1'b0;
    #(I2C_PERIOD/4);
    dbg_scl_master_pre      = 1'b1;
    #(I2C_PERIOD/2);
    dbg_scl_master_pre      = 1'b0;
    #(I2C_PERIOD/4);
    dbg_sda_master_out_pre  = 1'b1;
    dbg_i2c_string          = "";
  end
endtask

//----------------------------------------------------------------------------
// Write NACK
//----------------------------------------------------------------------------
task dbg_i2c_nack_wr;
  begin
    dbg_i2c_string          = "NACK (wr)";
    dbg_sda_master_out_pre  = 1'b1;
    #(I2C_PERIOD/4);
    dbg_scl_master_pre      = 1'b1;
    #(I2C_PERIOD/2);
    dbg_scl_master_pre      = 1'b0;
    #(I2C_PERIOD/4);
    dbg_sda_master_out_pre  = 1'b1;
    dbg_i2c_string          = "";
  end
endtask

//----------------------------------------------------------------------------
// Start Burst
//----------------------------------------------------------------------------
task dbg_i2c_burst_start;
  input        read;
  begin
    dbg_i2c_start;                     // START
    dbg_i2c_send({I2C_ADDR, read});    // Device Address + Write access
    dbg_i2c_ack_rd;
  end
endtask

//----------------------------------------------------------------------------
// Read 16 bits
//----------------------------------------------------------------------------
task dbg_i2c_rx16;
  input        is_last;

  reg [7:0] 	rxbuf_lo;
  reg [7:0] 	rxbuf_hi;
  begin
    rxbuf_lo = 8'h00;
    rxbuf_hi = 8'h00;

    dbg_i2c_receive(rxbuf_lo);        // Data (low)
    dbg_i2c_ack_wr;
    dbg_i2c_receive(rxbuf_hi);        // Data (high)
    if (is_last) begin
      dbg_i2c_nack_wr;
      dbg_i2c_stop;                   // STOP
    end
    else begin
      dbg_i2c_ack_wr;
    end
    dbg_i2c_buf = {rxbuf_hi, rxbuf_lo};
  end
endtask

//----------------------------------------------------------------------------
// Transmit 16 bits
//----------------------------------------------------------------------------
task dbg_i2c_tx16;
  input [15:0] dbg_data;
  input        is_last;

  begin
    dbg_i2c_send(dbg_data[7:0]);  // write LSB
    dbg_i2c_ack_rd;
    dbg_i2c_send(dbg_data[15:8]); // write MSB
    dbg_i2c_ack_rd;
    if (is_last)
      dbg_i2c_stop;               // STOP CONDITION
  end
endtask

//----------------------------------------------------------------------------
// Read 8 bits
//----------------------------------------------------------------------------
task dbg_i2c_rx8;
  input        is_last;

  reg [7:0] 	rxbuf;
  begin
    rxbuf = 8'h00;

    dbg_i2c_receive(rxbuf);        // Data (low)
    if (is_last) begin
      dbg_i2c_nack_wr;
      dbg_i2c_stop;                // STOP
    end
    else begin
      dbg_i2c_ack_wr;
    end

    dbg_i2c_buf = {8'h00, rxbuf};
  end
endtask

//----------------------------------------------------------------------------
// Transmit 8 bits
//----------------------------------------------------------------------------
task dbg_i2c_tx8;
  input [7:0] dbg_data;
  input       is_last;

  begin
    dbg_i2c_send(dbg_data);  // write LSB
    dbg_i2c_ack_rd;
    if (is_last)
      dbg_i2c_stop;          // STOP CONDITION
  end
endtask

//----------------------------------------------------------------------------
// Write to Debug register
//----------------------------------------------------------------------------
task dbg_i2c_wr;
  input  [7:0] dbg_reg;
  input [15:0] dbg_data;

  begin
    dbg_i2c_start;                     // START
    dbg_i2c_tx8({I2C_ADDR, 1'b0}, 0);  // Device Address + Write access
    dbg_i2c_tx8(DBG_WR | dbg_reg, 0);  // Command

    if (~dbg_reg[6])
      dbg_i2c_tx16(dbg_data,      1);
    else
      dbg_i2c_tx8 (dbg_data[7:0], 1);

  end
endtask

//----------------------------------------------------------------------------
// Read Debug register
//----------------------------------------------------------------------------
task dbg_i2c_rd;
  input  [7:0] dbg_reg;

  reg [7:0] 	rxbuf_lo;
  reg [7:0] 	rxbuf_hi;
  begin
    rxbuf_lo = 8'h00;
    rxbuf_hi = 8'h00;

    dbg_i2c_start;                     // START
    dbg_i2c_tx8({I2C_ADDR, 1'b0}, 0);  // Device Address + Write access
    dbg_i2c_tx8(DBG_RD | dbg_reg, 1);  // Command

    dbg_i2c_start;                     // START
    dbg_i2c_tx8({I2C_ADDR, 1'b1}, 0);  // Device Address + Read access

    if (~dbg_reg[6])
      dbg_i2c_rx16(1);
    else
      dbg_i2c_rx8(1);
  end
endtask

//----------------------------------------------------------------------------
// Build random delay insertion on SCL_MASTER and SDA_MASTER_OUT in order to
// simulate synchronization mechanism
//----------------------------------------------------------------------------

always @(posedge mclk or posedge dbg_rst) begin
  if (dbg_rst) begin
    dbg_sda_master_out_sel <= 1'b0;
    dbg_sda_master_out_dly <= 1'b1;

    dbg_scl_master_sel     <= 1'b0;
    dbg_scl_master_dly     <= 1'b1;
  end
  else if (dbg_en) begin
    dbg_sda_master_out_sel <= dbg_sda_master_out_meta ? $random : 1'b0;
    dbg_sda_master_out_dly <= dbg_sda_master_out_pre;

    dbg_scl_master_sel     <= dbg_scl_master_meta     ? $random : 1'b0;
    dbg_scl_master_dly     <= dbg_scl_master_pre;
  end
end

assign dbg_sda_master_out = dbg_sda_master_out_sel ? dbg_sda_master_out_dly : dbg_sda_master_out_pre;
assign dbg_scl_master     = dbg_scl_master_sel     ? dbg_scl_master_dly     : dbg_scl_master_pre;
