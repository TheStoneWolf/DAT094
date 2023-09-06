-- DAT094 - Lab 1b
--
-- Testbench for the simplified DAC controller. Note that this testbench does
-- not verify the timing of the DAC controller (as specified by the datasheet
-- for the Microchip MCP4822), only that the signals are switched in the
-- correct order and that all bits are transmitted. The LDAC pin is removed as a
-- simplification. 
--
-- Author:  Erik Börjeson
-- Date:    2023-08-28
-- Version: 1.0
--
library ieee;
use ieee.std_logic_1164.all;

entity dac_controller_tb is
end entity dac_controller_tb;

architecture dac_controller_tb_arch of dac_controller_tb is

  -- Testbench settings
  constant CLK_FREQ : real := 100.0e6;
  constant SPI_FREQ : real := 10.0e6;

  constant TEST_CHANNEL  : std_logic                     := '1';
  constant TEST_GAIN     : std_logic                     := '0';
  constant TEST_SHUTDOWN : std_logic                     := '0';
  constant TEST_DATA     : std_logic_vector(11 downto 0) := "101110001010";

  -- Calculated constants
  constant PERIOD : time := 1.0/CLK_FREQ*1.0e9 ns;

  -- Component declarations
  component dac_controller is
    generic (CLK_FREQ : real;
             SPI_FREQ : real);
    port (clk      : in  std_logic;
          rst      : in  std_logic;
          enable   : in  std_logic;
          channel  : in  std_logic;
          gain     : in  std_logic;
          shutdown : in  std_logic;
          data     : in  std_logic_vector(11 downto 0);
          busy     : out std_logic;
          dac_cs   : out std_logic;
          dac_sck  : out std_logic;
          dac_sdi  : out std_logic);
  end component dac_controller;

  -- Signal declarations
  signal clk      : std_logic := '0';
  signal rst      : std_logic;
  signal enable   : std_logic;
  signal channel  : std_logic;
  signal gain     : std_logic;
  signal shutdown : std_logic;
  signal data     : std_logic_vector(11 downto 0);
  signal busy     : std_logic;
  signal dac_cs   : std_logic;
  signal dac_sck  : std_logic;
  signal dac_sdi  : std_logic;
  
begin

  -- Component instantiation
  dac_controller_inst : component dac_controller
    generic map (CLK_FREQ => CLK_FREQ,
                 SPI_FREQ => SPI_FREQ)
    port map (clk      => clk,
              rst      => rst,
              enable   => enable,
              channel  => channel,
              gain     => gain,
              shutdown => shutdown,
              data     => data,
              busy     => busy,
              dac_cs   => dac_cs,
              dac_sck  => dac_sck,
              dac_sdi  => dac_sdi);

  -- Clock generation
  clk <= not clk after PERIOD/2.0;

  -- Simulate one data transmission by setting DAC controller inputs
  set_inputs_proc : process
  begin
    rst      <= '0';
    enable   <= '0';
    channel  <= '0';
    gain     <= '0';
    shutdown <= '0';
    data     <= (others => '0');
    wait for PERIOD/4.0;
    wait for PERIOD;
    rst      <= '1';
    wait for PERIOD;
    rst      <= '0';
    wait for 10.0*PERIOD;
    enable   <= '1';
    channel  <= TEST_CHANNEL;
    gain     <= TEST_GAIN;
    shutdown <= TEST_SHUTDOWN;
    data     <= TEST_DATA;
    wait for PERIOD;
    enable   <= '0';
    wait;
  end process set_inputs_proc;


  -- Receive data and compare to transmitted data
  data_verification_proc : process
  begin
    wait until falling_edge(dac_cs);
    wait for PERIOD/2.0;
    assert busy = '1' report "Busy flag not set" severity warning;
    wait until rising_edge(dac_sck);
    assert dac_sdi = TEST_CHANNEL report "Error in Channel bit" severity warning;
    wait until rising_edge(dac_sck);
    -- Don't care bit, no need to check.
    wait until rising_edge(dac_sck);
    assert dac_sdi = TEST_GAIN report "Error in Gain bit" severity warning;
    wait until rising_edge(dac_sck);
    assert dac_sdi = TEST_SHUTDOWN report "Error in Shutdown bit" severity warning;
    for idx in 11 downto 0 loop
      wait until rising_edge(dac_sck);
      assert dac_sdi = TEST_DATA(idx) report "Error in Data bit " & integer'image(idx) severity warning;
    end loop;
    wait until rising_edge(dac_cs);
    wait for PERIOD;
    assert busy = '0' report "Busy flag not reset" severity warning;
    wait for PERIOD;
    -- Force testbench to stop when the transmission is finished.
    report "Testbench finished!" severity failure;
  end process data_verification_proc;
  

end architecture dac_controller_tb_arch;
