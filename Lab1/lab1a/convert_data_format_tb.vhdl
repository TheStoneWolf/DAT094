-- DAT094 - Lab 1a
--
-- Testbench for the data conversion example.
--
-- Author:  Erik Börjeson
-- Date:    2023-08-28
-- Version: 1.0
--
library ieee;
use ieee.std_logic_1164.all;
use work.testbench_support_pkg.all;

entity convert_data_format_tb is
end entity convert_data_format_tb;

architecture convert_data_format_tb_arch of convert_data_format_tb is

  -- Constant declarations
  constant SIGNAL_WIDTH : positive := 4;

  -- Component declarations
  component convert_data_format is
    generic(SIGNAL_WIDTH : integer);
    port(input   : in  std_logic_vector(SIGNAL_WIDTH-1 downto 0);
         convert : in  std_logic;
         output  : out std_logic_vector(SIGNAL_WIDTH-1 downto 0));
  end component convert_data_format;

  -- Signal declarations
  signal input   : std_logic_vector(SIGNAL_WIDTH-1 downto 0);
  signal convert : std_logic;
  signal output  : std_logic_vector(SIGNAL_WIDTH-1 downto 0);
  
begin

  -- Component instantiation
  convert_data_format_inst : component convert_data_format
    generic map(SIGNAL_WIDTH => SIGNAL_WIDTH)
    port map(input   => input,
             convert => convert,
             output  => output);

  -- Set input values
  input <= "0110",
           "1110" after 100 ns,
           "0110" after 200 ns,
           "1110" after 300 ns;
  
  convert <= '0',
             '1' after 200 ns;

  -- Verify output values
  verification_proc : process
  begin
    wait for 50 ns;                     -- 50 ns 0110
    assert (output = "0110")
      report "Error for input " & to_string(input) &
      ": The output value is " & to_string(output) &
      ", but it should be " & "0110"
      severity warning;
    wait for 100 ns;                    -- 150 ns 1110
    assert (output = "1110")
      report "Error for input " & to_string(input) &
      ": The output value is " & to_string(output) &
      ", but it should be " & "1110"
      severity warning;
    wait for 100 ns;                    -- 250 ns 0110
    assert (output = "1110")
      report "Error for input " & to_string(input) &
      ": The output value is " & to_string(output) &
      ", but it should be " & "1110"
      severity warning;
    wait for 100 ns;                    -- 350 ns 1110
    assert (output = "0110")
      report "Error for input " & to_string(input) &
      ": The output value is " & to_string(output) &
      ", but it should be " & "0110"
      severity warning;
    wait for 50 ns;
    -- Force testbench to stop after 400 ns
    report "Testbech finished!" severity failure;
  end process verification_proc;

end architecture convert_data_format_tb_arch;
