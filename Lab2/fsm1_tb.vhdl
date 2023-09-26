library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm1_tb is
end entity fsm1_tb;

architecture arch of fsm1_tb is

  -- settings
  -- 
  constant THE_WIDTH : natural                              := 12;
  constant TESTVEC   : std_logic_vector(THE_WIDTH downto 1) := "101001011010";
  --constant SPI_PERIOD : natural				    := 10; --The period is equal to 10 clock cycles

  -- component declarations
  -- 
  component fsm1 is
    generic (WIDTH : natural range 1 to 16);
    port (d      : in  std_logic_vector(width - 1 downto 0);
          clk    : in  std_logic;
          reset  : in  std_logic;
          load   : in  std_logic;
          start  : in  std_logic;
	  spi_comp: in std_logic;
          shout  : out std_logic;
          done   : out std_logic);
  end component fsm1;

  -- signal declarations
  -- 
  signal d      : std_logic_vector(THE_WIDTH downto 1);
  signal clk    : std_logic := '1';
  signal reset  : std_logic;
  signal load   : std_logic;
  signal start  : std_logic;
  signal spi_comp: std_logic := '0';
  signal shout  : std_logic;
  signal done   : std_logic;

begin

  fsm1_inst : component fsm1
    generic map (WIDTH => THE_WIDTH)
    port map (d      => d,
              clk    => clk,
              reset  => reset,
              load   => load,
              start  => start,
	      spi_comp => spi_comp,
              shout  => shout,
              done   => done);

  -- clock generation 
  clk_proc : process
  begin
    wait for 5 ns;
    clk <= not(clk);
  end process clk_proc;
  
  -- SPI generation
  spi_proc : process
  begin
    spi_comp <= '0';
    wait for 90 ns;
    spi_comp <= '1';
    wait for 10 ns;
  end process;

  d <= TESTVEC;

  reset <= '0',
           '1' after 50 ns,
           '0' after 250 ns;

  load <= '0',
          '1' after 350 ns,
          '0' after 550 ns;

  start <= '0',
           '1' after 850 ns,
           '0' after 1050 ns;

  test_proc : process
  begin
    wait for 200 ns;
    assert (reset = '1')
      report "no reset"
      severity warning;

    wait for 310 ns;
    assert (load = '1')
      report "no load"
      severity warning;

    wait for 370 ns;
    assert (start = '1')
      report "no start"
      severity warning;

    for idx in 11 to 0 loop
      wait until falling_edge(spi_comp);
      assert shout = TESTVEC(idx) report "Error in shout bit " & integer'image(idx) severity warning;
    end loop;

    wait for 10000 ns;

    -- halt testbench 
    report "Testbench finished!" severity failure;

  end process test_proc;

end architecture arch;

