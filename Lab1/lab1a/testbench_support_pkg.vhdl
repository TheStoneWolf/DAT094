-- DAT094
--
-- Testbench support package with functions to convert vectors to strings.
-- Currently supported types are:
--   std_logic
--   std_logic_vector
--   unsigned
--   signed
--
-- Author:  Erik Börjeson
-- Date:    2023-08-28
-- Version: 1.0
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package testbench_support_pkg is

  function to_string(input : std_logic) return string;
  function to_string(input : std_logic_vector) return string;
  function to_string(input : unsigned) return string;
  function to_string(input : signed) return string;

end package testbench_support_pkg;

package body testbench_support_pkg is

  -- Convert a std_logic to a one character string, all possible values included.
  function to_string(input : std_logic) return string is
  begin
    case input is
      when 'U'    => return "U";
      when 'X'    => return "X";
      when '0'    => return "0";
      when '1'    => return "1";
      when 'Z'    => return "Z";
      when 'W'    => return "W";
      when 'L'    => return "L";
      when 'H'    => return "H";
      when '-'    => return "-";
      when others => return " ";
    end case;
  end function to_string;

  -- Convert a std_logic to a string. This function apply to_string(input : std_logic)
  -- to each bit in the vector. It supports both std_logic_vector(A to B) and
  -- (A downto B) by checking the ascending attribute of the input signal. 
  function to_string(input : std_logic_vector) return string is
    variable result : string(1 to input'length);
  begin
    if input'ascending then
      for idx in input'range loop
        result(idx+1) := to_string(input(idx))(1);
      end loop;
    else
      for idx in input'range loop
        result(input'length-idx) := to_string(input(idx))(1);
      end loop;
    end if;
    return result;
  end function to_string;

  -- Convert an unsigned to a string by type casting the input to a std_logic_vector
  -- and applying the to_string(input : std_logic_vector) function.
  function to_string(input : unsigned) return string is
  begin
    return to_string(std_logic_vector(input));
  end function to_string;

  -- Convert a signed to a string by type casting the input to a std_logic_vector
  -- and applying the to_string(input : std_logic_vector) function.
  function to_string(input : signed) return string is
  begin
    return to_string(std_logic_vector(input));
  end function to_string;
  
end package body testbench_support_pkg;
