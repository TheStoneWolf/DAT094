-- DAT094 - Lab 2a
--
-- Testbench for the FIR filter tap
--
-- Author:  Erik Borjeson
-- Date:    2023-09-13
-- Version: 1.1
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.testbench_support_pkg.all;

entity fir_tap_tb is
end entity fir_tap_tb;

architecture fir_tap_tb_arch of fir_tap_tb is

  -- Constant declarations
  constant DATA_WIDTH : positive := 4;
  constant COEF_WIDTH : positive := 4;
  constant TESTS_N    : positive := 15;      -- Number of input data points (11 originally)
  constant DELAY      : time     := 100 ns;  -- Time between inputs

  -- Component declarations
  component fir_tap is
    generic(DATA_WIDTH : positive;
            COEF_WIDTH : positive);
    port (data        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
          coefficient : in  std_logic_vector(COEF_WIDTH-1 downto 0);
          prev_result : in  std_logic_vector(DATA_WIDTH+COEF_WIDTH-2 downto 0);
          result      : out std_logic_vector(DATA_WIDTH+COEF_WIDTH-2 downto 0));
  end component fir_tap;

  -- Signal declarations
  signal data        : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal coefficient : std_logic_vector(COEF_WIDTH-1 downto 0);
  signal prev_result : std_logic_vector(DATA_WIDTH+COEF_WIDTH-2 downto 0);
  signal result      : std_logic_vector(DATA_WIDTH+COEF_WIDTH-2 downto 0);

  -- Arrays to store input and reference data
  type data_array_type is array (0 to TESTS_N-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  constant DATA_ARRAY : data_array_type := ("0110",
                                            "0110",
                                            "0110",
                                            "0110",
                                            "1101",
                                            "1101",
                                            "1101",
                                            "1101",
                                            "1101",
                                            "1101",
                                            "1101",
					    "1101", --new
					    "0111",
					    "0111",
					    "0111");


  type coefficient_array_type is array (0 to TESTS_N-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  constant COEFFICIENT_ARRAY : coefficient_array_type := ("0000",
                                                          "0000",
                                                          "0011",
                                                          "0011",
                                                          "0000",
                                                          "0000",
                                                          "0011",
                                                          "0011",
                                                          "0000",
                                                          "1110",
                                                          "1110",
							  "1101", --new
							  "0111",
							  "0111",
							  "0111");

  type prev_result_array_type is array (0 to TESTS_N-1) of std_logic_vector(DATA_WIDTH+COEF_WIDTH-2 downto 0);
  constant PREV_RESULT_ARRAY : prev_result_array_type := ("0000000",
                                                          "0000111",
                                                          "0000000",
                                                          "0000111",
                                                          "0000000",
                                                          "0000111",
                                                          "0000000",
                                                          "0000111",
                                                          "1111110",
                                                          "0000000",
                                                          "1111110",
							  "0000000", --new
							  "0000000",
						 	  "0100000",
							  "1000001");

  type result_array_type is array (0 to TESTS_N-1) of std_logic_vector(DATA_WIDTH+COEF_WIDTH-2 downto 0);
  constant RESULT_ARRAY : result_array_type := ("0000000",
                                                "0000111",
                                                "0010010",
                                                "0011001",
                                                "0000000",
                                                "0000111",
                                                "1110111",
                                                "1111110",
                                                "1111110",
                                                "0000110",
                                                "0000100",
						"0101001", --new
						"0110001",
						"-------",
						"-------");
begin

  -- Component instantiation
  fir_tap_inst : component fir_tap
    generic map (DATA_WIDTH => DATA_WIDTH,
                 COEF_WIDTH => COEF_WIDTH)
    port map (data        => data,
              coefficient => coefficient,
              prev_result => prev_result,
              result      => result);

  -- Set input values
  inputs_proc : process
  begin
    for idx in 0 to TESTS_N-1 loop
      data        <= DATA_ARRAY(idx);
      coefficient <= COEFFICIENT_ARRAY(idx);
      prev_result <= PREV_RESULT_ARRAY(idx);
      wait for DELAY;
    end loop;
    wait;
  end process inputs_proc;

  -- Verify output values
  verification_proc : process
  begin
    for idx in 0 to TESTS_N-1 loop
      wait for DELAY/2;
      assert result = RESULT_ARRAY(idx)
        report "Error in result for data=" & to_string(DATA_ARRAY(idx)) &
        ", coefficient=" & to_string(COEFFICIENT_ARRAY(idx)) & ", and prev_result=" &
        to_string(PREV_RESULT_ARRAY(idx)) & ". The result is " &
        to_string(result) & ", but it should be " & to_string(RESULT_ARRAY(idx))
        severity warning;
      wait for DELAY/2;
    end loop;
    -- Force testbench to stop when all tests are done
    report "Testbech finished!" severity failure;
  end process verification_proc;
  
end architecture fir_tap_tb_arch;
