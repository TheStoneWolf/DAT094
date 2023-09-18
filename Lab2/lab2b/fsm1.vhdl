-- fsm1 for shifting out the data bits. / ljs Sep 13 2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm1 is
  generic (width : natural range 1 to 16);
  port (d      : in  std_logic_vector(width - 1 downto 0);
        clk    : in  std_logic;
        enable : in  std_logic;
        reset  : in  std_logic;
        load   : in  std_logic;
        start  : in  std_logic;
        shout  : out std_logic;
        done   : out std_logic);
end entity fsm1;
