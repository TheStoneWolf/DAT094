-- DAT094 - Lab 1a
--
-- Data conversion example.
--
-- Author:  Erik Börjeson
-- Date:    2023-08-28
-- Version: 1.0
--
library ieee;
use ieee.std_logic_1164.all;

entity convert_data_format is
  generic(SIGNAL_WIDTH : integer := 4);
  port(input   : in  std_logic_vector(SIGNAL_WIDTH-1 downto 0);
       convert : in  std_logic;
       output  : out std_logic_vector(SIGNAL_WIDTH-1 downto 0));
end entity convert_data_format;

architecture convert_data_format_arch of convert_data_format is
begin
  
  output <= not(input(SIGNAL_WIDTH-1)) & input(SIGNAL_WIDTH-2 downto 0) when (convert = '1')
            else input;
  
end architecture convert_data_format_arch;
