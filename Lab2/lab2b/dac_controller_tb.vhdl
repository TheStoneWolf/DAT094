-- DAT094 - Lab 2b
--
-- Testbench for the simplified DAC controller, vith tests included to verify
-- the timing of the DAC controller as specified by datasheet for the Microchip
-- MCP4822. The LDAC pin is removed as a simplification. 
--
-- Author:  Erik Börjeson
-- Date:    2023-09-11
-- Version: 1.0
library ieee;
use ieee.std_logic_1164.all;

entity dac_controller_tb is
end entity dac_controller_tb;

architecture dac_controller_tb_arch of dac_controller_tb is

  constant CLK_FREQ : real := 100.0e6;
  constant SPI_FREQ : real := 20.0e6;

  constant PERIOD : time := 1.0/CLK_FREQ*1.0e9 ns;

  constant TEST_CHANNEL  : std_logic                     := '1';
  constant TEST_GAIN     : std_logic                     := '0';
  constant TEST_SHUTDOWN : std_logic                     := '0';
  constant TEST_DATA     : std_logic_vector(11 downto 0) := "101110001010";

  component dac_controller is
    generic(	CLK_FREQ : real := 100.0e6;
           	SPI_FREQ : real := 20.0e6);
  	port (	clk      : in  std_logic;
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

  clk <= not clk after PERIOD/2.0;

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


  -- Timing checks, see MCP4822 data sheet.
  t_HI_proc : process(dac_sck)
  begin
    if falling_edge(dac_sck) then
      assert dac_sck'delayed'stable(15 ns) report "Clock High Time < 15 ns" severity warning;
    end if;
  end process t_HI_proc;

  t_LO_proc : process(dac_sck)
  begin
    if rising_edge(dac_sck) then
      assert dac_sck'delayed'stable(15 ns) report "Clock Low Time < 15 ns" severity warning;
    end if;
  end process t_LO_proc;

  t_CSSR_proc : process(dac_cs)
  -- Only applies when CS falls with CLK high. In this implementation CLK
  -- should be low when CS falls, so check that instead.
  begin
    if falling_edge(dac_cs) then
      assert dac_sck = '0' report "SCK != 0 When CS Falls" severity warning;
    end if;
  end process t_CSSR_proc;

  t_SU_proc : process (dac_sck)
  begin
    if rising_edge(dac_sck) then
      assert dac_sdi'stable(15 ns) report "Data Input Setup Time < 15 ns" severity warning;
    end if;
  end process t_SU_proc;

  t_HD_proc : process
  begin
    wait until rising_edge(dac_sck);
    wait for 10 ns;
    assert dac_sdi'stable(10 ns) report "Data Input Hold Time < 10 ns" severity warning;
  end process t_HD_proc;

  t_CHS_proc : process (dac_cs, dac_sck)
    variable last_sck_rising_edge : time := 0 ns;
  begin
    if rising_edge(dac_sck) then
      last_sck_rising_edge := now;
    end if;
    if rising_edge(dac_cs) then
      assert now - last_sck_rising_edge >= 15 ns report "SCK Rise to CS Rise Hold Time < 15 ns" severity warning;
    end if;
  end process t_CHS_proc;

  t_CSH_proc : process (dac_cs)
  begin
    if falling_edge(dac_cs) then
      assert dac_cs'delayed'stable(15 ns) report "CS Hight Time < 15 ns" severity warning;
    end if;
  end process t_CSH_proc;

  -- Verify that we transfer 16 bits during one CS write command
  cs_duration_proc : process (dac_cs, dac_sck)
    variable sck_rising_edges : integer := 0;
  begin
    if falling_edge(dac_cs) then
      sck_rising_edges := 0;
    end if;
    if rising_edge(dac_sck) then
      sck_rising_edges := sck_rising_edges + 1;
    end if;
    if rising_edge(dac_cs) then
      assert sck_rising_edges = 16 report "Number of SCK edges during one CS write command != 16" severity warning;
    end if;
  end process cs_duration_proc;

  -- Receive data and compare to transmitted data
  data_verification_proc : process
  begin
    wait until falling_edge(dac_cs);
    wait for PERIOD/4;
    assert busy = '1' report "Busy signal not set" severity warning;
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
    wait for PERIOD/4;
    assert busy = '0' report "Busy signal not reset" severity warning;
    wait for PERIOD;
    -- Force testbench to stop when the transmission is finished.
    report "Testbench finished!" severity failure;
  end process data_verification_proc;
  

end architecture dac_controller_tb_arch;
