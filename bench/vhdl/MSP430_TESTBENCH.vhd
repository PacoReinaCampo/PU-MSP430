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

entity MSP430_TESTBENCH is
end MSP430_TESTBENCH;

architecture RTL of MSP430_TESTBENCH is
  component MSP430_MODEL
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
  end component;

  --////////////////////////////////////////////////////////////////
  --
  -- Variables
  --

  --CORE O
  --CPU registers
  signal omsp0_r0  : std_logic_vector (15 downto 0);
  signal omsp0_r1  : std_logic_vector (15 downto 0);
  signal omsp0_r2  : std_logic_vector (15 downto 0);
  signal omsp0_r3  : std_logic_vector (15 downto 0);
  signal omsp0_r4  : std_logic_vector (15 downto 0);
  signal omsp0_r5  : std_logic_vector (15 downto 0);
  signal omsp0_r6  : std_logic_vector (15 downto 0);
  signal omsp0_r7  : std_logic_vector (15 downto 0);
  signal omsp0_r8  : std_logic_vector (15 downto 0);
  signal omsp0_r9  : std_logic_vector (15 downto 0);
  signal omsp0_r10 : std_logic_vector (15 downto 0);
  signal omsp0_r11 : std_logic_vector (15 downto 0);
  signal omsp0_r12 : std_logic_vector (15 downto 0);
  signal omsp0_r13 : std_logic_vector (15 downto 0);
  signal omsp0_r14 : std_logic_vector (15 downto 0);
  signal omsp0_r15 : std_logic_vector (15 downto 0);

  --Debug interface
  signal omsp0_dbg_en  : std_logic;
  signal omsp0_dbg_clk : std_logic;
  signal omsp0_dbg_rst : std_logic;

  --Interrupt detection
  signal omsp0_irq_detect : std_logic;
  signal omsp0_nmi_pnd    : std_logic;

  signal omsp0_i_state : std_logic_vector (2 downto 0);
  signal omsp0_e_state : std_logic_vector (3 downto 0);
  signal omsp0_decode  : std_logic;
  signal omsp0_ir      : std_logic_vector (15 downto 0);
  signal omsp0_irq_num : std_logic_vector (5 downto 0);
  signal omsp0_pc      : std_logic_vector (15 downto 0);

  --CPU internals
  signal omsp0_mclk    : std_logic;
  signal omsp0_puc_rst : std_logic;

  signal dco_clk : std_logic;

  --User Reset Push Button
  signal USER_RESET : std_logic;

  --Triple-Output PLL Clock Chip
  signal USER_CLOCK : std_logic;

  --User DIP Switch x4
  signal GPIO_DIP1 : std_logic;
  signal GPIO_DIP2 : std_logic;
  signal GPIO_DIP3 : std_logic;
  signal GPIO_DIP4 : std_logic;

  --User LEDs
  signal GPIO_LED1 : std_logic;
  signal GPIO_LED2 : std_logic;
  signal GPIO_LED3 : std_logic;
  signal GPIO_LED4 : std_logic;

  --Silicon Labs CP2102 USB-to-UART Bridge Chip
  signal USB_RS232_RXD : std_logic;
  signal USB_RS232_TXD : std_logic;

  --Peripheral Modules (PMODs) and GPIO
  signal PMOD1_P3 : std_logic;
  signal PMOD1_P4 : std_logic;

begin
  --////////////////////////////////////////////////////////////////
  --
  -- Module Body
  --

  --DUT
  DUT : MSP430_MODEL
    port map (
      --CORE 0
      --CPU registers
      omsp0_r0  => omsp0_r0,
      omsp0_r1  => omsp0_r1,
      omsp0_r2  => omsp0_r2,
      omsp0_r3  => omsp0_r3,
      omsp0_r4  => omsp0_r4,
      omsp0_r5  => omsp0_r5,
      omsp0_r6  => omsp0_r6,
      omsp0_r7  => omsp0_r7,
      omsp0_r8  => omsp0_r8,
      omsp0_r9  => omsp0_r9,
      omsp0_r10 => omsp0_r10,
      omsp0_r11 => omsp0_r11,
      omsp0_r12 => omsp0_r12,
      omsp0_r13 => omsp0_r13,
      omsp0_r14 => omsp0_r14,
      omsp0_r15 => omsp0_r15,

      --Debug interface
      omsp0_dbg_en  => omsp0_dbg_en,
      omsp0_dbg_clk => omsp0_dbg_clk,
      omsp0_dbg_rst => omsp0_dbg_rst,

      --Interrupt detection
      omsp0_irq_detect => omsp0_irq_detect,
      omsp0_nmi_pnd    => omsp0_nmi_pnd,

      omsp0_i_state => omsp0_i_state,
      omsp0_e_state => omsp0_e_state,
      omsp0_decode  => omsp0_decode,
      omsp0_ir      => omsp0_ir,
      omsp0_irq_num => omsp0_irq_num,
      omsp0_pc      => omsp0_pc,

      --CPU internals
      omsp0_mclk    => omsp0_mclk,
      omsp0_puc_rst => omsp0_puc_rst,

      dco_clk => dco_clk,

      --User Reset Push Button
      USER_RESET => USER_RESET,

      --Triple-Output PLL Clock Chip
      USER_CLOCK => USER_CLOCK,

      --User DIP Switch x4
      GPIO_DIP1 => GPIO_DIP1,
      GPIO_DIP2 => GPIO_DIP2,
      GPIO_DIP3 => GPIO_DIP3,
      GPIO_DIP4 => GPIO_DIP4,

      --User LEDs                 
      GPIO_LED1 => GPIO_LED1,
      GPIO_LED2 => GPIO_LED2,
      GPIO_LED3 => GPIO_LED3,
      GPIO_LED4 => GPIO_LED4,

      --Silicon Labs CP2102 USB-to-UART Bridge Chip
      USB_RS232_RXD => USB_RS232_RXD,
      USB_RS232_TXD => USB_RS232_TXD,

      --Peripheral Modules (PMODs) and GPIO
      PMOD1_P3 => PMOD1_P3,
      PMOD1_P4 => PMOD1_P4);
end RTL;
