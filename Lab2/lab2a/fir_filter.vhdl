-- DAT094 - Lab 2a
--
-- FIR filter implemented using for...generate and component instantiation.
--
-- For simplicity the filter does not support filters with a gain > 1 and does
-- not have any overflow checking.
--
-- Author:  Erik Borjeson
-- Date:    2023-09-13
-- Version: 1.1
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter is
  generic (DATA_WIDTH : positive := 8);
  port (clk    : in  std_logic;
        rst    : in  std_logic;
        enable : in  std_logic;
        input  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        output : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity fir_filter;

architecture arch of fir_filter is

  constant TAPS_N     : positive := 9;
  constant COEF_WIDTH : positive := 8;

  -- Tap values calculated in MATLAB to be a lowpass filter with an approximate
  -- cutoff frequency of 0.16Fs, where Fs is the sample rate.
  type coefficients_type is array (0 to TAPS_N-1) of std_logic_vector(COEF_WIDTH-1 downto 0);
  constant COEFFICIENTS : coefficients_type := ("11111101",
                                                "11111010",
                                                "00000110",
                                                "00100110",
                                                "00111001",
                                                "00100110",
                                                "00000110",
                                                "11111010",
                                                "11111101");

  type input_buffer_type is array (0 to TAPS_N-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal input_buffer : input_buffer_type;

  type results_type is array (-1 to TAPS_N-1) of std_logic_vector(DATA_WIDTH+COEF_WIDTH-2 downto 0);
  signal results : results_type;

  -- Component declarations
  component fir_tap is
    generic(DATA_WIDTH : positive;
            COEF_WIDTH : positive);
    port (data        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
          coefficient : in  std_logic_vector(COEF_WIDTH-1 downto 0);
          prev_result : in  std_logic_vector(DATA_WIDTH+COEF_WIDTH-2 downto 0);
          result      : out std_logic_vector(DATA_WIDTH+COEF_WIDTH-2 downto 0));
  end component fir_tap;

begin

  -- Input registers and buffer to store old input values.
  input_reg_proc : process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        input_buffer <= (others => (others => '0'));
      elsif enable = '1' then
        input_buffer(0) <= input;
        for tap_idx in 1 to input_buffer'high loop
          input_buffer(tap_idx) <= input_buffer(tap_idx-1);
        end loop;
      end if;
    end if;
  end process input_reg_proc;

  -- Previous input to first FIR tap is zero.
  results(-1) <= (others => '0');

  -- Generate all FIR taps.
  fir_taps_gen : for tap_idx in 0 to TAPS_N-1 generate
    fir_tap_inst : component fir_tap
      generic map (DATA_WIDTH => DATA_WIDTH,
                   COEF_WIDTH => COEF_WIDTH)
      port map (data        => input_buffer(tap_idx),
                coefficient => COEFFICIENTS(tap_idx),
                prev_result => results(tap_idx-1),
                result      => results(tap_idx));
  end generate fir_taps_gen;

  -- Output is the MSBs of the result from the last filter tap.
  output <= results(TAPS_N-1)(results(TAPS_N-1)'left downto results(TAPS_N-1)'left-DATA_WIDTH+1);
  
end architecture arch;
