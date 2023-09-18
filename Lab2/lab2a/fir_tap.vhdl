-- DAT094 - Lab 2a
--
-- FIR filter tap
--
-- Author:  Erik Borjeson
-- Date:    2023-09-13
-- Version: 1.1
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_tap is
  generic(DATA_WIDTH : positive := 12;
          COEF_WIDTH : positive := 12);
  port (data        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        coefficient : in  std_logic_vector(COEF_WIDTH-1 downto 0);
        prev_result : in  std_logic_vector(DATA_WIDTH+COEF_WIDTH-2 downto 0);
        result      : out std_logic_vector(DATA_WIDTH+COEF_WIDTH-2 downto 0));
end entity fir_tap;

architecture fir_tap_arch of fir_tap is
  signal product : signed(DATA_WIDTH+COEF_WIDTH-1 downto 0);
begin

  product <= signed(data)*signed(coefficient);
  result  <= std_logic_vector(product(product'left-1 downto product'right) + signed(prev_result));
  
end architecture fir_tap_arch;




