-- DAT094 - Lab 2a
--
-- Testbench for the FIR filter generating a new input every INPUT_DELAY clock
-- cycle. The input and output reference data was generated in MATLAB and converted
-- to binary.  
--
-- Author:  Erik Borjeson
-- Date:    2023-09-13
-- Version: 1.1
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.testbench_support_pkg.all;

entity fir_filter_tb is
end fir_filter_tb;

architecture fir_filter_tb_arch of fir_filter_tb is

  -- Constant declarations
  constant DATA_WIDTH   : integer  := 8;
  constant PERIOD       : time     := 10 ns;
  constant INPUT_DELAY  : positive := 1;  -- Clock cycles between input samples
  constant OUTPUT_DELAY : natural  := 0;  -- Number of clock cycles from the
                                          -- input is clock in to the output is
                                          -- clocked out.

  -- Component declarations
  component fir_filter is
    generic (DATA_WIDTH : positive := 8);
    port (clk    : in  std_logic;
          rst    : in  std_logic;
          enable : in  std_logic;
          input  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
          output : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component fir_filter;

  -- Signal declarations
  signal clk    : std_logic := '0';
  signal rst    : std_logic;
  signal enable : std_logic;
  signal input  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal output : std_logic_vector(DATA_WIDTH-1 downto 0);

  -- Input data with 2 superimposed sine waves calculated as 
  --   0.6sin(2*pi*0.1Fs*t) + 0.4sin(2*pi*0.4Fs*t),
  -- where Fs is the sample rate. This data is loopable to create a countinous
  -- waveform. 
  type input_data_type is array (0 to 9) of std_logic_vector(DATA_WIDTH-1 downto 0);
  constant INPUT_DATA : input_data_type := ("00000000",
                                            "01001011",
                                            "00011000",
                                            "01111010",
                                            "00001111",
                                            "00000000",
                                            "11110001",
                                            "10000110",
                                            "11101000",
                                            "10110101");

  -- Expected output for the first 2 loops of the input data.
  type output_expected_type is array (0 to 19) of std_logic_vector(DATA_WIDTH-1 downto 0);
  constant OUTPUT_EXPECTED : output_expected_type := ("00000000",
                                                      "11111110",
                                                      "11111011",
                                                      "11111111",
                                                      "00010001",
                                                      "00101101",
                                                      "01000110",
                                                      "01001000",
                                                      "00101110",
                                                      "00000000",
                                                      "11010001",
                                                      "10110101",
                                                      "10110101",
                                                      "11010001",
                                                      "00000000",
                                                      "00101110",
                                                      "01001010",
                                                      "01001010",
                                                      "00101110",
                                                      "00000000");

begin

  -- Component instantiation
  fir_filter_inst :
    component fir_filter
      generic map(DATA_WIDTH => DATA_WIDTH)
      port map(clk    => clk,
               rst    => rst,
               enable => enable,
               input  => input,
               output => output);

  -- Clock generation
  clk <= not clk after PERIOD/2.0;

  -- Input setup.
  set_inputs_proc : process
  begin
    rst    <= '0';
    input  <= (others => '0');
    enable <= '0';
    wait until rising_edge(clk);        -- Synchronize inputs with clock
    wait for 3.0*PERIOD/4.0;
    rst    <= '1';
    wait for PERIOD;
    rst    <= '0';
    -- Loop over the input data until testbench is stopped.
    while true loop
      for input_idx in 0 to INPUT_DATA'high loop
        input  <= INPUT_DATA(input_idx);
        enable <= '1';
        wait for PERIOD;
        if INPUT_DELAY > 1 then
          enable <= '0';
          wait for (INPUT_DELAY-1)*PERIOD;
        end if;
      end loop;
    end loop;
  end process;

  -- Verify output data
  verification_proc : process
  begin
    -- Wait for first valid filter output
    wait until rising_edge(rst);
    wait until falling_edge(rst);
    wait until rising_edge(clk);        -- Synchronize verification with clock
    wait for 3.0*PERIOD/4.0;
    wait for OUTPUT_DELAY*PERIOD;
    for output_idx in 0 to OUTPUT_EXPECTED'high loop
      assert (output = OUTPUT_EXPECTED(output_idx))
        report "output=" & to_string(output) &
        ", but expected " & to_string(OUTPUT_EXPECTED(output_idx))
        severity warning;
      wait for INPUT_DELAY*PERIOD;
    end loop;
    -- Run for extra time to draw waveform
    wait for PERIOD*100.0;
    -- Force testbench to stop
    report "Testbech finished!" severity failure;
  end process verification_proc;
  
end architecture fir_filter_tb_arch;
