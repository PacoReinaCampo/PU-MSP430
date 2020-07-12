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
--   Olivier Girard <olgirard@gmail.com>
--   Paco Reina Campo <pacoreinacampo@queenfield.tech>
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.msp430_pkg.all;

entity msp430_ta is
  port (
    -- OUTPUTs
    irq_ta0    : out std_logic;         -- Timer A interrupt: TACCR0
    irq_ta1    : out std_logic;  -- Timer A interrupt: TAIV, TACCR1, TACCR2
    per_dout   : out std_logic_vector(15 downto 0);  -- Peripheral data output
    ta_out0    : out std_logic;         -- Timer A output 0
    ta_out0_en : out std_logic;         -- Timer A output 0 enable
    ta_out1    : out std_logic;         -- Timer A output 1
    ta_out1_en : out std_logic;         -- Timer A output 1 enable
    ta_out2    : out std_logic;         -- Timer A output 2
    ta_out2_en : out std_logic;         -- Timer A output 2 enable
    tar        : out std_logic_vector(15 downto 0);
    taccr0     : out std_logic_vector(15 downto 0);

    -- INPUTs
    aclk_en     : in std_logic;         -- ACLK enable (from CPU)
    dbg_freeze  : in std_logic;         -- Freeze Timer A counter
    inclk       : in std_logic;         -- INCLK external timer clock (SLOW)
    irq_ta0_acc : in std_logic;         -- Interrupt request TACCR0 accepted
    mclk        : in std_logic;         -- Main system clock
    per_addr    : in std_logic_vector(13 downto 0);  -- Peripheral address
    per_din     : in std_logic_vector(15 downto 0);  -- Peripheral data input
    per_en      : in std_logic;         -- Peripheral enable (high active)
    per_we      : in std_logic_vector(1 downto 0);  -- Peripheral write enable (high active)
    puc_rst     : in std_logic;         -- Main system reset
    smclk_en    : in std_logic;         -- SMCLK enable (from CPU)
    ta_cci0a    : in std_logic;         -- Timer A capture 0 input A
    ta_cci0b    : in std_logic;         -- Timer A capture 0 input B
    ta_cci1a    : in std_logic;         -- Timer A capture 1 input A
    ta_cci1b    : in std_logic;         -- Timer A capture 1 input B
    ta_cci2a    : in std_logic;         -- Timer A capture 2 input A
    ta_cci2b    : in std_logic;         -- Timer A capture 2 input B
    taclk       : in std_logic);        -- TACLK external timer clock (SLOW)
end msp430_ta;

architecture rtl of msp430_ta is

  --=============================================================================
  -- 1)  PARAMETER DECLARATION
  --=============================================================================

  -- Register base address (must be aligned to decoder bit width)
  constant BASE_ADDR : std_logic_vector(14 downto 0) := "000000000000100";

  -- Decoder bit width (defines how many bits are considered for address decoding)
  constant DEC_WD : integer := 7;

  -- Register addresses offset
  constant TACTLX   : std_logic_vector(DEC_WD-1 downto 0) := std_logic_vector(to_unsigned(96, DEC_WD));
  constant TARX     : std_logic_vector(DEC_WD-1 downto 0) := std_logic_vector(to_unsigned(112, DEC_WD));
  constant TACCTLX0 : std_logic_vector(DEC_WD-1 downto 0) := std_logic_vector(to_unsigned(98, DEC_WD));
  constant TACCRX0  : std_logic_vector(DEC_WD-1 downto 0) := std_logic_vector(to_unsigned(114, DEC_WD));
  constant TACCTLX1 : std_logic_vector(DEC_WD-1 downto 0) := std_logic_vector(to_unsigned(100, DEC_WD));
  constant TACCRX1  : std_logic_vector(DEC_WD-1 downto 0) := std_logic_vector(to_unsigned(116, DEC_WD));
  constant TACCTLX2 : std_logic_vector(DEC_WD-1 downto 0) := std_logic_vector(to_unsigned(102, DEC_WD));
  constant TACCRX2  : std_logic_vector(DEC_WD-1 downto 0) := std_logic_vector(to_unsigned(118, DEC_WD));
  constant TAIVX    : std_logic_vector(DEC_WD-1 downto 0) := std_logic_vector(to_unsigned(46, DEC_WD));

  -- Register one-hot decoder utilities
  constant DEC_SZ : integer := 2**DEC_WD;

  constant BASE_REG : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(to_unsigned(1, DEC_SZ));

  -- Register one-hot decoder
  constant TACTL_D   : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG sll 96));
  constant TAR_D     : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG sll 112));
  constant TACCTL0_D : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG sll 98));
  constant TACCR0_D  : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG sll 114));
  constant TACCTL1_D : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG sll 100));
  constant TACCR1_D  : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG sll 116));
  constant TACCTL2_D : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG sll 102));
  constant TACCR2_D  : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG sll 118));
  constant TAIV_D    : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG sll 46));

  --============================================================================
  -- 2)  REGISTER DECODER
  --============================================================================

  -- Local register selection
  signal reg_sel : std_logic;

  -- Register local address
  signal reg_addr : std_logic_vector(DEC_WD-1 downto 0);

  -- Register address decode
  signal reg_dec : std_logic_vector(DEC_SZ-1 downto 0);

  -- Read/Write probes
  signal reg_write : std_logic;
  signal reg_read  : std_logic;

  -- Read/Write vectors
  signal reg_wr : std_logic_vector(DEC_SZ-1 downto 0);
  signal reg_rd : std_logic_vector(DEC_SZ-1 downto 0);

  --============================================================================
  -- 3) REGISTERS
  --============================================================================

  -- TACTL Register
  signal tactl : std_logic_vector(9 downto 0);

  signal tactl_wr  : std_logic;
  signal taclr     : std_logic;
  signal taifg_set : std_logic;
  signal taifg_clr : std_logic;

  -- TAR Register
  signal tar_wr : std_logic;

  signal tar_clk : std_logic;
  signal tar_clr : std_logic;
  signal tar_inc : std_logic;
  signal tar_dec : std_logic;
  signal tar_add : std_logic_vector(15 downto 0);
  signal tar_nxt : std_logic_vector(15 downto 0);

  -- TACCTL0 Register
  signal tacctl0 : std_logic_vector(15 downto 0);

  signal tacctl0_wr : std_logic;
  signal ccifg0_set : std_logic;
  signal cov0_set   : std_logic;

  signal cci0         : std_logic;
  signal scci0        : std_logic;
  signal tacctl0_full : std_logic_vector(15 downto 0);

  -- TACCR0 Register
  signal taccr0_wr : std_logic;
  signal cci0_cap  : std_logic;

  -- TACCTL1 Register
  signal tacctl1 : std_logic_vector(15 downto 0);

  signal tacctl1_wr : std_logic;
  signal ccifg1_set : std_logic;
  signal ccifg1_clr : std_logic;
  signal cov1_set   : std_logic;

  signal cci1         : std_logic;
  signal scci1        : std_logic;
  signal tacctl1_full : std_logic_vector(15 downto 0);

  -- TACCR1 Register
  signal taccr1 : std_logic_vector(15 downto 0);

  signal taccr1_wr : std_logic;
  signal cci1_cap  : std_logic;

  -- TACCTL2 Register
  signal tacctl2 : std_logic_vector(15 downto 0);

  signal tacctl2_wr : std_logic;
  signal ccifg2_set : std_logic;
  signal ccifg2_clr : std_logic;
  signal cov2_set   : std_logic;

  signal cci2         : std_logic;
  signal scci2        : std_logic;
  signal tacctl2_full : std_logic_vector(15 downto 0);

  -- TACCR2 Register
  signal taccr2 : std_logic_vector(15 downto 0);

  signal taccr2_wr : std_logic;
  signal cci2_cap  : std_logic;

  -- TAIV Register
  signal taiv : std_logic_vector(3 downto 0);

  --============================================================================
  -- 4) DATA OUTPUT GENERATION
  --============================================================================

  -- Data output mux
  signal tactl_rd   : std_logic_vector(15 downto 0);
  signal tar_rd     : std_logic_vector(15 downto 0);
  signal tacctl0_rd : std_logic_vector(15 downto 0);
  signal taccr0_rd  : std_logic_vector(15 downto 0);
  signal tacctl1_rd : std_logic_vector(15 downto 0);
  signal taccr1_rd  : std_logic_vector(15 downto 0);
  signal tacctl2_rd : std_logic_vector(15 downto 0);
  signal taccr2_rd  : std_logic_vector(15 downto 0);
  signal taiv_rd    : std_logic_vector(15 downto 0);

  --============================================================================
  -- 5) Timer A counter control
  --============================================================================

  -- Clock input synchronization (TACLK & INCLK)
  signal taclk_s : std_logic;
  signal inclk_s : std_logic;

  -- Clock edge detection (TACLK & INCLK)
  signal taclk_dly : std_logic;
  signal taclk_en  : std_logic;
  signal inclk_dly : std_logic;
  signal inclk_en  : std_logic;

  -- Timer clock input mux
  signal sel_clk : std_logic;

  -- Generate update pluse for the counter (<=> divided clock)
  signal clk_div : std_logic_vector(2 downto 0);
  signal tar_dir : std_logic;

  --============================================================================
  -- 6) Timer A comparator
  --============================================================================

  signal equ0 : std_logic;
  signal equ1 : std_logic;
  signal equ2 : std_logic;

  -- CCIx synchronization
  signal cci0_s : std_logic;
  signal cci1_s : std_logic;
  signal cci2_s : std_logic;

  -- Register CCIx for edge detection
  signal cci0_dly : std_logic;
  signal cci1_dly : std_logic;
  signal cci2_dly : std_logic;

  -- Capture mode
  signal cci0_evt : std_logic;
  signal cci1_evt : std_logic;
  signal cci2_evt : std_logic;

  -- Event Synchronization
  signal cci0_evt_s : std_logic;
  signal cci1_evt_s : std_logic;
  signal cci2_evt_s : std_logic;
  signal cci0_sync  : std_logic;
  signal cci1_sync  : std_logic;
  signal cci2_sync  : std_logic;

  -- Generate capture overflow flag
  signal cap0_taken     : std_logic;
  signal cap0_taken_clr : std_logic;

  signal cap1_taken     : std_logic;
  signal cap1_taken_clr : std_logic;
  signal cap2_taken     : std_logic;
  signal cap2_taken_clr : std_logic;

  --============================================================================
  -- 8) Timer A output unit
  --============================================================================

  -- Output unit 0
  signal ta_out0_mode0 : std_logic;     -- Output
  signal ta_out0_mode1 : std_logic;     -- Set
  -- Toggle/Reset
  signal ta_out0_mode2 : std_logic;
  -- Set/Reset
  signal ta_out0_mode3 : std_logic;
  signal ta_out0_mode4 : std_logic;     -- Toggle
  signal ta_out0_mode5 : std_logic;     -- Reset
  -- Toggle/Set
  signal ta_out0_mode6 : std_logic;
  -- Reset/Set
  signal ta_out0_mode7 : std_logic;
  signal ta_out0_nxt   : std_logic;

  -- Output unit 1
  signal ta_out1_mode0 : std_logic;     -- Output
  signal ta_out1_mode1 : std_logic;     -- Set
  -- Toggle/Reset
  signal ta_out1_mode2 : std_logic;
  -- Set/Reset
  signal ta_out1_mode3 : std_logic;
  signal ta_out1_mode4 : std_logic;     -- Toggle
  signal ta_out1_mode5 : std_logic;     -- Reset
  -- Toggle/Set
  signal ta_out1_mode6 : std_logic;
  -- Reset/Set
  signal ta_out1_mode7 : std_logic;
  signal ta_out1_nxt   : std_logic;

  -- Output unit 2
  signal ta_out2_mode0 : std_logic;     -- Output
  signal ta_out2_mode1 : std_logic;     -- Set
  -- Toggle/Reset
  signal ta_out2_mode2 : std_logic;
  -- Set/Reset
  signal ta_out2_mode3 : std_logic;
  signal ta_out2_mode4 : std_logic;     -- Toggle
  signal ta_out2_mode5 : std_logic;     -- Reset
  -- Toggle/Set
  signal ta_out2_mode6 : std_logic;
  -- Reset/Set
  signal ta_out2_mode7 : std_logic;
  signal ta_out2_nxt   : std_logic;

begin
  --============================================================================
  -- 2)  REGISTER DECODER
  --============================================================================

  -- Local register selection
  reg_sel <= per_en and to_stdlogic(per_addr(13 downto DEC_WD-1) = BASE_ADDR(14 downto DEC_WD));

  -- Register local address
  reg_addr <= (per_addr(DEC_WD-2 downto 0) & '0');

  -- Register address decode
  reg_dec <= (TACTL_D   and (0 to DEC_SZ - 1 => to_stdlogic(reg_addr = TACTLX))) or
             (TAR_D     and (0 to DEC_SZ - 1 => to_stdlogic(reg_addr = TARX))) or
             (TACCTL0_D and (0 to DEC_SZ - 1 => to_stdlogic(reg_addr = TACCTLX0))) or
             (TACCR0_D  and (0 to DEC_SZ - 1 => to_stdlogic(reg_addr = TACCRX0))) or
             (TACCTL1_D and (0 to DEC_SZ - 1 => to_stdlogic(reg_addr = TACCTLX1))) or
             (TACCR1_D  and (0 to DEC_SZ - 1 => to_stdlogic(reg_addr = TACCRX1))) or
             (TACCTL2_D and (0 to DEC_SZ - 1 => to_stdlogic(reg_addr = TACCTLX2))) or
             (TACCR2_D  and (0 to DEC_SZ - 1 => to_stdlogic(reg_addr = TACCRX2))) or
             (TAIV_D    and (0 to DEC_SZ - 1 => to_stdlogic(reg_addr = TAIVX)));

  -- Read/Write probes
  reg_write <= (per_we(0) or per_we(1)) and reg_sel;
  reg_read  <= (per_we(0) nor per_we(1)) and reg_sel;

  -- Read/Write vectors
  reg_wr <= reg_dec and (0 to DEC_SZ-1 => reg_write);
  reg_rd <= reg_dec and (0 to DEC_SZ-1 => reg_read);

  --============================================================================
  -- 3) REGISTERS
  --============================================================================

  -- TACTL Register
  tactl_wr <= reg_wr(to_integer(unsigned(TACTLX)));
  taclr    <= tactl_wr and per_din(2);

  processing_0 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      tactl <= "0000000000";
    elsif (rising_edge(mclk)) then
      if (tactl_wr) then
        tactl <= ((per_din(9 downto 0) and "1111110011") or ("000000000" & taifg_set)) and ("111111111" & not taifg_clr);
      else
        tactl <= (tactl or ("000000000" & taifg_set)) and ("111111111" & not taifg_clr);
      end if;
    end if;
  end process;

  -- TAR Register
  tar_wr  <= reg_wr(to_integer(unsigned(TARX)));
  tar_add <= X"0001"
             when tar_inc else X"ffff"
             when tar_dec else X"0000";
  tar_nxt <= X"0000"
             when tar_clr else std_logic_vector(unsigned(tar)+unsigned(tar_add));

  processing_1 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      tar <= X"0000";
    elsif (rising_edge(mclk)) then
      if (tar_wr) then
        tar <= per_din;
      elsif (taclr) then
        tar <= X"0000";
      elsif (tar_clk and not dbg_freeze) then
        tar <= tar_nxt;
      end if;
    end if;
  end process;

  -- TACCTL0 Register
  tacctl0_wr <= reg_wr(to_integer(unsigned(TACCTLX0)));

  processing_2 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      tacctl0 <= X"0000";
    elsif (rising_edge(mclk)) then
      if (tacctl0_wr) then
        tacctl0 <= ((per_din and "1111100111110111") or ("00000000000000" & cov0_set & ccifg0_set)) and ("111111111111111" & not irq_ta0_acc);
      else
        tacctl0 <= (tacctl0 or ("00000000000000" & cov0_set & ccifg0_set)) and ("111111111111111" & not irq_ta0_acc);
      end if;
    end if;
  end process;

  tacctl0_full <= tacctl0 or ("00000" & scci0 & "000000" & cci0 & "000");

  -- TACCR0 Register
  taccr0_wr <= reg_wr(to_integer(unsigned(TACCRX0)));

  processing_3 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      taccr0 <= X"0000";
    elsif (rising_edge(mclk)) then
      if (taccr0_wr) then
        taccr0 <= per_din;
      elsif (cci0_cap) then
        taccr0 <= tar;
      end if;
    end if;
  end process;

  -- TACCTL1 Register
  tacctl1_wr <= reg_wr(to_integer(unsigned(TACCTLX1)));

  processing_4 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      tacctl1 <= X"0000";
    elsif (rising_edge(mclk)) then
      if (tacctl1_wr) then
        tacctl1 <= ((per_din and "1111100111110111") or ("00000000000000" & cov1_set & ccifg1_set)) and ("111111111111111" & not ccifg1_clr);
      else
        tacctl1 <= (tacctl1 or ("00000000000000" & cov1_set & ccifg1_set)) and ("111111111111111" & not ccifg1_clr);
      end if;
    end if;
  end process;

  tacctl1_full <= tacctl1 or ("00000" & scci1 & "000000" & cci1 & "000");

  -- TACCR1 Register
  taccr1_wr <= reg_wr(to_integer(unsigned(TACCRX1)));

  processing_5 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      taccr1 <= X"0000";
    elsif (rising_edge(mclk)) then
      if (taccr1_wr) then
        taccr1 <= per_din;
      elsif (cci1_cap) then
        taccr1 <= tar;
      end if;
    end if;
  end process;

  -- TACCTL2 Register
  tacctl2_wr <= reg_wr(to_integer(unsigned(TACCTLX2)));

  processing_6 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      tacctl2 <= X"0000";
    elsif (rising_edge(mclk)) then
      if (tacctl2_wr) then
        tacctl2 <= ((per_din and X"f9f7") or ("00000000000000" & cov2_set & ccifg2_set)) and ("111111111111111" & not ccifg2_clr);
      else
        tacctl2 <= (tacctl2 or ("00000000000000" & cov2_set & ccifg2_set)) and ("111111111111111" & not ccifg2_clr);
      end if;
    end if;
  end process;

  tacctl2_full <= tacctl2 or ("00000" & scci2 & "000000" & cci2 & "000");

  -- TACCR2 Register
  taccr2_wr <= reg_wr(to_integer(unsigned(TACCRX2)));

  processing_7 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      taccr2 <= X"0000";
    elsif (rising_edge(mclk)) then
      if (taccr2_wr) then
        taccr2 <= per_din;
      elsif (cci2_cap) then
        taccr2 <= tar;
      end if;
    end if;
  end process;

  -- TAIV Register
  taiv <= X"2"
          when (tacctl1(0) and tacctl1(4)) else X"4"
          when (tacctl2(0) and tacctl2(4)) else X"A"
          when (tactl(0) and tactl(1))     else X"0";

  ccifg1_clr <= (reg_rd(to_integer(unsigned(TAIVX))) or reg_wr(to_integer(unsigned(TAIVX)))) and to_stdlogic(taiv = X"2");
  ccifg2_clr <= (reg_rd(to_integer(unsigned(TAIVX))) or reg_wr(to_integer(unsigned(TAIVX)))) and to_stdlogic(taiv = X"4");
  taifg_clr  <= (reg_rd(to_integer(unsigned(TAIVX))) or reg_wr(to_integer(unsigned(TAIVX)))) and to_stdlogic(taiv = X"A");

  --============================================================================
  -- 4) DATA OUTPUT GENERATION
  --============================================================================

  -- Data output mux
  tactl_rd   <= ("000000" & tactl) and (0 to 15 => reg_rd(to_integer(unsigned(TACTLX))));
  tar_rd     <= tar and (0 to 15                => reg_rd(to_integer(unsigned(TARX))));
  tacctl0_rd <= tacctl0_full and (0 to 15       => reg_rd(to_integer(unsigned(TACCTLX0))));
  taccr0_rd  <= taccr0 and (0 to 15             => reg_rd(to_integer(unsigned(TACCRX0))));
  tacctl1_rd <= tacctl1_full and (0 to 15       => reg_rd(to_integer(unsigned(TACCTLX1))));
  taccr1_rd  <= taccr1 and (0 to 15             => reg_rd(to_integer(unsigned(TACCRX1))));
  tacctl2_rd <= tacctl2_full and (0 to 15       => reg_rd(to_integer(unsigned(TACCTLX2))));
  taccr2_rd  <= taccr2 and (0 to 15             => reg_rd(to_integer(unsigned(TACCRX2))));
  taiv_rd    <= (X"000" & taiv) and (0 to 15    => reg_rd(to_integer(unsigned(TAIVX))));
  per_dout   <= tactl_rd or tar_rd or tacctl0_rd or taccr0_rd or tacctl1_rd or taccr1_rd or tacctl2_rd or taccr2_rd or taiv_rd;

  --============================================================================
  -- 5) Timer A counter control
  --============================================================================

  -- Clock input synchronization (TACLK & INCLK)
  sync_cell_taclk : msp430_sync_cell
    port map (
      data_out => taclk_s,
      data_in  => taclk,
      clk      => mclk,
      rst      => puc_rst);

  sync_cell_inclk : msp430_sync_cell
    port map (
      data_out => inclk_s,
      data_in  => inclk,
      clk      => mclk,
      rst      => puc_rst);

  -- Clock edge detection (TACLK & INCLK)
  processing_8 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      taclk_dly <= '0';
    elsif (rising_edge(mclk)) then
      taclk_dly <= taclk_s;
    end if;
  end process;

  taclk_en <= taclk_s and not taclk_dly;

  processing_9 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      inclk_dly <= '0';
    elsif (rising_edge(mclk)) then
      inclk_dly <= inclk_s;
    end if;
  end process;

  -- Timer clock input mux
  inclk_en <= inclk_s and not inclk_dly;
  sel_clk  <= taclk_en
              when (tactl(9 downto 8) = "00") else aclk_en
              when (tactl(9 downto 8) = "01") else smclk_en
              when (tactl(9 downto 8) = "10") else inclk_en;

  -- Generate update pluse for the counter (<=> divided clock)
  tar_clk <= sel_clk and '1' when (tactl(7 downto 6) = "00") else clk_div(0)
                             when (tactl(7 downto 6) = "01") else (clk_div(0) and clk_div(1))
                             when (tactl(7 downto 6) = "10") else (clk_div(0) and clk_div(1) and clk_div(2));

  processing_10 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      clk_div <= "000";
    elsif (rising_edge(mclk)) then
      if (tar_clk or taclr) then
        clk_div <= "000";
      elsif ((tactl(5 downto 4) /= "00") and (sel_clk = '1')) then
        clk_div <= std_logic_vector(unsigned(clk_div)+"001");
      end if;
    end if;
  end process;

  -- Time counter control signals
  tar_clr <= (to_stdlogic(tactl(5 downto 4) = "01") and to_stdlogic(tar >= taccr0)) or (to_stdlogic(tactl(5 downto 4) = "11") and to_stdlogic(taccr0 = X"0000"));

  tar_inc <= to_stdlogic(tactl(5 downto 4) = "01") or to_stdlogic(tactl(5 downto 4) = "10") or (to_stdlogic(tactl(5 downto 4) = "11") and not tar_dec);

  processing_11 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      tar_dir <= '0';
    elsif (rising_edge(mclk)) then
      if (taclr) then
        tar_dir <= '0';
      elsif (tactl(5 downto 4) = "11") then
        if ((tar_clk = '1') and (tar = X"0001")) then
          tar_dir <= '0';
        elsif (tar >= taccr0) then
          tar_dir <= '1';
        end if;
      else
        tar_dir <= '0';
      end if;
    end if;
  end process;

  tar_dec <= tar_dir or (to_stdlogic(tactl(5 downto 4) = "11") and to_stdlogic(tar >= taccr0));

  --============================================================================
  -- 6) Timer A comparator
  --============================================================================

  equ0 <= to_stdlogic(tar_nxt = taccr0) and to_stdlogic(tar /= taccr0);
  equ1 <= to_stdlogic(tar_nxt = taccr1) and to_stdlogic(tar /= taccr1);
  equ2 <= to_stdlogic(tar_nxt = taccr2) and to_stdlogic(tar /= taccr2);

  --============================================================================
  -- 7) Timer A capture logic
  --============================================================================

  -- Input selection
  cci0 <= ta_cci0a
          when (tacctl0(13 downto 12) = "00") else ta_cci0b
          when (tacctl0(13 downto 12) = "01") else '0'
          when (tacctl0(13 downto 12) = "10") else '1';

  cci1 <= ta_cci1a
          when (tacctl1(13 downto 12) = "00") else ta_cci1b
          when (tacctl1(13 downto 12) = "01") else '0'
          when (tacctl1(13 downto 12) = "10") else '1';

  cci2 <= ta_cci2a
          when (tacctl2(13 downto 12) = "00") else ta_cci2b
          when (tacctl2(13 downto 12) = "01") else '0'
          when (tacctl2(13 downto 12) = "10") else '1';

  sync_cell_cci0 : msp430_sync_cell
    port map (
      data_out => cci0_s,
      data_in  => cci0,
      clk      => mclk,
      rst      => puc_rst);

  sync_cell_cci1 : msp430_sync_cell
    port map (
      data_out => cci1_s,
      data_in  => cci1,
      clk      => mclk,
      rst      => puc_rst);

  sync_cell_cci2 : msp430_sync_cell
    port map (
      data_out => cci2_s,
      data_in  => cci2,
      clk      => mclk,
      rst      => puc_rst);

  processing_12 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      cci0_dly <= '0';
      cci1_dly <= '0';
      cci2_dly <= '0';
    elsif (rising_edge(mclk)) then
      cci0_dly <= cci0_s;
      cci1_dly <= cci1_s;
      cci2_dly <= cci2_s;
    end if;
  end process;

  -- Generate SCCIx
  processing_13 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      scci0 <= '0';
    elsif (rising_edge(mclk)) then
      if (tar_clk and equ0) then
        scci0 <= cci0_s;
      end if;
    end if;
  end process;

  processing_14 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      scci1 <= '0';
    elsif (rising_edge(mclk)) then
      if (tar_clk and equ1) then
        scci1 <= cci1_s;
      end if;
    end if;
  end process;

  processing_15 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      scci2 <= '0';
    elsif (rising_edge(mclk)) then
      if (tar_clk and equ2) then
        scci2 <= cci2_s;
      end if;
    end if;
  end process;

  -- Capture mode
  cci0_evt <= '0'
              when (tacctl0(15 downto 14) = "00") else (cci0_s and not cci0_dly)
              when (tacctl0(15 downto 14) = "01") else (not cci0_s and cci0_dly)
              when (tacctl0(15 downto 14) = "10") else (cci0_s xor cci0_dly);  -- Both edges

  cci1_evt <= '0'
              when (tacctl1(15 downto 14) = "00") else (cci1_s and not cci1_dly)
              when (tacctl1(15 downto 14) = "01") else (not cci1_s and cci1_dly)
              when (tacctl1(15 downto 14) = "10") else (cci1_s xor cci1_dly);  -- Both edges

  cci2_evt <= '0'
              when (tacctl2(15 downto 14) = "00") else (cci2_s and not cci2_dly)
              when (tacctl2(15 downto 14) = "01") else (not cci2_s and cci2_dly)
              when (tacctl2(15 downto 14) = "10") else (cci2_s xor cci2_dly);  -- Both edges

  -- Event Synchronization
  processing_16 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      cci0_evt_s <= '0';
    elsif (rising_edge(mclk)) then
      if (tar_clk) then
        cci0_evt_s <= '0';
      elsif (cci0_evt) then
        cci0_evt_s <= '1';
      end if;
    end if;
  end process;

  processing_17 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      cci1_evt_s <= '0';
    elsif (rising_edge(mclk)) then
      if (tar_clk) then
        cci1_evt_s <= '0';
      elsif (cci1_evt) then
        cci1_evt_s <= '1';
      end if;
    end if;
  end process;

  processing_18 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      cci2_evt_s <= '0';
    elsif (rising_edge(mclk)) then
      if (tar_clk) then
        cci2_evt_s <= '0';
      elsif (cci2_evt) then
        cci2_evt_s <= '1';
      end if;
    end if;
  end process;

  processing_19 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      cci0_sync <= '0';
    elsif (rising_edge(mclk)) then
      cci0_sync <= (tar_clk and cci0_evt_s) or (tar_clk and cci0_evt and not cci0_evt_s);
    end if;
  end process;

  processing_20 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      cci1_sync <= '0';
    elsif (rising_edge(mclk)) then
      cci1_sync <= (tar_clk and cci1_evt_s) or (tar_clk and cci1_evt and not cci1_evt_s);
    end if;
  end process;

  processing_21 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      cci2_sync <= '0';
    elsif (rising_edge(mclk)) then
      cci2_sync <= (tar_clk and cci2_evt_s) or (tar_clk and cci2_evt and not cci2_evt_s);
    end if;
  end process;

  -- Generate final capture command
  cci0_cap <= cci0_sync
              when tacctl0(11) else cci0_evt;
  cci1_cap <= cci1_sync
              when tacctl1(11) else cci1_evt;
  cci2_cap <= cci2_sync
              when tacctl2(11) else cci2_evt;

  cap0_taken_clr <= reg_rd(to_integer(unsigned(TACCRX0))) or (tacctl0_wr and tacctl0(1) and not per_din(1));

  -- Generate capture overflow flag
  processing_22 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      cap0_taken <= '0';
    elsif (rising_edge(mclk)) then
      if (cci0_cap) then
        cap0_taken <= '1';
      elsif (cap0_taken_clr) then
        cap0_taken <= '0';
      end if;
    end if;
  end process;
  cap1_taken_clr <= reg_rd(to_integer(unsigned(TACCRX1))) or (tacctl1_wr and tacctl1(1) and not per_din(1));

  processing_23 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      cap1_taken <= '0';
    elsif (rising_edge(mclk)) then
      if (cci1_cap) then
        cap1_taken <= '1';
      elsif (cap1_taken_clr) then
        cap1_taken <= '0';
      end if;
    end if;
  end process;
  cap2_taken_clr <= reg_rd(to_integer(unsigned(TACCRX2))) or (tacctl2_wr and tacctl2(1) and not per_din(1));

  processing_24 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      cap2_taken <= '0';
    elsif (rising_edge(mclk)) then
      if (cci2_cap) then
        cap2_taken <= '1';
      elsif (cap2_taken_clr) then
        cap2_taken <= '0';
      end if;
    end if;
  end process;

  cov0_set <= cap0_taken and cci0_cap and not reg_rd(to_integer(unsigned(TACCRX0)));
  cov1_set <= cap1_taken and cci1_cap and not reg_rd(to_integer(unsigned(TACCRX1)));
  cov2_set <= cap2_taken and cci2_cap and not reg_rd(to_integer(unsigned(TACCRX2)));

  --============================================================================
  -- 8) Timer A output unit
  --============================================================================

  -- Output unit 0
  ta_out0_mode0 <= tacctl0(2);
  ta_out0_mode1 <= '1'
                   when equ0 else ta_out0;
  ta_out0_mode2 <= not ta_out0
                   when equ0 else '0'
                   when equ0 else ta_out0;
  ta_out0_mode3 <= '1'
                   when equ0 else '0'
                   when equ0 else ta_out0;
  ta_out0_mode4 <= not ta_out0
                   when equ0 else ta_out0;
  ta_out0_mode5 <= '0'
                   when equ0 else ta_out0;
  ta_out0_mode6 <= not ta_out0
                   when equ0 else '1'
                   when equ0 else ta_out0;
  ta_out0_mode7 <= '0'
                   when equ0 else '1'
                   when equ0 else ta_out0;

  ta_out0_nxt <= ta_out0_mode0
                 when (tacctl0(7 downto 5) = "000") else ta_out0_mode1
                 when (tacctl0(7 downto 5) = "001") else ta_out0_mode2
                 when (tacctl0(7 downto 5) = "010") else ta_out0_mode3
                 when (tacctl0(7 downto 5) = "011") else ta_out0_mode4
                 when (tacctl0(7 downto 5) = "100") else ta_out0_mode5
                 when (tacctl0(7 downto 5) = "101") else ta_out0_mode6
                 when (tacctl0(7 downto 5) = "110") else ta_out0_mode7;

  processing_25 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      ta_out0 <= '0';
    elsif (rising_edge(mclk)) then
      if ((tacctl0(7 downto 5) = "001") and (taclr = '1')) then
        ta_out0 <= '0';
      elsif (tar_clk) then
        ta_out0 <= ta_out0_nxt;
      end if;
    end if;
  end process;

  ta_out0_en <= not tacctl0(8);

  -- Output unit 1
  ta_out1_mode0 <= tacctl1(2);
  ta_out1_mode1 <= '1'
                   when equ1 else ta_out1;
  ta_out1_mode2 <= not ta_out1
                   when equ1 else '0'
                   when equ0 else ta_out1;
  ta_out1_mode3 <= '1'
                   when equ1 else '0'
                   when equ0 else ta_out1;
  ta_out1_mode4 <= not ta_out1
                   when equ1 else ta_out1;
  ta_out1_mode5 <= '0'
                   when equ1 else ta_out1;
  ta_out1_mode6 <= not ta_out1
                   when equ1 else '1'
                   when equ0 else ta_out1;
  ta_out1_mode7 <= '0'
                   when equ1 else '1'
                   when equ0 else ta_out1;

  ta_out1_nxt <= ta_out1_mode0
                 when (tacctl1(7 downto 5) = "000") else ta_out1_mode1
                 when (tacctl1(7 downto 5) = "001") else ta_out1_mode2
                 when (tacctl1(7 downto 5) = "010") else ta_out1_mode3
                 when (tacctl1(7 downto 5) = "011") else ta_out1_mode4
                 when (tacctl1(7 downto 5) = "100") else ta_out1_mode5
                 when (tacctl1(7 downto 5) = "101") else ta_out1_mode6
                 when (tacctl1(7 downto 5) = "110") else ta_out1_mode7;

  processing_26 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      ta_out1 <= '0';
    elsif (rising_edge(mclk)) then
      if ((tacctl1(7 downto 5) = "001") and (taclr = '1')) then
        ta_out1 <= '0';
      elsif (tar_clk) then
        ta_out1 <= ta_out1_nxt;
      end if;
    end if;
  end process;

  ta_out1_en <= not tacctl1(8);

  -- Output unit 2
  ta_out2_mode0 <= tacctl2(2);
  ta_out2_mode1 <= '1'
                   when equ2 else ta_out2;
  ta_out2_mode2 <= not ta_out2
                   when equ2 else '0'
                   when equ0 else ta_out2;
  ta_out2_mode3 <= '1'
                   when equ2 else '0'
                   when equ0 else ta_out2;
  ta_out2_mode4 <= not ta_out2
                   when equ2 else ta_out2;
  ta_out2_mode5 <= '0'
                   when equ2 else ta_out2;
  ta_out2_mode6 <= not ta_out2
                   when equ2 else '1'
                   when equ0 else ta_out2;
  ta_out2_mode7 <= '0'
                   when equ2 else '1'
                   when equ0 else ta_out2;

  ta_out2_nxt <= ta_out2_mode0
                 when (tacctl2(7 downto 5) = "000") else ta_out2_mode1
                 when (tacctl2(7 downto 5) = "001") else ta_out2_mode2
                 when (tacctl2(7 downto 5) = "010") else ta_out2_mode3
                 when (tacctl2(7 downto 5) = "011") else ta_out2_mode4
                 when (tacctl2(7 downto 5) = "100") else ta_out2_mode5
                 when (tacctl2(7 downto 5) = "101") else ta_out2_mode6
                 when (tacctl2(7 downto 5) = "110") else ta_out2_mode7;

  processing_27 : process (mclk, puc_rst)
  begin
    if (puc_rst) then
      ta_out2 <= '0';
    elsif (rising_edge(mclk)) then
      if ((tacctl2(7 downto 5) = "001") and (taclr = '1')) then
        ta_out2 <= '0';
      elsif (tar_clk) then
        ta_out2 <= ta_out2_nxt;
      end if;
    end if;
  end process;

  ta_out2_en <= not tacctl2(8);

  --============================================================================
  -- 9) Timer A interrupt generation
  --============================================================================

  taifg_set <= tar_clk and ((to_stdlogic(tactl(5 downto 4) = "01") and to_stdlogic(tar = taccr0)) or (to_stdlogic(tactl(5 downto 4) = "10") and to_stdlogic(tar = X"ffff")) or (to_stdlogic(tactl(5 downto 4) = "11") and to_stdlogic(tar_nxt = X"0000") and tar_dec));

  ccifg0_set <= cci0_cap
                when tacctl0(8) else (tar_clk and (to_stdlogic(tactl(5 downto 4) /= "00") and equ0));
  ccifg1_set <= cci1_cap
                when tacctl1(8) else (tar_clk and (to_stdlogic(tactl(5 downto 4) /= "00") and equ1));
  ccifg2_set <= cci2_cap
                when tacctl2(8) else (tar_clk and (to_stdlogic(tactl(5 downto 4) /= "00") and equ2));

  irq_ta0 <= (tacctl0(0) and tacctl0(4));
  irq_ta1 <= (tactl (0) and tactl (1)) or
             (tacctl1(0) and tacctl1(4)) or
             (tacctl2(0) and tacctl2(4));
end rtl;
