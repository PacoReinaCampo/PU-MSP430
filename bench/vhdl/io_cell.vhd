library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity io_cell is
  port (
    -- INOUTs
    pad : inout std_logic;              -- I/O Pad

    -- OUTPUTs
    data_in : out std_logic;            -- Input value

    -- INPUTs
    data_out_en : in std_logic;         -- Output enable
    data_out    : in std_logic          -- Output value
    );
end io_cell;

architecture RTL of io_cell is
begin
  -- I/O CELL
  data_in <= pad;
  pad     <= data_out when data_out_en else 'z';
end RTL;
