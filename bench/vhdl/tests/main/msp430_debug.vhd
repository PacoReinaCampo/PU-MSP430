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

entity msp430_debug is
  port (
    -- OUTPUTs
    inst_pc : out std_logic_vector(15 downto 0);  -- Instruction Program counter

    -- INPUTs
    mclk    : in std_logic;             -- Main system clock
    puc_rst : in std_logic);            -- Main system reset  
end msp430_debug;

architecture rtl of msp430_debug is
  constant VXL : std_logic := '0';

  constant DBG_SWBRK_OP : std_logic_vector(15 downto 0) := X"0000";

  --=============================================================================
  -- 1) ASCII FORMATING FUNCTIONS
  --=============================================================================

  -- This function simply concatenates two string(8 downto 0)s together, ignorning the NULL
  -- at the end of string2.
  -- The specified number of space will be inserted between string1 and string2
  function myFormat (
    string1 : string(8 downto 0);
    string2 : string(8 downto 0);
    space   : integer
    ) return string is
    variable myFormat_return : string(8 downto 0);

    variable j : integer;
  begin
    myFormat_return := "         ";
    return myFormat_return;
  end myFormat;

  --=============================================================================
  -- 2) CONNECTIONS TO MSP430 CORE INTERNALS
  --=============================================================================

  signal i_state_bin : std_logic_vector(2 downto 0);
  signal e_state_bin : std_logic_vector(3 downto 0);

  signal decode     : std_logic;
  signal ir         : std_logic_vector(15 downto 0);
  signal irq_detect : std_logic;
  signal irq_num    : std_logic_vector(3 downto 0);
  signal pc         : std_logic_vector(15 downto 0);

  --=============================================================================
  -- 3) GENERATE DEBUG SIGNALS
  --=============================================================================

  -- Instruction fetch state
  --=========================
  signal i_state : string(8 downto 0);

  -- Execution state
  --=========================
  signal e_state : string(8 downto 0);

  -- Count instruction number & cycles
  --====================================
  signal inst_number : std_logic_vector(31 downto 0);
  signal inst_cycle  : std_logic_vector(31 downto 0);

  -- Decode instruction
  --====================================

  -- Buffer opcode
  signal opcode : std_logic_vector(15 downto 0);

  -- Interrupts
  signal irq : std_logic;

  -- Instruction type
  signal inst_type : string(8 downto 0);

  -- Instructions name
  signal inst_name : string(8 downto 0);

  -- Instructions byte/word mode
  signal inst_bw : string(8 downto 0);

  -- Source register
  signal inst_src : string(8 downto 0);
  signal src_reg  : std_logic_vector(3 downto 0);

  -- Destination register
  signal inst_dst : string(8 downto 0);

  -- Source Addressing mode
  signal inst_as : string(8 downto 0);

  -- Destination Addressing mode
  signal inst_ad : string(8 downto 0);

  -- Currently executed instruction
  --================================
  signal inst_short : string(8 downto 0);
  signal inst_full  : string(8 downto 0);

begin
  ----i_state_bin <= msp430_testbench.i_state_bin;
  ----e_state_bin <= msp430_testbench.e_state_bin;
  ----decode      <= msp430_testbench.decode;
  ----ir          <= msp430_testbench.ir;
  ----irq_detect  <= msp430_testbench.irq_detect;
  ----irq_num     <= msp430_testbench.irq_num;
  ----pc          <= msp430_testbench.pc;

  processing_0 : process (i_state_bin)
  begin
    case (i_state_bin) is
      when "000" =>
        i_state <= "IRQ_FETCH";
      when "001" =>
        i_state <= " IRQ_DONE";
      when "010" =>
        i_state <= "      DEC";
      when "011" =>
        i_state <= "     EXT1";
      when "100" =>
        i_state <= "     EXT2";
      when "101" =>
        i_state <= "     IDLE";
      when others =>
        i_state <= "    XXXXX";
    end case;
  end process;

  processing_1 : process (e_state_bin)
  begin
    case (e_state_bin) is
      when X"2" =>
        e_state <= "    IRQ_0";
      when X"1" =>
        e_state <= "    IRQ_1";
      when X"0" =>
        e_state <= "    IRQ_2";
      when X"3" =>
        e_state <= "    IRQ_3";
      when X"4" =>
        e_state <= "    IRQ_4";
      when X"5" =>
        e_state <= "   SRC_AD";
      when X"6" =>
        e_state <= "   SRC_RD";
      when X"7" =>
        e_state <= "   SRC_WR";
      when X"8" =>
        e_state <= "   DST_AD";
      when X"9" =>
        e_state <= "   DST_RD";
      when X"A" =>
        e_state <= "   DST_WR";
      when X"B" =>
        e_state <= "     EXEC";
      when X"C" =>
        e_state <= "     JUMP";
      when X"D" =>
        e_state <= "     IDLE";
      when others =>
        e_state <= "    XXXXX";
    end case;
  end process;

  processing_2 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      inst_number <= (others => '0');
    elsif (rising_edge(mclk)) then
      if (decode = '1') then
        inst_number <= std_logic_vector(unsigned(inst_number)+(to_unsigned(1, 32)));
      end if;
    end if;
  end process;

  processing_3 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      inst_cycle <= (others => '0');
    elsif (rising_edge(mclk)) then
      if (decode = '1') then
        inst_cycle <= (others => '0');
      else
        inst_cycle <= std_logic_vector(unsigned(inst_cycle)+(to_unsigned(1, 32)));
      end if;
    end if;
  end process;

  processing_4 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      opcode <= (others => '0');
    elsif (rising_edge(mclk)) then
      if (decode = '1') then
        opcode <= ir;
      end if;
    end if;
  end process;

  processing_5 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      irq <= '1';
    elsif (rising_edge(mclk)) then
      if (decode = '1') then

        irq <= irq_detect;
      end if;
    end if;
  end process;

  processing_6 : process (opcode, irq)
  begin
    if (irq) then
      inst_type <= "      IRQ";
    else
      case (opcode(15 downto 13)) is
        when "000" =>
          inst_type <= "   SIG-OP";
        when "001" =>
          inst_type <= "     JUMP";
        when others =>
          inst_type <= "   TWO-OP";
      end case;
    end if;
  end process;

  processing_7 : process (opcode, inst_type, irq_num)
  begin
    if (inst_type = "      IRQ") then
      case (irq_num(3 downto 0)) is
        when "0000" =>
          inst_name <= "    IRQ 0";
        when "0001" =>
          inst_name <= "    IRQ 1";
        when "0010" =>
          inst_name <= "    IRQ 2";
        when "0011" =>
          inst_name <= "    IRQ 3";
        when "0100" =>
          inst_name <= "    IRQ 4";
        when "0101" =>
          inst_name <= "    IRQ 5";
        when "0110" =>
          inst_name <= "    IRQ 6";
        when "0111" =>
          inst_name <= "    IRQ 7";
        when "1000" =>
          inst_name <= "    IRQ 8";
        when "1001" =>
          inst_name <= "    IRQ 9";
        when "1010" =>
          inst_name <= "   IRQ 10";
        when "1011" =>
          inst_name <= "   IRQ 11";
        when "1100" =>
          inst_name <= "   IRQ 12";
        when "1101" =>
          inst_name <= "   IRQ 13";
        when "1110" =>
          inst_name <= "      NMI";
        when others =>
          inst_name <= "    RESET";
      end case;
    elsif (inst_type = "   SIG-OP") then
      case (opcode(15 downto 7)) is
        when "000100000" =>
          inst_name <= "      RRC";
        when "000100001" =>
          inst_name <= "     SWPB";
        when "000100010" =>
          inst_name <= "      RRA";
        when "000100011" =>
          inst_name <= "      SXT";
        when "000100100" =>
          inst_name <= "     PUSH";
        when "000100101" =>
          inst_name <= "     CALL";
        when "000100110" =>
          inst_name <= "     RETI";
        when others =>
          inst_name <= "     XXXX";
      end case;
    elsif (inst_type = "     JUMP") then
      case (opcode(15 downto 10)) is
        when "001000" =>
          inst_name <= "      JNE";
        when "001001" =>
          inst_name <= "      JEQ";
        when "001010" =>
          inst_name <= "      JNC";
        when "001011" =>
          inst_name <= "       JC";
        when "001100" =>
          inst_name <= "       JN";
        when "001101" =>
          inst_name <= "      JGE";
        when "001110" =>
          inst_name <= "       JL";
        when "001111" =>
          inst_name <= "      JMP";
        when others =>
          inst_name <= "     XXXX";
      end case;
    elsif (inst_type = "   TWO-OP") then
      case (opcode(15 downto 12)) is
        when "0100" =>
          inst_name <= "      MOV";
        when "0101" =>
          inst_name <= "      ADD";
        when "0110" =>
          inst_name <= "     ADDC";
        when "0111" =>
          inst_name <= "     SUBC";
        when "1000" =>
          inst_name <= "      SUB";
        when "1001" =>
          inst_name <= "      CMP";
        when "1010" =>
          inst_name <= "     DADD";
        when "1011" =>
          inst_name <= "      BIT";
        when "1100" =>
          inst_name <= "      BIC";
        when "1101" =>
          inst_name <= "      BIS";
        when "1110" =>
          inst_name <= "      XOR";
        when "1111" =>
          inst_name <= "      AND";
        when others =>
          inst_name <= "     XXXX";
      end case;
    end if;
  end process;

  processing_8 : process (opcode, inst_type)
  begin
    if (inst_type = "      IRQ") then
      inst_bw <= "         ";
    elsif (inst_type = "   SIG-OP") then
      if (opcode(6)) then
        inst_bw <= "       .B";
      else
        inst_bw <= "         ";
      end if;
    elsif (inst_type = "     JUMP") then
      inst_bw <= "         ";
    elsif (inst_type = "   TWO-OP") then
      if (opcode(6)) then
        inst_bw <= "       .B";
      else
        inst_bw <= "         ";
      end if;
    end if;
  end process;

  src_reg <= opcode(3 downto 0) when (inst_type = "   SIG-OP") else opcode(11 downto 8);

  processing_9 : process (src_reg, inst_type)
  begin
    if (inst_type = "      IRQ") then
      inst_src <= "         ";
    elsif (inst_type = "     JUMP") then
      inst_src <= "         ";
    elsif ((inst_type = "   SIG-OP") or (inst_type = "   TWO-OP")) then
      case (src_reg) is
        when "0000" =>
          inst_src <= "       r0";
        when "0001" =>
          inst_src <= "       r1";
        when "0010" =>
          inst_src <= "       r2";
        when "0011" =>
          inst_src <= "       r3";
        when "0100" =>
          inst_src <= "       r4";
        when "0101" =>
          inst_src <= "       r5";
        when "0110" =>
          inst_src <= "       r6";
        when "0111" =>
          inst_src <= "       r7";
        when "1000" =>
          inst_src <= "       r8";
        when "1001" =>
          inst_src <= "       r9";
        when "1010" =>
          inst_src <= "      r10";
        when "1011" =>
          inst_src <= "      r11";
        when "1100" =>
          inst_src <= "      r12";
        when "1101" =>
          inst_src <= "      r13";
        when "1110" =>
          inst_src <= "      r14";
        when others =>
          inst_src <= "      r15";
      end case;
    end if;
  end process;

  processing_10 : process (opcode, inst_type)
  begin
    if (inst_type = "      IRQ") then
      inst_dst <= "         ";
    elsif (inst_type = "   SIG-OP") then
      inst_dst <= "         ";
    elsif (inst_type = "     JUMP") then
      inst_dst <= "         ";
    elsif (inst_type = "   TWO-OP") then
      case (opcode(3 downto 0)) is
        when "0000" =>
          inst_dst <= "       r0";
        when "0001" =>
          inst_dst <= "       r1";
        when "0010" =>
          inst_dst <= "       r2";
        when "0011" =>
          inst_dst <= "       r3";
        when "0100" =>
          inst_dst <= "       r4";
        when "0101" =>
          inst_dst <= "       r5";
        when "0110" =>
          inst_dst <= "       r6";
        when "0111" =>
          inst_dst <= "       r7";
        when "1000" =>
          inst_dst <= "       r8";
        when "1001" =>
          inst_dst <= "       r9";
        when "1010" =>
          inst_dst <= "      r10";
        when "1011" =>
          inst_dst <= "      r11";
        when "1100" =>
          inst_dst <= "      r12";
        when "1101" =>
          inst_dst <= "      r13";
        when "1110" =>
          inst_dst <= "      r14";
        when others =>
          inst_dst <= "      r15";
      end case;
    end if;
  end process;

  processing_11 : process (inst_type, src_reg, opcode, inst_src)
  begin
    if (inst_type = "      IRQ") then
      inst_as <= "         ";
    elsif (inst_type = "     JUMP") then
      inst_as <= "         ";
    elsif (src_reg = X"3") then         -- Addressing mode using R3
      case (opcode(5 downto 4)) is
        when "11" =>
          inst_as <= "      #-1";
        when "10" =>
          inst_as <= "       #2";
        when "01" =>
          inst_as <= "       #1";
        when others =>
          inst_as <= "       #0";
      end case;
    elsif (src_reg = X"2") then         -- Addressing mode using R2
      case (opcode(5 downto 4)) is
        when "11" =>
          inst_as <= "       #8";
        when "10" =>
          inst_as <= "       #4";
        when "01" =>
          inst_as <= "     &EDE";
        when others =>
          inst_as <= inst_src;
      end case;
    elsif (src_reg = X"0") then         -- Addressing mode using R0
      case (opcode(5 downto 4)) is
        when "11" =>
          inst_as <= "       #N";
        when "10" =>
          inst_as <= myFormat("        @", inst_src, 0);
        when "01" =>
          inst_as <= "      EDE";
        when others =>
          inst_as <= inst_src;
      end case;
    else                                -- General Addressing mode
      case (opcode(5 downto 4)) is
        when "11" =>
          inst_as <= myFormat("        @", inst_src, 0);
          inst_as <= myFormat(inst_as, "    +    ", 0);
        when "10" =>
          inst_as <= myFormat("        @", inst_src, 0);
        when "01" =>
          inst_as <= myFormat("       x(", inst_src, 0);
          inst_as <= myFormat(inst_as, ")        ", 0);
        when others =>
          inst_as <= inst_src;
      end case;
    end if;
  end process;

  processing_12 : process (opcode, inst_type, inst_dst)
  begin
    if (inst_type /= "   TWO-OP") then
      inst_ad <= "         ";
    elsif (opcode(3 downto 0) = X"2") then  -- Addressing mode using R2
      case (opcode(7)) is
        when '1' =>
          inst_ad <= "     &EDE";
        when others =>
          inst_ad <= inst_dst;
      end case;
    elsif (opcode(3 downto 0) = X"0") then  -- Addressing mode using R0
      case (opcode(7)) is
        when '1' =>
          inst_ad <= "      EDE";
        when others =>
          inst_ad <= inst_dst;
      end case;
    else                                    -- General Addressing mode
      case (opcode(7)) is
        when '1' =>
          inst_ad <= myFormat("       x(", inst_dst, 0);
          inst_ad <= myFormat(inst_ad, ")        ", 0);
        when others =>
          inst_ad <= inst_dst;
      end case;
    end if;
  end process;

  inst_short <= inst_name;

  processing_13 : process (inst_type, inst_name, inst_bw, inst_as, inst_ad)
  begin
    inst_full <= myFormat(inst_name, inst_bw, 0);
    inst_full <= myFormat(inst_full, inst_as, 1);
    if (inst_type = "   TWO-OP") then
      inst_full <= myFormat(inst_full, "    ,    ", 0);
    end if;
    inst_full <= myFormat(inst_full, inst_ad, 1);
    if (opcode = X"4303") then
      inst_full <= "      NOP";
    end if;
    if (opcode = DBG_SWBRK_OP) then
      inst_full <= "   SBREAK";
    end if;
  end process;

  processing_14 : process (mclk, puc_rst)
  begin
    if (puc_rst = '1') then
      inst_pc <= X"0000";
    elsif (rising_edge(mclk)) then
      if (decode = '1') then
        inst_pc <= pc;
      end if;
    end if;
  end process;
end rtl;
