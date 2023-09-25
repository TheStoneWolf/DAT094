library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm2_tb is
end entity fsm2_tb;

architecture arch of fsm2_tb is

  -- settings
  -- 
  constant THE_WIDTH : natural                              := 12;
  --constant SPI_PERIOD : natural				    := 10; --The period is equal to 10 clock cycles

  -- component declarations
  -- 
  component fsm2 is
    	generic ( SPI_PERIOD : integer); --A multiplicative of the symstem clock 
	port(
		clk 	: in std_logic;
		reset 	: in std_logic;
		enable	: in std_logic;
		done	: in std_logic;
		channel	: in std_logic;
		gain    : in  std_logic;
        	shutdown: in  std_logic;
		load	: out std_logic;
		start	: out std_logic;
		shout	: out std_logic;
		dac_cs	: out std_logic;
		busy	: out std_logic;
		dac_sck	: out std_logic;
		spi_comp : out std_logic);
  end component;

  -- signal declarations
  -- 
  signal clk    : std_logic := '1';
  signal enable : std_logic;
  signal reset  : std_logic;
  signal load   : std_logic;
  signal start  : std_logic;
  signal dac_sck: std_logic;
  signal shout  : std_logic := '0';
  signal done   : std_logic;
  signal channel: std_logic;
  signal gain	: std_logic;
  signal shutdown:std_logic;
  signal dac_cs	: std_logic;
  signal busy   : std_logic;
  signal spi_comp : std_logic;

begin

  fsm2_inst : component fsm2
    generic map(SPI_PERIOD => 5)
    port map (clk    => clk,
	      enable => enable,
              reset  => reset,
              done   => done,
              channel=> channel,
              gain   => gain,
              shutdown=> shutdown,
              load   => load,
              start  => start,
	      shout  => shout,
	      dac_cs => dac_cs,
	      busy   => busy,
	      dac_sck => dac_sck,
	      spi_comp => spi_comp);

  -- clock generation 
  clk_proc : process
  begin
    wait for 5 ns;
    clk <= not(clk);
  end process clk_proc;

  -- enable generation 
  enable_proc : process
  begin
    enable <= '1';
    wait for 10 ns;
    enable <= '0';
    wait for 490 ns;
  end process enable_proc;

  reset <= '0',
           '1' after 50 ns,
           '0' after 250 ns;

  channel <= '1';
  gain <= '1';
  shutdown <= '0';

  test_proc : process
  begin 
    done <= '0';
    wait for 200 ns;
    assert (reset = '1')
      report "no reset"
      severity warning;
    
   wait until start = '1';
   wait for 2*5*10*5 ns;
   done <= '1';
   wait for 200 ns;
   done <= '0';

    wait for 10000 ns;

    -- halt testbench 
    report "Testbench finished!" severity failure;

  end process test_proc;

end architecture arch;

