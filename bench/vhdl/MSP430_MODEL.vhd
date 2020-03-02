--============================================================================--
--==                                          __ _      _     _             ==--
--==                                         / _(_)    | |   | |            ==--
--==              __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |            ==--
--==             / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |            ==--
--==            | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |            ==--
--==             \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|            ==--
--==                | |                                                     ==--
--==                |_|                                                     ==--
--==                                                                        ==--
--==                                                                        ==--
--==            MSP430 CPU                                                  ==--
--==            Processing Unit                                             ==--
--==                                                                        ==--
--============================================================================--

-- Copyright (c) 2015-2016 by the author(s)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- =============================================================================
-- Author(s):
--   Francisco Javier Reina Campo <frareicam@gmail.com>
--

library IEEE;
use IEEE.STD_LOGIC_1164 .all;
use IEEE.NUMERIC_STD .all;
use WORK.MSP430_PACK .all;

entity MSP430_MODEL is
  port (
    --CORE O
    --CPU registers
    omsp0_r0  : out std_logic_vector (15 downto 0);
    omsp0_r1  : out std_logic_vector (15 downto 0);
    omsp0_r2  : out std_logic_vector (15 downto 0);
    omsp0_r3  : out std_logic_vector (15 downto 0);
    omsp0_r4  : out std_logic_vector (15 downto 0);
    omsp0_r5  : out std_logic_vector (15 downto 0);
    omsp0_r6  : out std_logic_vector (15 downto 0);
    omsp0_r7  : out std_logic_vector (15 downto 0);
    omsp0_r8  : out std_logic_vector (15 downto 0);
    omsp0_r9  : out std_logic_vector (15 downto 0);
    omsp0_r10 : out std_logic_vector (15 downto 0);
    omsp0_r11 : out std_logic_vector (15 downto 0);
    omsp0_r12 : out std_logic_vector (15 downto 0);
    omsp0_r13 : out std_logic_vector (15 downto 0);
    omsp0_r14 : out std_logic_vector (15 downto 0);
    omsp0_r15 : out std_logic_vector (15 downto 0);

    --Debug interface
    omsp0_dbg_en  : out std_logic;
    omsp0_dbg_clk : out std_logic;
    omsp0_dbg_rst : out std_logic;

    --Interrupt detection
    omsp0_irq_detect : out std_logic;
    omsp0_nmi_pnd    : out std_logic;

    omsp0_i_state : out std_logic_vector (2 downto 0);
    omsp0_e_state : out std_logic_vector (3 downto 0);
    omsp0_decode  : out std_logic;
    omsp0_ir      : out std_logic_vector (15 downto 0);
    omsp0_irq_num : out std_logic_vector (5 downto 0);
    omsp0_pc      : out std_logic_vector (15 downto 0);

    --CPU internals
    omsp0_mclk    : out std_logic;
    omsp0_puc_rst : out std_logic;

    dco_clk : out std_logic;

    --User Reset Push Button
    USER_RESET : in std_logic;

    --Triple-Output PLL Clock Chip
    USER_CLOCK : in std_logic;

    --User DIP Switch x4
    GPIO_DIP1 : in std_logic;
    GPIO_DIP2 : in std_logic;
    GPIO_DIP3 : in std_logic;
    GPIO_DIP4 : in std_logic;

    --User LEDs                 
    GPIO_LED1 : out std_logic;
    GPIO_LED2 : out std_logic;
    GPIO_LED3 : out std_logic;
    GPIO_LED4 : out std_logic;

    --Silicon Labs CP2102 USB-to-UART Bridge Chip
    USB_RS232_RXD : in  std_logic;
    USB_RS232_TXD : out std_logic;

    --Peripheral Modules (PMODs) and GPIO
    PMOD1_P3 : inout std_logic;
    PMOD1_P4 : in    std_logic);
end MSP430_MODEL;

architecture MSP430_MODEL_ARQ of MSP430_MODEL is

  --Clock generation
  signal dco_clk_omsp : std_logic;

  --Reset generation
  signal reset_pin   : std_logic;
  signal reset_pin_n : std_logic;
  signal reset_n     : std_logic;
  signal not_reset_n : std_logic;
  signal dco_rst     : std_logic;

  --Debug interface
  signal omsp_dbg_i2c_scl      : std_logic;
  signal omsp_dbg_i2c_sda_in   : std_logic;
  signal omsp_dbg_i2c_sda_out  : std_logic;
  signal omsp0_dbg_i2c_sda_out : std_logic;

  --Instruction memory (CPU 0)
  signal omsp0_pmem_addr       : std_logic_vector (PMEM_MSB downto 0);
  signal omsp0_pmem_cen        : std_logic;
  signal omsp0_pmem_cen_sp     : std_logic;
  signal omsp0_not_pmem_cen_sp : std_logic;
  signal omsp0_pmem_cen_dp     : std_logic;
  signal omsp0_not_pmem_cen_dp : std_logic;
  signal omsp0_pmem_din        : std_logic_vector (15 downto 0);
  signal omsp0_pmem_wen        : std_logic_vector (1 downto 0);
  signal omsp0_not_pmem_wen    : std_logic_vector (1 downto 0);
  signal omsp0_pmem_dout       : std_logic_vector (15 downto 0);
  signal omsp0_pmem_dout_sp    : std_logic_vector (15 downto 0);
  signal omsp0_pmem_dout_dp    : std_logic_vector (15 downto 0);
  signal omsp0_pmem_dout_sel   : std_logic;

  --Data memory (CPU 0)
  signal omsp0_dmem_addr       : std_logic_vector (DMEM_MSB downto 0);
  signal omsp0_dmem_cen        : std_logic;
  signal omsp0_dmem_cen_sp     : std_logic;
  signal omsp0_not_dmem_cen_sp : std_logic;
  signal omsp0_dmem_cen_dp     : std_logic;
  signal omsp0_not_dmem_cen_dp : std_logic;
  signal omsp0_dmem_din        : std_logic_vector (15 downto 0);
  signal omsp0_dmem_wen        : std_logic_vector (1 downto 0);
  signal omsp0_not_dmem_wen    : std_logic_vector (1 downto 0);
  signal omsp0_dmem_dout       : std_logic_vector (15 downto 0);
  signal omsp0_dmem_dout_sp    : std_logic_vector (15 downto 0);
  signal omsp0_dmem_dout_dp    : std_logic_vector (15 downto 0);
  signal omsp0_dmem_dout_sel   : std_logic;

  --UART
  signal omsp_uart_rxd  : std_logic;
  signal omsp0_uart_txd : std_logic;

  --GPIO
  signal gpio_in     : std_logic_vector (3 downto 0);
  signal omspx_out   : std_logic_vector (1 downto 0);
  signal omspy_out   : std_logic_vector (1 downto 0);

  component MSP430_PU
    port (
      --CPU registers   
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

      --Debug interface
      dbg_en  : out std_logic;
      dbg_clk : out std_logic;
      dbg_rst : out std_logic;

      --Interrupt detection
      irq_detect : out std_logic;
      nmi_pnd    : out std_logic;

      i_state : out std_logic_vector (2 downto 0);
      e_state : out std_logic_vector (3 downto 0);
      decode  : out std_logic;
      ir      : out std_logic_vector (15 downto 0);
      irq_num : out std_logic_vector (5 downto 0);
      pc      : out std_logic_vector (15 downto 0);

      --CPU internals
      mclk    : out std_logic;
      puc_rst : out std_logic;

      --Clock & Reset
      dco_clk : in std_logic;
      reset_n : in std_logic;

      --Serial Debug Interface (I2C)
      dbg_i2c_addr      : in  std_logic_vector (6 downto 0);
      dbg_i2c_broadcast : in  std_logic_vector (6 downto 0);
      dbg_i2c_scl       : in  std_logic;
      dbg_i2c_sda_in    : in  std_logic;
      dbg_i2c_sda_out   : out std_logic;

      --Data Memory
      dmem_dout : in  std_logic_vector (15 downto 0);
      dmem_addr : out std_logic_vector (DMEM_MSB downto 0);
      dmem_cen  : out std_logic;
      dmem_din  : out std_logic_vector (15 downto 0);
      dmem_wen  : out std_logic_vector (1 downto 0);

      --Instruction Memory
      pmem_dout : in  std_logic_vector (15 downto 0);
      pmem_addr : out std_logic_vector (PMEM_MSB downto 0);
      pmem_cen  : out std_logic;
      pmem_din  : out std_logic_vector (15 downto 0);
      pmem_wen  : out std_logic_vector (1 downto 0);

      --UART
      uart_rxd : in  std_logic;
      uart_txd : out std_logic;

      --GPIO
      gpio_in  : in  std_logic_vector (3 downto 0);
      gpio_out : out std_logic_vector (1 downto 0));
  end component MSP430_PU;

  component omsp_sync_reset
    port (
      rst_s : out std_logic;
      clk   : in  std_logic;
      rst_a : in  std_logic);
  end component omsp_sync_reset;

  component io_cell
    port (
      pad         : inout std_logic;
      data_in     : out   std_logic;
      data_out    : in    std_logic;
      data_out_en : in    std_logic);
  end component io_cell;

  component DATA_MEMORY_DISTRIBUTED_SINGLEPORT
    port (
      clka  : in  std_logic;
      ena   : in  std_logic;
      wea   : in  std_logic_vector (1 downto 0);
      addra : in  std_logic_vector (DMEM_MSB - 1 downto 0);
      dina  : in  std_logic_vector (15 downto 0);
      douta : out std_logic_vector (15 downto 0));
  end component DATA_MEMORY_DISTRIBUTED_SINGLEPORT;

  component INSTRUCTION_MEMORY_DISTRIBUTED_SINGLEPORT
    port (
      clka  : in  std_logic;
      ena   : in  std_logic;
      wea   : in  std_logic_vector (1 downto 0);
      addra : in  std_logic_vector (PMEM_MSB - 1 downto 0);
      dina  : in  std_logic_vector (15 downto 0);
      douta : out std_logic_vector (15 downto 0));
  end component INSTRUCTION_MEMORY_DISTRIBUTED_SINGLEPORT;

begin
  SOURCE_GENERATOR : block
  begin
    --RESET
    --Reset input buffer
    reset_pin   <= USER_RESET;
    reset_pin_n <= not reset_pin;

    --Release the reset only, if the DCM is locked
    reset_n <= reset_pin_n;

    --Top level reset generation
    sync_reset_dco : omsp_sync_reset
      port map (
        rst_s => dco_rst,
        clk   => dco_clk_omsp,
        rst_a => not_reset_n);

    not_reset_n <= reset_n;

    --CLOCK GENERATION
    --Input buffers
    dco_clk_omsp <= USER_CLOCK;
  end block SOURCE_GENERATOR;

  PU : block
  begin
    MSP430_PU_0 : MSP430_PU
      port map (
        --CPU registers 
        r0  => omsp0_r0,
        r1  => omsp0_r1,
        r2  => omsp0_r2,
        r3  => omsp0_r3,
        r4  => omsp0_r4,
        r5  => omsp0_r5,
        r6  => omsp0_r6,
        r7  => omsp0_r7,
        r8  => omsp0_r8,
        r9  => omsp0_r9,
        r10 => omsp0_r10,
        r11 => omsp0_r11,
        r12 => omsp0_r12,
        r13 => omsp0_r13,
        r14 => omsp0_r14,
        r15 => omsp0_r15,

        -- Debug interface
        dbg_en  => omsp0_dbg_en,
        dbg_clk => omsp0_dbg_clk,
        dbg_rst => omsp0_dbg_rst,

        --Interrupt detection
        irq_detect => omsp0_irq_detect,
        nmi_pnd    => omsp0_nmi_pnd,

        i_state => omsp0_i_state,
        e_state => omsp0_e_state,
        decode  => omsp0_decode,
        ir      => omsp0_ir,
        irq_num => omsp0_irq_num,
        pc      => omsp0_pc,

        --CPU internals
        mclk    => omsp0_mclk,
        puc_rst => omsp0_puc_rst,

        --UART
        uart_rxd => omsp_uart_rxd,
        uart_txd => omsp0_uart_txd,

        --Clock & Reset
        dco_clk => dco_clk_omsp,
        reset_n => reset_n,

        --Serial Debug Interface (I2C)
        dbg_i2c_addr      => std_logic_vector(to_unsigned(50, 7)),
        dbg_i2c_broadcast => std_logic_vector(to_unsigned(49, 7)),
        dbg_i2c_scl       => omsp_dbg_i2c_scl,
        dbg_i2c_sda_in    => omsp_dbg_i2c_sda_in,
        dbg_i2c_sda_out   => omsp0_dbg_i2c_sda_out,

        --Data Memory
        dmem_dout => omsp0_dmem_dout,
        dmem_addr => omsp0_dmem_addr,
        dmem_cen  => omsp0_dmem_cen,
        dmem_din  => omsp0_dmem_din,
        dmem_wen  => omsp0_dmem_wen,

        --Instruction Memory
        pmem_dout => omsp0_pmem_dout,
        pmem_addr => omsp0_pmem_addr,
        pmem_cen  => omsp0_pmem_cen,
        pmem_din  => omsp0_pmem_din,
        pmem_wen  => omsp0_pmem_wen,

        --GPIO
        gpio_in  => gpio_in,
        gpio_out => omspx_out);
  end block PU;

  MEMORIES : block
  begin
    --Instruction Memory muxing (CPU 0)
    omsp0_pmem_cen_sp <= omsp0_pmem_addr (PMEM_MSB) or omsp0_pmem_cen;
    omsp0_pmem_cen_dp <= not omsp0_pmem_addr (PMEM_MSB) or omsp0_pmem_cen;
    omsp0_pmem_dout   <= omsp0_pmem_dout_sp
                       when omsp0_pmem_dout_sel = '1' else omsp0_pmem_dout_dp;

    R0i_1c_2c : process (dco_clk_omsp, dco_rst)
    begin
      if (dco_rst = '1') then
        omsp0_pmem_dout_sel <= '1';
      elsif (rising_edge(dco_clk_omsp)) then
        if (omsp0_pmem_cen_sp = '0') then
          omsp0_pmem_dout_sel <= '1';
        elsif (omsp0_pmem_cen_dp = '0') then
          omsp0_pmem_dout_sel <= '0';
        end if;
      end if;
    end process R0i_1c_2c;

    --Instruction Memory (CPU 0)
    INSTRUCTION_MEMORY_DISTRIBUTED_SINGLEPORT_omsp0 : INSTRUCTION_MEMORY_DISTRIBUTED_SINGLEPORT
      port map(
        clka  => dco_clk_omsp,
        ena   => omsp0_not_pmem_cen_sp,
        wea   => omsp0_not_pmem_wen,
        addra => omsp0_pmem_addr (PMEM_MSB - 1 downto 0),
        dina  => omsp0_pmem_din,
        douta => omsp0_pmem_dout_sp);

    omsp0_not_pmem_cen_sp <= not omsp0_pmem_cen_sp;
    omsp0_not_pmem_wen    <= not omsp0_pmem_wen;

    --Data muxing (CPU 0)
    omsp0_dmem_cen_sp <= omsp0_dmem_addr (DMEM_MSB) or omsp0_dmem_cen;
    omsp0_dmem_cen_dp <= not omsp0_dmem_addr (DMEM_MSB) or omsp0_dmem_cen;
    omsp0_dmem_dout   <= omsp0_dmem_dout_sp
                       when omsp0_dmem_dout_sel = '1' else omsp0_dmem_dout_dp;

    R0d_1c_2c : process (dco_clk_omsp, dco_rst)
    begin
      if (dco_rst = '1') then
        omsp0_dmem_dout_sel <= '1';
      elsif (rising_edge(dco_clk_omsp)) then
        if (omsp0_dmem_cen_sp = '0') then
          omsp0_dmem_dout_sel <= '1';
        elsif (omsp0_dmem_cen_dp = '0') then
          omsp0_dmem_dout_sel <= '0';
        end if;
      end if;
    end process R0d_1c_2c;

    --Data Memory (CPU 0)
    DATA_MEMORY_DISTRIBUTED_SINGLEPORT_omsp0 : DATA_MEMORY_DISTRIBUTED_SINGLEPORT
      port map(
        clka  => dco_clk_omsp,
        ena   => omsp0_not_dmem_cen_sp,
        wea   => omsp0_not_dmem_wen,
        addra => omsp0_dmem_addr (DMEM_MSB - 1 downto 0),
        dina  => omsp0_dmem_din,
        douta => omsp0_dmem_dout_sp);

    omsp0_not_dmem_cen_sp <= not omsp0_dmem_cen_sp;
    omsp0_not_dmem_wen    <= not omsp0_dmem_wen;
  end block MEMORIES;

  CELLS : block
  begin
    dco_clk <= dco_clk_omsp;

    --User DIP Switch x4
    gpio_in <= GPIO_DIP4 & GPIO_DIP3 & GPIO_DIP2 & GPIO_DIP1;

    --User LEDs                 
    GPIO_LED4 <= omspy_out(1);
    GPIO_LED3 <= omspy_out(0);
    GPIO_LED2 <= omspx_out(1);
    GPIO_LED1 <= omspx_out(0);

    --Silicon Labs CP2102 USB-to-UART Bridge Chip
    omsp_uart_rxd <= USB_RS232_RXD;
    USB_RS232_TXD <= omsp0_uart_txd;

    omsp_dbg_i2c_sda_out <= omsp0_dbg_i2c_sda_out;

    --Connector J5
    PMOD_P3_PIN : io_cell
      port map (
        pad         => PMOD1_P3,
        data_in     => omsp_dbg_i2c_sda_in,
        data_out    => '0',
        data_out_en => omsp_dbg_i2c_sda_out);

    omsp_dbg_i2c_scl <= PMOD1_P4;
  end block CELLS;
end MSP430_MODEL_ARQ;
