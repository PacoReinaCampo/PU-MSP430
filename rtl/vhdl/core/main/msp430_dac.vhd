-- Converted from msp430_dac.sv
-- by verilog2vhdl - QueenField

--//////////////////////////////////////////////////////////////////////////////
--                                            __ _      _     _               //
--                                           / _(_)    | |   | |              //
--                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
--               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
--              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
--               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
--                  | |                                                       //
--                  |_|                                                       //
--                                                                            //
--                                                                            //
--              MSP430 CPU                                                    //
--              Processing Unit                                               //
--                                                                            //
--//////////////////////////////////////////////////////////////////////////////

-- Copyright (c) 2015-2016 by the author(s)
-- *
-- * Redistribution and use in source and binary forms, with or without
-- * modification, are permitted provided that the following conditions
-- * are met:
-- *     * Redistributions of source code must retain the above copyright
-- *       notice, this list of conditions and the following disclaimer.
-- *     * Redistributions in binary form must reproduce the above copyright
-- *       notice, this list of conditions and the following disclaimer in the
-- *       documentation and/or other materials provided with the distribution.
-- *     * Neither the name of the authors nor the names of its contributors
-- *       may be used to endorse or promote products derived from this software
-- *       without specific prior written permission.
-- *
-- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
-- * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
-- * THE POSSIBILITY OF SUCH DAMAGE
-- *
-- * =============================================================================
-- * Author(s):
-- *   Olivier Girard <olgirard@gmail.com>
-- *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
-- */

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.msp430_pkg.all;

entity msp430_dac is
  generic (
    -- Serial clock divider (Tsclk=Tmclk*(SCLK_DIV+1)*2)
    constant SCLK_DIV  : integer := 0;

    -- Registers base address
    constant BASE_ADDR : std_logic_vector(15 downto 0) := X"0190"
    );
  port (
    -- OUTPUTs
    cntrl1   : out std_logic_vector(15 downto 0);  -- Control value 1
    cntrl2   : out std_logic_vector(15 downto 0);  -- Control value 2
    din      : out std_logic;                      -- SPI Serial Data
    per_dout : out std_logic_vector(15 downto 0);  -- Peripheral data output
    sclk     : out std_logic;                      -- SPI Serial Clock
    sync_n   : out std_logic;                      -- SPI Frame synchronization signal (low active)

    -- INPUTs
    mclk     : in std_logic;                      -- Main system clock
    per_addr : in std_logic_vector(13 downto 0);  -- Peripheral address
    per_din  : in std_logic_vector(15 downto 0);  -- Peripheral data input
    per_en   : in std_logic;                      -- Peripheral enable (high active)
    per_we   : in std_logic_vector(1 downto 0);   -- Peripheral write enable (high active)
    puc_rst  : in std_logic                       -- Main system reset
    );
end msp430_dac;

architecture RTL of msp430_dac is

  --=============================================================================
  -- 1)  PARAMETER DECLARATION
  --=============================================================================

  -- Decoder bit width (defines how many bits are considered for address decoding)
  constant DEC_WD : integer := 3;

  -- Register addresses offset
  constant DAC_VALX  : integer := 0;
  constant DAC_STATX : integer := 3;
  constant CNTRLX1   : integer := 4;
  constant CNTRLX2   : integer := 6;
  
  -- Register one-hot decoder utilities
  constant DEC_SZ   : integer                             := 2**DEC_WD;
  constant BASE_REG : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(to_unsigned(1, DEC_SZ));

  -- Register one-hot decoder
  constant DAC_VAL_D  : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG) sll DAC_VALX);
  constant DAC_STAT_D : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG) sll DAC_STATX);
  constant CNTRL1_D   : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG) sll CNTRLX1);
  constant CNTRL2_D   : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(unsigned(BASE_REG) sll CNTRLX2);

  constant DAC_VAL_X  : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(to_unsigned(DAC_VALX, DEC_SZ));
  constant DAC_STAT_X : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(to_unsigned(DAC_STATX, DEC_SZ));
  constant CNTRL1_X   : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(to_unsigned(CNTRLX1, DEC_SZ));
  constant CNTRL2_X   : std_logic_vector(DEC_SZ-1 downto 0) := std_logic_vector(to_unsigned(CNTRLX2, DEC_SZ));

  --============================================================================
  -- 2)  REGISTER DECODER
  --============================================================================

  -- Local register selection
  signal reg_sel : std_logic;

  -- Register local address
  signal reg_addr : std_logic_vector(DEC_WD-1 downto 0);

  -- Register address decode
  signal reg_dec   : std_logic_vector(DEC_SZ-1 downto 0);
  -- Read/Write probes
  signal reg_write : std_logic;
  signal reg_read  : std_logic;

  -- Read/Write vectors
  signal reg_wr : std_logic_vector(DEC_SZ-1 downto 0);
  signal reg_rd : std_logic_vector(DEC_SZ-1 downto 0);

  --============================================================================
  -- 3) REGISTERS
  --============================================================================

  -- DAC_VAL Register
  signal dac_val : std_logic_vector(11 downto 0);
  signal dac_pd0 : std_logic;
  signal dac_pd1 : std_logic;

  signal dac_val_wr : std_logic;

  -- CNTRL1 Register
  signal cntrl1_wr : std_logic;

  -- CNTRL2 Register
  signal cntrl2_wr : std_logic;

  --============================================================================
  -- 4) DATA OUTPUT GENERATION
  --============================================================================

  -- Data output mux
  signal dac_val_rd  : std_logic_vector(15 downto 0);
  signal dac_stat_rd : std_logic_vector(15 downto 0);
  signal cntrl1_rd   : std_logic_vector(15 downto 0);
  signal cntrl2_rd   : std_logic_vector(15 downto 0);

  --============================================================================
  -- 5) SPI INTERFACE
  --============================================================================

  -- SPI Clock divider
  signal spi_clk_div : std_logic_vector(3 downto 0);

  -- SPI Clock generation
  signal sclk_re : std_logic;

  -- SPI Transfer trigger
  signal spi_tfx_trig : std_logic;

  signal spi_tfx_init : std_logic;

  -- Data counter
  signal spi_cnt      : std_logic_vector(3 downto 0);
  signal spi_cnt_done : std_logic;

  -- Frame synchronization signal (low active)

  -- Value to be shifted_out
  signal dac_shifter : std_logic_vector(15 downto 0);

  signal cntrl1_s : std_logic_vector(15 downto 0);
  signal cntrl2_s : std_logic_vector(15 downto 0);

  signal sclk_s   : std_logic;
  signal sync_n_s : std_logic;

begin

  reg_sel  <= per_en and to_stdlogic(per_addr(13 downto DEC_WD-1) = BASE_ADDR(14 downto DEC_WD));
  reg_addr <= (per_addr(DEC_WD-2 downto 0) & '0');
  reg_dec  <= (DAC_VAL_D and (DEC_SZ-1 downto 0 => to_stdlogic(reg_addr = DAC_VAL_X))) or
              (DAC_STAT_D and (DEC_SZ-1 downto 0 => to_stdlogic(reg_addr = DAC_STAT_X))) or
              (CNTRL1_D and (DEC_SZ-1 downto 0 => to_stdlogic(reg_addr = CNTRL1_X))) or
              (CNTRL2_D and (DEC_SZ-1 downto 0 => to_stdlogic(reg_addr = CNTRL2_X)));

  reg_write  <= reduce_or(per_we) and reg_sel;
  reg_read   <= reduce_nor(per_we) and reg_sel;
  reg_wr     <= reg_dec and (DEC_SZ-1 downto 0 => reg_write);
  reg_rd     <= reg_dec and (DEC_SZ-1 downto 0 => reg_read);
  dac_val_wr <= reg_wr(DAC_VALX);

  processing_0 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      dac_val <= X"000";
      dac_pd0 <= '0';
      dac_pd1 <= '0';
    elsif (rising_edge(mclk)) then
      if (dac_val_wr = '1') then
        dac_val <= per_din(11 downto 0);
        dac_pd0 <= per_din(12);
        dac_pd1 <= per_din(13);
      end if;
    end if;
  end process;

  cntrl1_wr <= reg_wr(CNTRLX1);

  processing_1 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      cntrl1_s <= X"0000";
    elsif (rising_edge(mclk)) then
      if (cntrl1_wr = '1') then
        cntrl1_s <= per_din;
      end if;
    end if;
  end process;

  cntrl2_wr <= reg_wr(CNTRLX2);

  processing_2 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      cntrl2_s <= X"0000";
    elsif (rising_edge(mclk)) then
      if (cntrl2_wr = '1') then
        cntrl2_s <= per_din;
      end if;
    end if;
  end process;

  dac_val_rd  <= ("00" & dac_pd1 & dac_pd0 & dac_val) and (15 downto 0 => reg_rd(DAC_VALX));
  dac_stat_rd <= ("000000000000000" & not sync_n_s) and (15 downto 0 => reg_rd(DAC_STATX));
  cntrl1_rd   <= cntrl1_s and (15 downto 0 => reg_rd(CNTRLX1));
  cntrl2_rd   <= cntrl2_s and (15 downto 0 => reg_rd(CNTRLX2));
  per_dout    <= dac_val_rd or dac_stat_rd or cntrl1_rd or cntrl2_rd;

  processing_3 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      spi_clk_div <= std_logic_vector(to_unsigned(SCLK_DIV, 4));
    elsif (rising_edge(mclk)) then
      if (spi_clk_div = "0000") then
        spi_clk_div <= std_logic_vector(to_unsigned(SCLK_DIV, 4));
      else
        spi_clk_div <= std_logic_vector(unsigned(spi_clk_div)-"0001");
      end if;
    end if;
  end process;

  processing_4 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      sclk <= '0';
    elsif (rising_edge(mclk)) then
      if (spi_clk_div = "0000") then
        sclk_s <= not sclk_s;
      end if;
    end if;
  end process;
  sclk_re <= to_stdlogic(spi_clk_div = "0000") and not sclk_s;

  processing_5 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      spi_tfx_trig <= '0';
    elsif (rising_edge(mclk)) then
      if (dac_val_wr = '1') then
        spi_tfx_trig <= '1';
      elsif (sclk_re = '1' and sync_n_s = '1') then
        spi_tfx_trig <= '0';
      end if;
    end if;
  end process;

  spi_tfx_init <= spi_tfx_trig and sync_n_s;
  spi_cnt_done <= to_stdlogic(spi_cnt = X"f");

  processing_6 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      spi_cnt <= X"f";
    elsif (rising_edge(mclk)) then
      if (sclk_re = '1') then
        if (spi_tfx_init = '1') then
          spi_cnt <= X"e";
        elsif (spi_cnt_done = '0') then
          spi_cnt <= std_logic_vector(unsigned(spi_cnt)-"0001");
        end if;
      end if;
    end if;
  end process;

  processing_7 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      sync_n <= '1';
    elsif (rising_edge(mclk)) then
      if (sclk_re = '1') then
        if (spi_tfx_init = '1') then
          sync_n <= '0';
        elsif (spi_cnt_done = '1') then
          sync_n <= '1';
        end if;
      end if;
    end if;
  end process;

  processing_8 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      dac_shifter <= X"0000";
    elsif (rising_edge(mclk)) then
      if (sclk_re = '1') then
        if (spi_tfx_init = '1') then
          dac_shifter <= ("00" & dac_pd1 & dac_pd0 & dac_val(11 downto 0));
        else
          dac_shifter <= (dac_shifter(14 downto 0) & '0');
        end if;
      end if;
    end if;
  end process;

  din <= dac_shifter(15);

  cntrl1 <= cntrl1_s;
  cntrl2 <= cntrl2_s;

  sclk   <= sclk_s;
  sync_n <= sync_n_s;
end RTL;
