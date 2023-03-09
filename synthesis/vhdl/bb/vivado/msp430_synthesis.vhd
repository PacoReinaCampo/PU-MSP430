-- Converted from msp430_synthesis.sv
-- by verilog2vhdl - QueenField

--------------------------------------------------------------------------------
--                                            __ _      _     _               --
--                                           / _(_)    | |   | |              --
--                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              --
--               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              --
--              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              --
--               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              --
--                  | |                                                       --
--                  |_|                                                       --
--                                                                            --
--                                                                            --
--              MSP430 CPU                                                    --
--              Processing Unit                                               --
--                                                                            --
--------------------------------------------------------------------------------

-- Copyright (c) 2015-2016 by the author(s)
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the authors nor the names of its contributors
--       may be used to endorse or promote products derived from this software
--       without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
-- OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
-- THE POSSIBILITY OF SUCH DAMAGE
--
--------------------------------------------------------------------------------
-- Author(s):
--   Olivier Girard <olgirard@gmail.com>
--   Paco Reina Campo <pacoreinacampo@queenfield.tech>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.msp430_pkg.all;

entity msp430_synthesis is
  generic (
    AW : integer := 16;
    DW : integer := 16;

    -- Current oMSP instance number (for multicore systems)
    INST_NR : std_logic_vector(7 downto 0) := X"00";

    -- Total number of oMSP instances-1 (for multicore systems)
    TOTAL_NR : std_logic_vector(7 downto 0) := X"00"
    );
  port (
    ir      : out std_logic_vector(DW-1 downto 0);
    cpu_en  : in  std_logic;  -- Enable CPU code execution (asynchronous and non-glitchy)
    irq     : in  std_logic_vector(IRQ_NR-3 downto 0);  -- Maskable interrupts (14, 30 or 62)
    nmi     : in  std_logic;  -- Non-maskable interrupt (asynchronous and non-glitchy)
    reset_n : in  std_logic;  -- Reset Pin (active low, asynchronous and non-glitchy)

    aclk_en  : out std_logic;           -- FPGA ONLY: ACLK enable
    smclk_en : out std_logic;           -- FPGA ONLY: SMCLK enable

    aclk        : out std_logic;        -- ASIC ONLY: ACLK
    lfxt_enable : out std_logic;  -- ASIC ONLY: Low frequency oscillator enable
    lfxt_wkup   : out std_logic;  -- ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    smclk       : out std_logic;        -- ASIC ONLY: SMCLK
    scan_enable : in  std_logic;  -- ASIC ONLY: Scan enable (active during scan shifting)
    scan_mode   : in  std_logic;        -- ASIC ONLY: Scan mode
    wkup        : in  std_logic;  -- ASIC ONLY: System Wake-up (asynchronous and non-glitchy)

    dco_enable : out std_logic;         -- ASIC ONLY: Fast oscillator enable
    dco_wkup   : out std_logic;  -- ASIC ONLY: Fast oscillator wake-up (asynchronous)
    dco_clk    : in  std_logic;         -- Fast oscillator (fast clock)

    dbg_clk           : out std_logic;
    dbg_rst           : out std_logic;
    dbg_freeze        : out std_logic;  -- Freeze peripherals
    dbg_i2c_sda_out   : out std_logic;  -- Debug interface: I2C SDA OUT
    dbg_uart_txd      : out std_logic;  -- Debug interface: UART TXD
    dbg_en            : in  std_logic;  -- Debug interface enable (asynchronous and non-glitchy)
    dbg_i2c_addr      : in  std_logic_vector(6 downto 0);  -- Debug interface: I2C Address
    dbg_i2c_broadcast : in  std_logic_vector(6 downto 0);  -- Debug interface: I2C Broadcast Address (for multicore systems)
    dbg_i2c_scl       : in  std_logic;  -- Debug interface: I2C SCL
    dbg_i2c_sda_in    : in  std_logic;  -- Debug interface: I2C SDA IN
    dbg_uart_rxd      : in  std_logic  -- Debug interface: UART RXD (asynchronous)
    );
end msp430_synthesis;

architecture rtl of msp430_synthesis is

  ------------------------------------------------------------------------------
  -- Components
  ------------------------------------------------------------------------------

  component msp430_ram
    generic (
      ADDR_MSB : integer := 6;                       -- MSB of the address bus
      MEM_SIZE : integer := 256);                    -- Memory size in bytes
    port (
      -- OUTPUTs
      ram_dout : out std_logic_vector(15 downto 0);  -- RAM data output

      -- INPUTs
      ram_addr : in std_logic_vector(ADDR_MSB downto 0);  -- RAM address
      ram_cen  : in std_logic;          -- RAM chip enable (low active)
      ram_clk  : in std_logic;          -- RAM clock
      ram_din  : in std_logic_vector(15 downto 0);  -- RAM data input
      ram_wen  : in std_logic_vector(1 downto 0));  -- RAM write enable (low active)
  end component;

  component msp430_core
    port (
      --FRONTEND - SCAN
      scan_enable : in std_logic;
      scan_mode   : in std_logic;

      --FRONTEND - INTERRUPTION
      irq_acc : out std_logic_vector (IRQ_NR - 3 downto 0);
      nmi     : in  std_logic;
      irq     : in  std_logic_vector (IRQ_NR - 3 downto 0);

      --FRONTEND - RESET
      puc_rst : out std_logic;
      reset_n : in  std_logic;

      --DATA MEMORY
      dmem_cen  : out std_logic;
      dmem_wen  : out std_logic_vector (1 downto 0);
      dmem_din  : out std_logic_vector (15 downto 0);
      dmem_addr : out std_logic_vector (DMEM_MSB downto 0);
      dmem_dout : in  std_logic_vector (15 downto 0);

      --INSTRUCTION MEMORY
      pmem_cen  : out std_logic;
      pmem_wen  : out std_logic_vector (1 downto 0);
      pmem_din  : out std_logic_vector (15 downto 0);
      pmem_addr : out std_logic_vector (PMEM_MSB downto 0);
      pmem_dout : in  std_logic_vector (15 downto 0);

      --PERIPHERAL MEMORY
      per_en   : out std_logic;
      per_we   : out std_logic_vector (1 downto 0);
      per_addr : out std_logic_vector (13 downto 0);
      per_din  : out std_logic_vector (15 downto 0);
      per_dout : in  std_logic_vector (15 downto 0);

      --EXECUTION - REGISTERS
      r0  : out std_logic_vector (15 downto 0);
      r1  : out std_logic_vector (15 downto 0);
      r2  : out std_logic_vector (15 downto 0);
      r3  : out std_logic_vector (15 downto 0);
      r4  : out std_logic_vector (15 downto 0);
      r5  : out std_logic_vector (15 downto 0);
      r6  : out std_logic_vector (15 downto 0);
      r7  : out std_logic_vector (15 downto 0);
      r8  : out std_logic_vector (15 downto 0);
      r9  : out std_logic_vector (15 downto 0);
      r10 : out std_logic_vector (15 downto 0);
      r11 : out std_logic_vector (15 downto 0);
      r12 : out std_logic_vector (15 downto 0);
      r13 : out std_logic_vector (15 downto 0);
      r14 : out std_logic_vector (15 downto 0);
      r15 : out std_logic_vector (15 downto 0);

      dbg_clk    : out std_logic;
      dbg_rst    : out std_logic;
      irq_detect : out std_logic;
      nmi_detect : out std_logic;

      i_state : out std_logic_vector (2 downto 0);
      e_state : out std_logic_vector (3 downto 0);
      decode  : out std_logic;
      ir      : out std_logic_vector (15 downto 0);
      irq_num : out std_logic_vector (5 downto 0);
      pc      : out std_logic_vector (15 downto 0);

      nodiv_smclk : out std_logic;

      --DBG
      dbg_freeze : out std_logic;
      dbg_en     : in  std_logic;

      --DBG - I2C
      dbg_i2c_sda_out   : out std_logic;
      dbg_i2c_scl       : in  std_logic;
      dbg_i2c_sda_in    : in  std_logic;
      dbg_i2c_addr      : in  std_logic_vector (6 downto 0);
      dbg_i2c_broadcast : in  std_logic_vector (6 downto 0);

      --DBG - UART
      dbg_uart_txd : out std_logic;
      dbg_uart_rxd : in  std_logic;

      --BCM
      aclk        : out std_logic;
      aclk_en     : out std_logic;
      dco_enable  : out std_logic;
      dco_wkup    : out std_logic;
      lfxt_enable : out std_logic;
      lfxt_wkup   : out std_logic;
      mclk        : out std_logic;
      smclk       : out std_logic;
      smclk_en    : out std_logic;
      cpu_en      : in  std_logic;
      dco_clk     : in  std_logic;
      lfxt_clk    : in  std_logic;
      wkup        : in  std_logic);
  end component;

  component msp430_gpio
    port (
      p1_dout : out std_logic_vector (7 downto 0);
      p2_dout : out std_logic_vector (7 downto 0);
      p3_dout : out std_logic_vector (7 downto 0);
      p4_dout : out std_logic_vector (7 downto 0);
      p5_dout : out std_logic_vector (7 downto 0);
      p6_dout : out std_logic_vector (7 downto 0);

      p1_dout_en : out std_logic_vector (7 downto 0);
      p2_dout_en : out std_logic_vector (7 downto 0);
      p3_dout_en : out std_logic_vector (7 downto 0);
      p4_dout_en : out std_logic_vector (7 downto 0);
      p5_dout_en : out std_logic_vector (7 downto 0);
      p6_dout_en : out std_logic_vector (7 downto 0);

      p1_sel : out std_logic_vector (7 downto 0);
      p2_sel : out std_logic_vector (7 downto 0);
      p3_sel : out std_logic_vector (7 downto 0);
      p4_sel : out std_logic_vector (7 downto 0);
      p5_sel : out std_logic_vector (7 downto 0);
      p6_sel : out std_logic_vector (7 downto 0);

      p1dir : out std_logic_vector (7 downto 0);
      p1ifg : out std_logic_vector (7 downto 0);

      p1_din : in std_logic_vector (7 downto 0);
      p2_din : in std_logic_vector (7 downto 0);
      p3_din : in std_logic_vector (7 downto 0);
      p4_din : in std_logic_vector (7 downto 0);
      p5_din : in std_logic_vector (7 downto 0);
      p6_din : in std_logic_vector (7 downto 0);

      irq_port1 : out std_logic;
      irq_port2 : out std_logic;

      per_dout : out std_logic_vector (15 downto 0);
      mclk     : in  std_logic;
      per_en   : in  std_logic;
      puc_rst  : in  std_logic;
      per_we   : in  std_logic_vector (1 downto 0);
      per_addr : in  std_logic_vector (13 downto 0);
      per_din  : in  std_logic_vector (15 downto 0));
  end component;

  component msp430_ta
    port (
      -- OUTPUTs
      irq_ta0    : out std_logic;       -- Timer A interrupt: TACCR0
      irq_ta1    : out std_logic;  -- Timer A interrupt: TAIV, TACCR1, TACCR2
      per_dout   : out std_logic_vector(15 downto 0);  -- Peripheral data output
      ta_out0    : out std_logic;       -- Timer A output 0
      ta_out0_en : out std_logic;       -- Timer A output 0 enable
      ta_out1    : out std_logic;       -- Timer A output 1
      ta_out1_en : out std_logic;       -- Timer A output 1 enable
      ta_out2    : out std_logic;       -- Timer A output 2
      ta_out2_en : out std_logic;       -- Timer A output 2 enable
      tar        : out std_logic_vector(15 downto 0);
      taccr0     : out std_logic_vector(15 downto 0);

      -- INPUTs
      aclk_en     : in std_logic;       -- ACLK enable (from CPU)
      dbg_freeze  : in std_logic;       -- Freeze Timer A counter
      inclk       : in std_logic;       -- INCLK external timer clock (SLOW)
      irq_ta0_acc : in std_logic;       -- Interrupt request TACCR0 accepted
      mclk        : in std_logic;       -- Main system clock
      per_addr    : in std_logic_vector(13 downto 0);  -- Peripheral address
      per_din     : in std_logic_vector(15 downto 0);  -- Peripheral data input
      per_en      : in std_logic;       -- Peripheral enable (high active)
      per_we      : in std_logic_vector(1 downto 0);  -- Peripheral write enable (high active)
      puc_rst     : in std_logic;       -- Main system reset
      smclk_en    : in std_logic;       -- SMCLK enable (from CPU)
      ta_cci0a    : in std_logic;       -- Timer A capture 0 input A
      ta_cci0b    : in std_logic;       -- Timer A capture 0 input B
      ta_cci1a    : in std_logic;       -- Timer A capture 1 input A
      ta_cci1b    : in std_logic;       -- Timer A capture 1 input B
      ta_cci2a    : in std_logic;       -- Timer A capture 2 input A
      ta_cci2b    : in std_logic;       -- Timer A capture 2 input B
      taclk       : in std_logic);      -- TACLK external timer clock (SLOW)
  end component;

  component msp430_uart
    port (
      uart_txd : out std_logic;
      uart_rxd : in  std_logic;
      smclk_en : in  std_logic;

      irq_uart_rx : out std_logic;
      irq_uart_tx : out std_logic;

      per_dout : out std_logic_vector (15 downto 0);
      mclk     : in  std_logic;
      per_en   : in  std_logic;
      puc_rst  : in  std_logic;
      per_we   : in  std_logic_vector (1 downto 0);
      per_addr : in  std_logic_vector (13 downto 0);
      per_din  : in  std_logic_vector (15 downto 0));
  end component;

  component msp430_template08
    port (
      per_dout : out std_logic_vector (15 downto 0);

      mclk     : in std_logic;
      per_en   : in std_logic;
      puc_rst  : in std_logic;
      per_we   : in std_logic_vector (1 downto 0);
      per_addr : in std_logic_vector (13 downto 0);
      per_din  : in std_logic_vector (15 downto 0));
  end component;

  component msp430_template16
    port (
      per_dout   : out std_logic_vector (15 downto 0);
      cntrl2_16b : out std_logic_vector (15 downto 0);
      cntrl4_16b : out std_logic_vector (15 downto 0);

      mclk     : in std_logic;
      per_en   : in std_logic;
      puc_rst  : in std_logic;
      per_we   : in std_logic_vector (1 downto 0);
      per_addr : in std_logic_vector (13 downto 0);
      per_din  : in std_logic_vector (15 downto 0));
  end component;

  signal mclk    : std_logic;
  signal puc_rst : std_logic;

  signal irq_in  : std_logic_vector(IRQ_NR - 3 downto 0);
  signal wkup_in : std_logic_vector(13 downto 0);

  -- Data Memory interface
  signal dmem_addr : std_logic_vector(DMEM_MSB downto 0);
  signal dmem_cen  : std_logic;
  signal dmem_din  : std_logic_vector(15 downto 0);
  signal dmem_wen  : std_logic_vector(1 downto 0);
  signal dmem_dout : std_logic_vector(15 downto 0);

  -- Program Memory interface
  signal pmem_addr : std_logic_vector(PMEM_MSB downto 0);
  signal pmem_cen  : std_logic;
  signal pmem_din  : std_logic_vector(15 downto 0);
  signal pmem_wen  : std_logic_vector(1 downto 0);
  signal pmem_dout : std_logic_vector(15 downto 0);

  -- Peripherals interface
  signal per_addr : std_logic_vector(13 downto 0);
  signal per_din  : std_logic_vector(15 downto 0);
  signal per_dout : std_logic_vector(15 downto 0);
  signal per_we   : std_logic_vector(1 downto 0);
  signal per_en   : std_logic;

  -- Digital I/O
  signal irq_port1    : std_logic;
  signal irq_port2    : std_logic;
  signal per_dout_dio : std_logic_vector(15 downto 0);
  signal p1_dout      : std_logic_vector(7 downto 0);
  signal p1_dout_en   : std_logic_vector(7 downto 0);
  signal p1_sel       : std_logic_vector(7 downto 0);
  signal p2_dout      : std_logic_vector(7 downto 0);
  signal p2_dout_en   : std_logic_vector(7 downto 0);
  signal p2_sel       : std_logic_vector(7 downto 0);
  signal p3_dout      : std_logic_vector(7 downto 0);
  signal p3_dout_en   : std_logic_vector(7 downto 0);
  signal p3_sel       : std_logic_vector(7 downto 0);
  signal p4_dout      : std_logic_vector(7 downto 0);
  signal p4_dout_en   : std_logic_vector(7 downto 0);
  signal p4_sel       : std_logic_vector(7 downto 0);
  signal p5_dout      : std_logic_vector(7 downto 0);
  signal p5_dout_en   : std_logic_vector(7 downto 0);
  signal p5_sel       : std_logic_vector(7 downto 0);
  signal p6_dout      : std_logic_vector(7 downto 0);
  signal p6_dout_en   : std_logic_vector(7 downto 0);
  signal p6_sel       : std_logic_vector(7 downto 0);
  signal p1_din       : std_logic_vector(7 downto 0);
  signal p2_din       : std_logic_vector(7 downto 0);
  signal p3_din       : std_logic_vector(7 downto 0);
  signal p4_din       : std_logic_vector(7 downto 0);
  signal p5_din       : std_logic_vector(7 downto 0);
  signal p6_din       : std_logic_vector(7 downto 0);
  signal p1dir        : std_logic_vector(7 downto 0);
  signal p1ifg        : std_logic_vector(7 downto 0);

  -- Peripheral templates
  signal per_dout_temp_8b  : std_logic_vector(15 downto 0);
  signal per_dout_temp_16b : std_logic_vector(15 downto 0);
  signal cntrl2_16b        : std_logic_vector(15 downto 0);
  signal cntrl4_16b        : std_logic_vector(15 downto 0);

  -- Simple full duplex UART
  signal per_dout_uart : std_logic_vector(15 downto 0);
  signal irq_uart_rx   : std_logic;
  signal irq_uart_tx   : std_logic;
  signal uart_txd      : std_logic;
  signal uart_rxd      : std_logic;

  -- Timer A
  signal irq_ta0         : std_logic;
  signal irq_ta1         : std_logic;
  signal per_dout_timerA : std_logic_vector(15 downto 0);
  signal inclk           : std_logic;
  signal taclk           : std_logic;
  signal ta_cci0a        : std_logic;
  signal ta_cci0b        : std_logic;
  signal ta_cci1a        : std_logic;
  signal ta_cci1b        : std_logic;
  signal ta_cci2a        : std_logic;
  signal ta_cci2b        : std_logic;
  signal ta_out0         : std_logic;
  signal ta_out0_en      : std_logic;
  signal ta_out1         : std_logic;
  signal ta_out1_en      : std_logic;
  signal ta_out2         : std_logic;
  signal ta_out2_en      : std_logic;
  signal tar             : std_logic_vector(15 downto 0);
  signal taccr0          : std_logic_vector(15 downto 0);

begin

  --
  -- Program Memory
  ------------------------------------

  pmem_0 : msp430_ram
    generic map (
      ADDR_MSB => PMEM_MSB,
      MEM_SIZE => PMEM_SIZE
      )
    port map (
      -- OUTPUTs
      ram_dout => pmem_dout,            -- Program Memory data output

      -- INPUTs
      ram_addr => pmem_addr,            -- Program Memory address
      ram_cen  => pmem_cen,   -- Program Memory chip enable (low active)
      ram_clk  => mclk,                 -- Program Memory clock
      ram_din  => pmem_din,             -- Program Memory data input
      ram_wen  => pmem_wen    -- Program Memory write enable (low active)
      );

  --
  -- Data Memory
  ------------------------------------

  dmem_0 : msp430_ram
    generic map (
      ADDR_MSB => DMEM_MSB,
      MEM_SIZE => DMEM_SIZE
      )
    port map (
      -- OUTPUTs
      ram_dout => dmem_dout,            -- Data Memory data output

      -- INPUTs
      ram_addr => dmem_addr,            -- Data Memory address
      ram_cen  => dmem_cen,             -- Data Memory chip enable (low active)
      ram_clk  => mclk,                 -- Data Memory clock
      ram_din  => dmem_din,             -- Data Memory data input
      ram_wen  => dmem_wen    -- Data Memory write enable (low active)
      );

  --
  -- openMSP430 Instance
  ------------------------------------

  dut : msp430_core
    port map (
      irq_detect  => open,
      nmi_detect  => open,
      i_state     => open,
      e_state     => open,
      decode      => open,
      ir          => ir,
      irq_num     => open,
      pc          => open,
      nodiv_smclk => open,
      irq_acc     => open,     -- Interrupt request accepted (one-hot signal)
      mclk        => open,              -- Main system clock
      puc_rst     => open,              -- Main system reset
      cpu_en      => cpu_en,   -- Enable CPU code execution (asynchronous)
      irq         => irq,               -- Maskable interrupts
      lfxt_clk    => '0',               -- Low frequency oscillator (typ 32kHz)
      nmi         => nmi,      -- Non-maskable interrupt (asynchronous)
      reset_n     => reset_n,           -- Reset Pin (low active, asynchronous)

      aclk_en  => aclk_en,              -- FPGA ONLY: ACLK enable
      smclk_en => smclk_en,             -- FPGA ONLY: SMCLK enable

      aclk        => aclk,              -- ASIC ONLY: ACLK
      lfxt_enable => lfxt_enable,  -- ASIC ONLY: Low frequency oscillator enable
      lfxt_wkup   => lfxt_wkup,  -- ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
      smclk       => smclk,             -- ASIC ONLY: SMCLK
      scan_enable => scan_enable,  -- ASIC ONLY: Scan enable (active during scan shifting)
      scan_mode   => scan_mode,         -- ASIC ONLY: Scan mode
      wkup        => or wkup_in,   -- ASIC ONLY: System Wake-up (asynchronous)

      dco_enable => dco_enable,         -- ASIC ONLY: Fast oscillator enable
      dco_wkup   => dco_wkup,  -- ASIC ONLY: Fast oscillator wake-up (asynchronous)
      dco_clk    => dco_clk,            -- Fast oscillator (fast clock)

      dbg_clk           => dbg_clk,
      dbg_rst           => dbg_rst,
      dbg_freeze        => dbg_freeze,  -- Freeze peripherals
      dbg_i2c_sda_out   => dbg_i2c_sda_out,    -- Debug interface: I2C SDA OUT
      dbg_uart_txd      => dbg_uart_txd,  -- Debug interface: UART TXD
      dbg_en            => dbg_en,  -- Debug interface enable (asynchronous)
      dbg_i2c_addr      => dbg_i2c_addr,  -- Debug interface: I2C Address
      dbg_i2c_broadcast => dbg_i2c_broadcast,  -- Debug interface: I2C Broadcast Address (for multicore systems)
      dbg_i2c_scl       => dbg_i2c_scl,   -- Debug interface: I2C SCL
      dbg_i2c_sda_in    => dbg_i2c_sda_in,     -- Debug interface: I2C SDA IN
      dbg_uart_rxd      => dbg_uart_rxd,  -- Debug interface: UART RXD (asynchronous)

      pmem_addr => pmem_addr,           -- Program Memory address
      pmem_cen  => pmem_cen,  -- Program Memory chip enable (low active)
      pmem_din  => pmem_din,            -- Program Memory data input (optional)
      pmem_wen  => pmem_wen,  -- Program Memory write enable (low active) (optional)
      pmem_dout => pmem_dout,           -- Program Memory data output

      dmem_addr => dmem_addr,           -- Data Memory address
      dmem_cen  => dmem_cen,            -- Data Memory chip enable (low active)
      dmem_din  => dmem_din,            -- Data Memory data input
      dmem_wen  => dmem_wen,   -- Data Memory write enable (low active)
      dmem_dout => dmem_dout,           -- Data Memory data output

      per_addr => per_addr,             -- Peripheral address
      per_din  => per_din,              -- Peripheral data input
      per_we   => per_we,    -- Peripheral write enable (high active)
      per_en   => per_en,               -- Peripheral enable (high active)
      per_dout => per_dout,             -- Peripheral data output

      r0  => open,
      r1  => open,
      r2  => open,
      r3  => open,
      r4  => open,
      r5  => open,
      r6  => open,
      r7  => open,
      r8  => open,
      r9  => open,
      r10 => open,
      r11 => open,
      r12 => open,
      r13 => open,
      r14 => open,
      r15 => open
      );

  --
  -- Digital I/O
  ------------------------------------

  gpio : msp430_gpio
    port map (
      -- OUTPUTs
      irq_port1  => irq_port1,          -- Port 1 interrupt
      irq_port2  => irq_port2,          -- Port 2 interrupt
      p1_dout    => p1_dout,            -- Port 1 data output
      p1_dout_en => p1_dout_en,         -- Port 1 data output enable
      p1_sel     => p1_sel,             -- Port 1 function select
      p2_dout    => p2_dout,            -- Port 2 data output
      p2_dout_en => p2_dout_en,         -- Port 2 data output enable
      p2_sel     => p2_sel,             -- Port 2 function select
      p3_dout    => p3_dout,            -- Port 3 data output
      p3_dout_en => p3_dout_en,         -- Port 3 data output enable
      p3_sel     => p3_sel,             -- Port 3 function select
      p4_dout    => p4_dout,            -- Port 4 data output
      p4_dout_en => p4_dout_en,         -- Port 4 data output enable
      p4_sel     => p4_sel,             -- Port 4 function select
      p5_dout    => p5_dout,            -- Port 5 data output
      p5_dout_en => p5_dout_en,         -- Port 5 data output enable
      p5_sel     => p5_sel,             -- Port 5 function select
      p6_dout    => p6_dout,            -- Port 6 data output
      p6_dout_en => p6_dout_en,         -- Port 6 data output enable
      p6_sel     => p6_sel,             -- Port 6 function select
      per_dout   => per_dout_dio,       -- Peripheral data output
      p1dir      => p1dir,
      p1ifg      => p1ifg,

      -- INPUTs
      mclk     => mclk,                 -- Main system clock
      p1_din   => p1_din,               -- Port 1 data input
      p2_din   => p2_din,               -- Port 2 data input
      p3_din   => p3_din,               -- Port 3 data input
      p4_din   => p4_din,               -- Port 4 data input
      p5_din   => p5_din,               -- Port 5 data input
      p6_din   => p6_din,               -- Port 6 data input
      per_addr => per_addr,             -- Peripheral address
      per_din  => per_din,              -- Peripheral data input
      per_en   => per_en,               -- Peripheral enable (high active)
      per_we   => per_we,    -- Peripheral write enable (high active)
      puc_rst  => puc_rst               -- Main system reset
      );

  --
  -- Timers
  ------------------------------------

  ta : msp430_ta
    port map (
      -- OUTPUTs
      irq_ta0    => irq_ta0,            -- Timer A interrupt: TACCR0
      irq_ta1    => irq_ta1,  -- Timer A interrupt: TAIV, TACCR1, TACCR2
      per_dout   => per_dout_timerA,    -- Peripheral data output
      ta_out0    => ta_out0,            -- Timer A output 0
      ta_out0_en => ta_out0_en,         -- Timer A output 0 enable
      ta_out1    => ta_out1,            -- Timer A output 1
      ta_out1_en => ta_out1_en,         -- Timer A output 1 enable
      ta_out2    => ta_out2,            -- Timer A output 2
      ta_out2_en => ta_out2_en,         -- Timer A output 2 enable
      tar        => tar,
      taccr0     => taccr0,

      -- INPUTs
      aclk_en     => aclk_en,           -- ACLK enable (from CPU)
      dbg_freeze  => dbg_freeze,        -- Freeze Timer A counter
      inclk       => inclk,             -- INCLK external timer clock (SLOW)
      irq_ta0_acc => '0',               -- Interrupt request TACCR0 accepted
      mclk        => mclk,              -- Main system clock
      per_addr    => per_addr,          -- Peripheral address
      per_din     => per_din,           -- Peripheral data input
      per_en      => per_en,            -- Peripheral enable (high active)
      per_we      => per_we,      -- Peripheral write enable (high active)
      puc_rst     => puc_rst,           -- Main system reset
      smclk_en    => smclk_en,          -- SMCLK enable (from CPU)
      ta_cci0a    => ta_cci0a,          -- Timer A compare 0 input A
      ta_cci0b    => ta_cci0b,          -- Timer A compare 0 input B
      ta_cci1a    => ta_cci1a,          -- Timer A compare 1 input A
      ta_cci1b    => ta_cci1b,          -- Timer A compare 1 input B
      ta_cci2a    => ta_cci2a,          -- Timer A compare 2 input A
      ta_cci2b    => ta_cci2b,          -- Timer A compare 2 input B
      taclk       => taclk              -- TACLK external timer clock (SLOW)
      );

  --
  -- Simple full duplex UART (8N1 protocol)
  ------------------------------------------
  uart : msp430_uart
    port map (
      -- OUTPUTs
      irq_uart_rx => irq_uart_rx,       -- UART receive interrupt
      irq_uart_tx => irq_uart_tx,       -- UART transmit interrupt
      per_dout    => per_dout_uart,     -- Peripheral data output
      uart_txd    => uart_txd,          -- UART Data Transmit (TXD)

      -- INPUTs
      mclk     => mclk,                 -- Main system clock
      per_addr => per_addr,             -- Peripheral address
      per_din  => per_din,              -- Peripheral data input
      per_en   => per_en,               -- Peripheral enable (high active)
      per_we   => per_we,    -- Peripheral write enable (high active)
      puc_rst  => puc_rst,              -- Main system reset
      smclk_en => smclk_en,             -- SMCLK enable (from CPU)
      uart_rxd => uart_rxd              -- UART Data Receive (RXD)
      );

  --
  -- Peripheral templates
  ------------------------------------

  template08 : msp430_template08
    port map (
      -- OUTPUTs
      per_dout => per_dout_temp_8b,     -- Peripheral data output

      -- INPUTs
      mclk     => mclk,                 -- Main system clock
      per_addr => per_addr,             -- Peripheral address
      per_din  => per_din,              -- Peripheral data input
      per_en   => per_en,               -- Peripheral enable (high active)
      per_we   => per_we,    -- Peripheral write enable (high active)
      puc_rst  => puc_rst               -- Main system reset
      );

  template16 : msp430_template16
    port map (
      -- OUTPUTs
      per_dout   => per_dout_temp_16b,  -- Peripheral data output
      cntrl2_16b => cntrl2_16b,
      cntrl4_16b => cntrl4_16b,

      -- INPUTs
      mclk     => mclk,                 -- Main system clock
      per_addr => per_addr,             -- Peripheral address
      per_din  => per_din,              -- Peripheral data input
      per_en   => per_en,               -- Peripheral enable (high active)
      per_we   => per_we,    -- Peripheral write enable (high active)
      puc_rst  => puc_rst               -- Main system reset
      );

  --
  -- Combine peripheral data bus
  ------------------------------------

  per_dout <= per_dout_dio or
              per_dout_timerA or
              per_dout_uart or
              per_dout_temp_8b or
              per_dout_temp_16b;

  irq_in  <= irq or (X"00" & irq_ta0 & irq_ta1 & irq_uart_rx & irq_uart_tx & "00");
  wkup_in <= wkup or "00000000000000";
end rtl;
